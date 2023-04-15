package io.agora.hack.believe.rtc

import android.os.Handler
import android.os.Looper
import io.agora.hack.believe.BuildConfig
import io.agora.hack.believe.MApp
import io.agora.hack.believe.utils.ToastTool
import io.agora.rtc2.*

object AgoraRtcEngineInstance {

    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    private var innerRtcEngine: RtcEngineEx? = null
    val rtcEngine: RtcEngineEx
        get() {
            if (innerRtcEngine == null) {
                val config = RtcEngineConfig()
                config.mContext = MApp.get()
                config.mAppId = BuildConfig.RTC_APP_ID
                config.mEventHandler = object : IRtcEngineEventHandler() {
                    override fun onError(err: Int) {
                        super.onError(err)
                        mainHandler.post {
                            ToastTool.showToast("Rtc Error code:$err, msg:" + RtcEngine.getErrorDescription(err))
                        }
                    }
                }
                innerRtcEngine = (RtcEngine.create(config) as RtcEngineEx).apply {
                    enableVideo()
                }
            }
            return innerRtcEngine!!
        }

    private var innerAgoraClient: IAgoraRtcClient? = null
    val rtcClient: IAgoraRtcClient
        get() {
            if (innerAgoraClient == null) {
                innerAgoraClient = AgoraRtcClientImpl(rtcEngine)
            }
            return innerAgoraClient!!
        }

    fun destroy() {
        innerAgoraClient?.let {
            innerAgoraClient = null
        }
        innerRtcEngine?.let {
            RtcEngine.destroy()
            innerRtcEngine = null
        }
    }
}
