package io.agora.hack.believe.rtc

import io.agora.base.VideoFrame
import io.agora.rtc2.video.AgoraVideoFrame

/**
 * @author create by zhangwei03
 */
interface OnVideoReadListener {
    fun onVideoRead(videoFrame: VideoFrame)
}