package io.agora.hack.believe.rtc

import android.view.ViewGroup
import androidx.lifecycle.LifecycleOwner
import io.agora.rtc2.ChannelMediaOptions
import io.agora.rtc2.Constants
import io.agora.rtc2.IRtcEngineEventHandler
import io.agora.rtc2.RtcConnection

interface IAgoraRtcClient {

    data class IChannelEventListener constructor(
        var onJoinChannelSuccess: (() -> Unit)? = null,
        var onUserJoined: ((uid: Int) -> Unit)? = null,
        var onUserOffline: ((uid: Int) -> Unit)? = null,
    )

    data class VideoCanvasContainer constructor(
        val lifecycleOwner: LifecycleOwner,
        val container: ViewGroup,
        val uid: Int,
        val viewIndex: Int = 0,
        val renderMode: Int = Constants.RENDER_MODE_HIDDEN,
    )

    /**
     * join channel
     */
    fun joinChannel(connection: RtcConnection, mediaOptions: ChannelMediaOptions, eventListener: IChannelEventListener)

    /**
     * leave channel
     */
    fun leaveChannel(connection: RtcConnection): Boolean

    /**
     * setup remote video
     */
    fun setupRemoteVideo(connection: RtcConnection, container: VideoCanvasContainer)

    /**
     * setup local video
     */
    fun setupLocalVideo(container: VideoCanvasContainer)
}