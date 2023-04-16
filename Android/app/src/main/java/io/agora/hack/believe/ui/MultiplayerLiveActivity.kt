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
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.Toast
import androidx.core.view.isVisible
import com.google.android.gms.common.annotation.KeepName
import com.unity3d.player.UnityPlayer
import io.agora.base.VideoFrame
import io.agora.hack.believe.BaseUnityActivity
import io.agora.hack.believe.api.RoomScene
import io.agora.hack.believe.common.CameraSource
import io.agora.hack.believe.databinding.ActivityMultiplayerLivePreviewBinding
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

/** 多玩家 */
@KeepName
class MultiplayerLiveActivity : BaseUnityActivity<ActivityMultiplayerLivePreviewBinding>() {

    companion object {
        private const val POSE_DETECTION = "Pose Detection"
        private const val TAG = "MultiplayerLiveActivity"

        private const val KEY_CHANNEL_NAME = "key_channelName"
        private const val KEY_ROOM_SCENE = "key_roomScene"

        fun startActivity(context: Context, channelName: String, roomScene: Int) {
            val intent = Intent(context, MultiplayerLiveActivity::class.java).apply {
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
    private var remoteUid: Int = -1

    private val eventListener = IAgoraRtcClient.IChannelEventListener(
        onJoinChannelSuccess = {

        },
        onUserJoined = {
            setupRemoteView(it)
        },
        onUserOffline = {
            removeRemoteView(it)
        },
    )

    private fun setupRemoteView(uid: Int) {
        if (isSingle()) return
        if (remoteUid != -1) return
        remoteUid = uid
        rtcClient.setupRemoteVideo(
            rtcConnection,
            IAgoraRtcClient.VideoCanvasContainer(this, binding.layoutRemoteContainer, uid)
        )
    }

    // 古风，切瓜是单人场景
    private fun isSingle(): Boolean {
        return roomScene == RoomScene.Classical.value || roomScene == RoomScene.CutMelons.value
    }

    private fun removeRemoteView(uid: Int) {
        if (remoteUid == uid) {
            binding.layoutRemoteContainer.removeAllViews()
            remoteUid = -1
        }
    }

    override fun getViewBinding(inflater: LayoutInflater): ActivityMultiplayerLivePreviewBinding {
        return ActivityMultiplayerLivePreviewBinding.inflate(inflater)
    }

    override fun sendSceneToUnity() {
        super.sendSceneToUnity()
        LogTool.d("MultiplayerLiveActivity", "${System.currentTimeMillis() - start}")
        UnityProtocol.sendLoadScene(roomScene)

        // unity load finish 做后续操作
        binding.loading.root.isVisible = false
        createCameraSource(selectedModel)
        startCameraSource()
        RtmEngineInstance.subscribeMessage(channelName)
        RtmEngineInstance.setRtmChannelEventListener(
            RtmEngineInstance.IRtmChannelEventListener(
                onMessageEvent = { event: MessageEvent? ->
                    event ?: return@IRtmChannelEventListener
                    if (event.channelName != channelName) return@IRtmChannelEventListener
                    val msg =
                        if (event.messageType != RtmConstants.RtmMessageType.STRING) String(event.message) else String(
                            event.message
                        )
                    handleRtcMessage(msg)
                },
            )
        )
        joinChannel()
    }

    private var start = System.currentTimeMillis()

    override fun onCreate(savedInstanceState: Bundle?) {
        start = System.currentTimeMillis()
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
        binding.graphicOverlay.setOnClickListener {
            cameraSource?.let {
                if (it.cameraFacing == CameraSource.CAMERA_FACING_FRONT) {
                    it.setFacing(CameraSource.CAMERA_FACING_BACK)
                } else {
                    it.setFacing(CameraSource.CAMERA_FACING_FRONT)
                }
                binding.previewView.stop()
                startCameraSource()
            }
        }
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

    override fun initData() {
        channelName = intent.getStringExtra(KEY_CHANNEL_NAME) ?: "Test1"
        roomScene = intent.getIntExtra(KEY_ROOM_SCENE, RoomScene.Welcome.value)
        KeyCenter.channelName = channelName
        rtcConnection = RtcConnection(channelName, KeyCenter.curUid)
    }

    private fun handleRtcMessage(msg: String) {
        LogTool.d(TAG, "handleRtcMessage $msg")
        // 单人场景不处理
        if (isSingle()) return
        UnityProtocol.sendPosition3DToUnity(msg)
    }

    override fun setUpUnityPlayer(unityPlayer: UnityPlayer) {
        binding.layoutUnityContainer.addView(unityPlayer)
    }

    private fun createCameraSource(model: String) {
        // If there's no existing cameraSource, create one.
        if (cameraSource == null) {
            cameraSource = CameraSource(this, binding.graphicOverlay)
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