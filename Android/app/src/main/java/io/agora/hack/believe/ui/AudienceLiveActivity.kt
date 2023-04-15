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
import android.os.Bundle
import android.view.LayoutInflater
import androidx.core.view.isVisible
import com.google.android.gms.common.annotation.KeepName
import com.google.gson.JsonElement
import com.unity3d.player.UnityPlayer
import io.agora.hack.believe.BaseUnityActivity
import io.agora.hack.believe.api.RoomScene
import io.agora.hack.believe.databinding.ActivityAudienceLivePreviewBinding
import io.agora.hack.believe.rtc.IAgoraRtcClient
import io.agora.hack.believe.rtc.RtmEngineInstance
import io.agora.hack.believe.unity.UnityProtocol
import io.agora.hack.believe.utils.GsonTools
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.LogTool
import io.agora.rtc2.ChannelMediaOptions
import io.agora.rtc2.Constants
import io.agora.rtc2.RtcConnection
import io.agora.rtm.MessageEvent
import io.agora.rtm.RtmConstants

/** 观众. */
@KeepName
class AudienceLiveActivity : BaseUnityActivity<ActivityAudienceLivePreviewBinding>() {

    companion object {
        private const val KEY_CHANNEL_NAME = "key_channelName"
        private const val KEY_ROOM_SCENE = "key_roomScene"

        fun startActivity(context: Context,  channelName: String, roomScene: Int) {
            val intent = Intent(context, AudienceLiveActivity::class.java).apply {
                putExtra(KEY_CHANNEL_NAME, channelName)
                putExtra(KEY_ROOM_SCENE, roomScene)
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            context.startActivity(intent)
        }
    }

    private var channelName: String = ""

    private var roomScene: Int = RoomScene.Welcome.value

    private var rtcConnection: RtcConnection = RtcConnection(channelName, KeyCenter.curUid)

    private val eventListener = IAgoraRtcClient.IChannelEventListener(
        onJoinChannelSuccess = {

        },
        onUserJoined = {
            runOnUiThread {
                initRemoteVideo(it)
            }
        },
        onUserOffline = {

        },
    )

    override fun getViewBinding(inflater: LayoutInflater): ActivityAudienceLivePreviewBinding {
        return ActivityAudienceLivePreviewBinding.inflate(inflater)
    }

    override fun sendSceneToUnity() {
        super.sendSceneToUnity()
        UnityProtocol.sendLoadScene(roomScene)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding.ivBack.setOnClickListener {
            rtcClient.leaveChannel(rtcConnection)
            RoomListActivity.startActivity(this)
        }
    }

    override fun initData() {
        channelName = intent.getStringExtra(KEY_CHANNEL_NAME) ?: "Test1"
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

    private fun initRemoteVideo(uid: Int) {
        binding.layoutRemoteContainer.isVisible = true
        rtcClient.setupRemoteVideo(
            rtcConnection,
            IAgoraRtcClient.VideoCanvasContainer(
                this, binding.layoutRemoteContainer, uid
            )
        )
    }

    private fun joinChannel() {
        val channelMediaOptions = ChannelMediaOptions().apply {
            clientRoleType = Constants.CLIENT_ROLE_AUDIENCE
            autoSubscribeVideo = true
            autoSubscribeAudio = true
        }
        rtcClient.joinChannel(rtcConnection, channelMediaOptions, eventListener)
    }

    override fun setUpUnityPlayer(unityPlayer: UnityPlayer) {
        binding.layoutUnityContainer.addView(unityPlayer)
    }

    private fun handleRtcMessage(msg: String) {
        LogTool.d( "handleRtcMessage $msg")
        val element: JsonElement? = GsonTools.toBean(msg, JsonElement::class.java)
        val jsonObj = element?.asJsonObject ?: return
        if (jsonObj.has("point")) {
            UnityProtocol.sendPosition3DToUnity(msg)
        }
    }

    public override fun onDestroy() {
        super.onDestroy()
        RtmEngineInstance.unsubscribe(channelName)
    }
}