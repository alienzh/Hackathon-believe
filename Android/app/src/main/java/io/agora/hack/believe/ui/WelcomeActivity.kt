package io.agora.hack.believe.ui

import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.view.LayoutInflater
import androidx.core.view.isVisible
import io.agora.hack.believe.BaseActivity
import io.agora.hack.believe.databinding.ActivityWelcomeBinding
import io.agora.hack.believe.rtc.AgoraRtcEngineInstance
import io.agora.hack.believe.rtc.IAgoraRtcClient
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.LogTool
import io.agora.rtc2.ChannelMediaOptions
import io.agora.rtc2.Constants
import io.agora.rtc2.RtcConnection

class WelcomeActivity : BaseActivity<ActivityWelcomeBinding>() {

    companion object {
        private const val TAG = "WelcomeActivity"

        private const val KEY_CHANNEL_NAME = "key_channelName"

        fun startActivity(context: Context,channelName: String) {
            val intent = Intent(context, WelcomeActivity::class.java).apply {
                putExtra(KEY_CHANNEL_NAME, channelName)
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            context.startActivity(intent)
        }
    }

    private var channelName: String = ""

    private var rtcConnection: RtcConnection = RtcConnection(channelName, KeyCenter.curUid)

    protected val rtcEngine by lazy { AgoraRtcEngineInstance.rtcEngine }
    protected val rtcClient by lazy { AgoraRtcEngineInstance.rtcClient }

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

    override fun getViewBinding(inflater: LayoutInflater): ActivityWelcomeBinding {
        return ActivityWelcomeBinding.inflate(inflater)
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        LogTool.d(TAG, "onCreate")
        binding.ivBack.setOnClickListener {
            rtcClient.leaveChannel(rtcConnection)
            RoomListActivity.startActivity(this)
            finish()
        }
        initData()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        initData()
    }

    private fun initData() {
        channelName = intent.getStringExtra(KEY_CHANNEL_NAME) ?: "Test1"
        rtcConnection = RtcConnection(channelName, KeyCenter.curUid)
        joinChannel()
    }

    private fun joinChannel() {
        val channelMediaOptions = ChannelMediaOptions().apply {
            clientRoleType = Constants.CLIENT_ROLE_AUDIENCE
            autoSubscribeVideo = true
            autoSubscribeAudio = true
        }
        rtcClient.joinChannel(rtcConnection, channelMediaOptions, eventListener)
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
}