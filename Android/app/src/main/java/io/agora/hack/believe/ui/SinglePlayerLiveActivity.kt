/*
 * Copyright 2020 Google LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.agora.hack.believe.ui

import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import com.google.android.gms.common.annotation.KeepName
import com.unity3d.player.UnityPlayer
import io.agora.base.VideoFrame
import io.agora.hack.believe.BaseUnityActivity
import io.agora.hack.believe.api.RoomScene
import io.agora.hack.believe.common.CameraSource
import io.agora.hack.believe.databinding.ActivitySinglePlayerLivePreviewBinding
import io.agora.hack.believe.posedetector.PoseDetectorProcessor
import io.agora.hack.believe.rtc.IAgoraRtcClient
import io.agora.hack.believe.rtc.OnVideoReadListener
import io.agora.hack.believe.rtc.RtmEngineInstance
import io.agora.hack.believe.unity.UnityProtocol
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.LogTool
import io.agora.hack.believe.utils.PreferenceUtils
import io.agora.rtc2.ChannelMediaOptions
import io.agora.rtc2.Constants
import io.agora.rtc2.RtcConnection
import io.agora.rtm.MessageEvent
import io.agora.rtm.RtmConstants
import java.io.IOException

/** 单玩家. */
@KeepName
class SinglePlayerLiveActivity : BaseUnityActivity<ActivitySinglePlayerLivePreviewBinding>() {

    companion object {
        private const val POSE_DETECTION = "Pose Detection"
        private const val TAG = "SinglePlayerLiveActivity"

        private const val KEY_CHANNEL_NAME = "key_channelName"
        private const val KEY_ROOM_SCENE = "key_roomScene"

        fun startActivity(context: Context, channelName: String, roomScene: Int) {
            val intent = Intent(context, SinglePlayerLiveActivity::class.java).apply {
                putExtra(KEY_CHANNEL_NAME, channelName)
                putExtra(KEY_ROOM_SCENE, roomScene)
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            context.startActivity(intent)
        }
    }

    private var channelName: String = ""
    private var roomScene: Int = RoomScene.Welcome.value

    private var cameraSource: CameraSource? = null
    private var selectedModel = POSE_DETECTION
    private var videoTrackId: Int = -1

    private var rtcConnection: RtcConnection = RtcConnection(channelName, KeyCenter.curUid)

    private val eventListener = IAgoraRtcClient.IChannelEventListener(
        onJoinChannelSuccess = {

        },
        onUserJoined = {

        },
        onUserOffline = {

        },
    )

    override fun getViewBinding(inflater: LayoutInflater): ActivitySinglePlayerLivePreviewBinding {
        return ActivitySinglePlayerLivePreviewBinding.inflate(inflater)
    }

    override fun sendSceneToUnity() {
        super.sendSceneToUnity()
        UnityProtocol.sendLoadScene(roomScene)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.attributes.apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
            window.attributes = this
        }
        LogTool.d(TAG, "onCreate")
        binding.ivBack.setOnClickListener {
            if (videoTrackId != -1) {
                rtcEngine.destroyCustomVideoTrack(videoTrackId)
            }
            RoomListActivity.startActivity(this)
        }
        binding.facingSwitch.setOnCheckedChangeListener { _, isChecked ->
            LogTool.d(TAG, "Set facing")
            if (cameraSource != null) {
                if (isChecked) {
                    cameraSource?.setFacing(CameraSource.CAMERA_FACING_FRONT)
                } else {
                    cameraSource?.setFacing(CameraSource.CAMERA_FACING_BACK)
                }
            }
            binding.previewView.stop()
            startCameraSource()
        }
        createCameraSource(selectedModel)
    }

    override fun initData() {
        channelName = intent.getStringExtra(KEY_CHANNEL_NAME) ?: "Test1"
        roomScene = intent.getIntExtra(KEY_ROOM_SCENE, RoomScene.Welcome.value)
        KeyCenter.channelName = channelName
        rtcConnection = RtcConnection(channelName, KeyCenter.curUid)
        RtmEngineInstance.subscribeMessage(channelName)
        RtmEngineInstance.setRtmChannelEventListener(RtmEngineInstance.IRtmChannelEventListener(
            onMessageEvent = { event: MessageEvent? ->
                event ?: return@IRtmChannelEventListener
                if (event.channelName != channelName) return@IRtmChannelEventListener
                val msg =
                    if (event.messageType != RtmConstants.RtmMessageType.STRING) String(event.message) else String(
                        event.message
                    )
                handleRtcMessage(msg)
            }
        ))
        joinChannel()
    }

    private fun joinChannel() {
        videoTrackId = rtcEngine.createCustomVideoTrack()
        val channelMediaOptions = ChannelMediaOptions().apply {
            clientRoleType = Constants.CLIENT_ROLE_BROADCASTER
            autoSubscribeVideo = true
            autoSubscribeAudio = true
            publishCameraTrack = false
            publishCustomVideoTrack = true
            customVideoTrackId = videoTrackId
        }
        rtcClient.joinChannel(rtcConnection, channelMediaOptions, eventListener)
    }

    private fun handleRtcMessage(msg: String) {
        LogTool.d(TAG, "handleRtcMessage $msg")
        // 单人场景不会收到message
    }

    override fun setUpUnityPlayer(unityPlayer: UnityPlayer) {
        binding.layoutUnityContainer.addView(unityPlayer)
    }

    private fun createCameraSource(model: String) {
        // If there's no existing cameraSource, create one.
        if (cameraSource == null) {
            cameraSource = CameraSource(this, binding.graphicOverlay)
            if (roomScene == RoomScene.CutMelons.value) {
                // 切瓜前置摄像头
                cameraSource?.setFacing(CameraSource.CAMERA_FACING_FRONT)
            } else {
                cameraSource?.setFacing(CameraSource.CAMERA_FACING_BACK)
            }
        }
        cameraSource?.setOnVideoReadListener(object : OnVideoReadListener {
            override fun onVideoRead(videoFrame: VideoFrame) {
                if (videoTrackId != -1) {
                    rtcEngine.pushExternalVideoFrameEx(videoFrame, videoTrackId)
                }
            }
        })
        try {
            when (model) {
                POSE_DETECTION -> {
                    val poseDetectorOptions = PreferenceUtils.getPoseDetectorOptionsForLivePreview(this)
                    LogTool.d(TAG, "Using Pose Detector with options $poseDetectorOptions")
                    val shouldShowInFrameLikelihood =
                        PreferenceUtils.shouldShowPoseDetectionInFrameLikelihoodLivePreview(this)
                    val visualizeZ = PreferenceUtils.shouldPoseDetectionVisualizeZ(this)
                    val rescaleZ = PreferenceUtils.shouldPoseDetectionRescaleZForVisualization(this)
                    val runClassification = PreferenceUtils.shouldPoseDetectionRunClassification(this)
                    cameraSource!!.setMachineLearningFrameProcessor(
                        PoseDetectorProcessor(
                            this,
                            poseDetectorOptions,
                            shouldShowInFrameLikelihood,
                            visualizeZ,
                            rescaleZ,
                            runClassification,
                            /* isStreamMode = */ true
                        )
                    )
                }
                else -> LogTool.e(TAG, "Unknown model: $model")
            }
        } catch (e: Exception) {
            LogTool.e(TAG, "Can not create image processor: $model")
            Toast.makeText(
                applicationContext,
                "Can not create image processor: " + e.message,
                Toast.LENGTH_LONG
            )
                .show()
        }
    }

    /**
     * Starts or restarts the camera source, if it exists. If the camera source doesn't exist yet
     * (e.g., because onResume was called before the camera source was created), this will be called
     * again when the camera source is created.
     */
    private fun startCameraSource() {
        if (cameraSource != null) {
            try {
                binding.previewView.start(cameraSource, binding.graphicOverlay)
            } catch (e: IOException) {
                LogTool.e(TAG, "Unable to start camera source.")
                cameraSource?.release()
                cameraSource = null
            }
        }
    }

    public override fun onResume() {
        super.onResume()
        LogTool.d(TAG, "onResume")
        createCameraSource(selectedModel)
        startCameraSource()
    }

    /** Stops the camera. */
    override fun onPause() {
        super.onPause()
        LogTool.d(TAG, "onPause")
        binding.previewView.stop()
    }

    override fun onStop() {
        super.onStop()
        LogTool.d(TAG, "onStop")
    }

    public override fun onDestroy() {
        super.onDestroy()
        if (cameraSource != null) {
            cameraSource?.release()
        }
        RtmEngineInstance.unsubscribe(channelName)
    }
}