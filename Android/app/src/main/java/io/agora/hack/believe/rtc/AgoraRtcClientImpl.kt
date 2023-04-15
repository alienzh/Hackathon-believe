package io.agora.hack.believe.rtc

import android.os.Handler
import android.os.Looper
import android.view.TextureView
import android.view.View
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import io.agora.hack.believe.utils.LogTool
import io.agora.hack.believe.utils.ToastTool
import io.agora.rtc2.*
import io.agora.rtc2.video.VideoCanvas

class AgoraRtcClientImpl constructor(private val rtcEngine: RtcEngineEx) : IAgoraRtcClient {

    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    override fun joinChannel(
        connection: RtcConnection,
        mediaOptions: ChannelMediaOptions,
        eventListener: IAgoraRtcClient.IChannelEventListener
    ) {
        LogTool.d("rtc joinChannel start :${connection.channelId},uid=${connection.localUid}")
        val eventHandler = RtcEngineEventHandlerImpl(connection, eventListener)
        val ret = rtcEngine.joinChannelEx(null, connection, mediaOptions, eventHandler)
        LogTool.d("rtc joinChannel:${connection.channelId} code=$ret,message=${RtcEngine.getErrorDescription(ret)}")
    }

    override fun leaveChannel(connection: RtcConnection): Boolean {
        val ret = rtcEngine.leaveChannelEx(connection)
        LogTool.d("rtc leaveChannel: connection=$connection, code=$ret, message=${RtcEngine.getErrorDescription(ret)}")
        return false
    }

    override fun setupRemoteVideo(connection: RtcConnection, container: IAgoraRtcClient.VideoCanvasContainer) {
        var videoView = container.container.getChildAt(container.viewIndex)
        if (videoView !is TextureView) {
            videoView = TextureView(container.container.context)
            container.container.addView(videoView, container.viewIndex)
        } else {
            container.container.removeViewInLayout(videoView)
            videoView = TextureView(container.container.context)
            container.container.addView(videoView, container.viewIndex)
        }
        val remoteVideoCanvasWrap = RemoteVideoCanvasWrap(
            connection,
            container.lifecycleOwner,
            videoView,
            container.renderMode,
            container.uid
        )
        rtcEngine.setupRemoteVideoEx(remoteVideoCanvasWrap, connection)
    }

    override fun setupLocalVideo(container: IAgoraRtcClient.VideoCanvasContainer) {
        var videoView = container.container.getChildAt(container.viewIndex)
        if (videoView !is TextureView) {
            videoView = TextureView(container.container.context)
            container.container.addView(videoView, container.viewIndex)
        }
        rtcEngine.setupLocalVideo(
            LocalVideoCanvasWrap(container.lifecycleOwner, videoView, container.renderMode, container.uid)
        )
    }

    inner class LocalVideoCanvasWrap constructor(
        private val lifecycleOwner: LifecycleOwner,
        view: View,
        renderMode: Int,
        uid: Int
    ) :
        DefaultLifecycleObserver, VideoCanvas(view, renderMode, uid) {

        init {
            lifecycleOwner.lifecycle.addObserver(this)
        }

        override fun onDestroy(owner: LifecycleOwner) {
            super.onDestroy(owner)
            if (lifecycleOwner == owner) {
                release()
            }
        }

        fun release() {
            lifecycleOwner.lifecycle.removeObserver(this)
            view = null
            rtcEngine.setupLocalVideo(this)
        }

    }

    inner class RemoteVideoCanvasWrap constructor(
        private val connection: RtcConnection,
        private val lifecycleOwner: LifecycleOwner,
        view: View,
        renderMode: Int,
        uid: Int
    ) : DefaultLifecycleObserver, VideoCanvas(view, renderMode, uid) {

        init {
            mirrorMode = Constants.VIDEO_MIRROR_MODE_ENABLED
            lifecycleOwner.lifecycle.addObserver(this)
        }

        override fun onDestroy(owner: LifecycleOwner) {
            super.onDestroy(owner)
            if (lifecycleOwner == owner) {
                release()
            }
        }

        fun release() {
            lifecycleOwner.lifecycle.removeObserver(this)
            view = null
            rtcEngine.setupRemoteVideoEx(this, connection)
        }
    }


    inner class RtcEngineEventHandlerImpl constructor(
        private val connection: RtcConnection,
        private val eventListener: IAgoraRtcClient.IChannelEventListener,
    ) : IRtcEngineEventHandler() {

        override fun onError(err: Int) {
            super.onError(err)
            LogTool.e("rtc onError channel:${connection.channelId} error:code=$err, message=${RtcEngine.getErrorDescription(err)}")
        }

        override fun onJoinChannelSuccess(channel: String?, uid: Int, elapsed: Int) {
            super.onJoinChannelSuccess(channel, uid, elapsed)
            runOnUiThread {
                eventListener.onJoinChannelSuccess?.invoke()
                ToastTool.showToast("rtc onJoinChannelSuccess channel:$channel,uid:$uid")
            }
            LogTool.d("rtc onJoinChannelSuccess channel:$channel,uid:$uid")
        }

        override fun onLeaveChannel(stats: RtcStats?) {
            super.onLeaveChannel(stats)
            LogTool.d("rtc onLeaveChannel channel:${connection.channelId}")
        }

        override fun onUserJoined(uid: Int, elapsed: Int) {
            super.onUserJoined(uid, elapsed)
            LogTool.d("rtc onUserJoined channel ${connection.channelId},uid:$uid")
            runOnUiThread {
                eventListener.onUserJoined?.invoke(uid)
            }
        }

        override fun onUserOffline(uid: Int, reason: Int) {
            super.onUserOffline(uid, reason)
            LogTool.d("rtc onUserOffline channel:${connection.channelId},uid:$uid")
            runOnUiThread {
                eventListener.onUserOffline?.invoke(uid)
            }
        }
    }

    private fun runOnUiThread(run: () -> Unit) {
        if (Thread.currentThread() == mainHandler.looper.thread) {
            run.invoke()
        } else {
            mainHandler.post(run)
        }
    }
}