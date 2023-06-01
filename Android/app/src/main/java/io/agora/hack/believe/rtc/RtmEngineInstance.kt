package io.agora.hack.believe.rtc

import io.agora.hack.believe.BuildConfig
import io.agora.hack.believe.MApp
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.LogTool
import io.agora.rtm.*

/**
 * @author create by zhangwei03
 */
object RtmEngineInstance {

    data class IRtmChannelEventListener(
        var onMessageEvent: ((event: MessageEvent?) -> Unit)? = null,
        var onPresenceEvent: ((event: PresenceEvent?) -> Unit)? = null,
        var onTopicEvent: ((event: TopicEvent?) -> Unit)? = null,
        var onLockEvent: ((event: LockEvent?) -> Unit)? = null,
        var onStorageEvent: ((event: StorageEvent?) -> Unit)? = null,
        var onConnectionStateChange: ((channelName: String?, state: Int, reason: Int) -> Unit)? = null,
        var onTokenPrivilegeWillExpire: ((channelName: String?) -> Unit)? = null
    )

    private var rtmChannelEventListener: IRtmChannelEventListener? = null

    fun setRtmChannelEventListener(rtmChannelEventListener: IRtmChannelEventListener) {
        this.rtmChannelEventListener = rtmChannelEventListener
    }

    private var innerRtmClient: RtmClient? = null
    val rtmClient: RtmClient
        get() {
            if (innerRtmClient == null) {
                LogTool.d("rtmClient init curUid:${KeyCenter.curUid}")
                val rtmConfig = RtmConfig().apply {
                    appId = BuildConfig.RTM_APP_ID
                    userId = KeyCenter.curUid.toString()
                    context = MApp.get()
                    eventListener = object : RtmEventListener {
                        override fun onMessageEvent(event: MessageEvent?) {
                            LogTool.d( "onMessageEvent:$event")
                            rtmChannelEventListener?.onMessageEvent?.invoke(event)
                        }

                        override fun onPresenceEvent(event: PresenceEvent?) {
                            LogTool.d("onPresenceEvent:$event")
                            rtmChannelEventListener?.onPresenceEvent?.invoke(event)
                        }

                        override fun onTopicEvent(event: TopicEvent?) {
                            LogTool.d( "onTopicEvent:$event")
                            rtmChannelEventListener?.onTopicEvent?.invoke(event)
                        }

                        override fun onLockEvent(event: LockEvent?) {
                            LogTool.d("onLockEvent:$event")
                            rtmChannelEventListener?.onLockEvent?.invoke(event)
                        }

                        override fun onStorageEvent(event: StorageEvent?) {
                            LogTool.d( "onStorageEvent:$event")
                            rtmChannelEventListener?.onStorageEvent?.invoke(event)
                        }

                        override fun onConnectionStateChange(channel: String?, state: Int, reason: Int) {
                            LogTool.d("onConnectionStateChange channel:$channel,state:$state,reason:$reason")
                        }

                        override fun onTokenPrivilegeWillExpire(channel: String?) {
                            LogTool.d("onTokenPrivilegeWillExpire channel:$channel")
                            rtmChannelEventListener?.onTokenPrivilegeWillExpire?.invoke(channel)
                        }

                    }
                }
                innerRtmClient = RtmClient.create(rtmConfig)

            }
            return innerRtmClient!!
        }

    fun loginRtm(){
        rtmClient.login("", object : ResultCallback<Void> {
            override fun onSuccess(responseInfo: Void?) {
                LogTool.d("rtm login onSuccess")
            }

            override fun onFailure(errorInfo: ErrorInfo?) {
                LogTool.e( "rtm login onFailure:${errorInfo?.errorCode},${errorInfo?.errorReason}")
            }
        })
    }

    fun sendMessage(channelName: String, message: String) {
        rtmClient.publish(channelName, message, null, object : ResultCallback<Void> {
            override fun onSuccess(responseInfo: Void?) {
//                LogTool.d( "rtm sendMessage onSuccess")
            }

            override fun onFailure(errorInfo: ErrorInfo?) {
                LogTool.e("rtm sendMessage onFailure:${errorInfo?.errorCode},${errorInfo?.errorReason}")
            }

        })
    }

    fun subscribeMessage(channelName: String) {
        rtmClient.subscribe(channelName, SubscribeOptions(), object : ResultCallback<Void> {
            override fun onSuccess(responseInfo: Void?) {
                LogTool.d( "rtm subscribe onSuccess")
            }

            override fun onFailure(errorInfo: ErrorInfo?) {
                LogTool.e( "subscribe onFailure:${errorInfo?.errorCode},${errorInfo?.errorReason}")
            }

        })
    }

    fun unsubscribe(channelName: String) {
        rtmClient.unsubscribe(channelName)
        rtmChannelEventListener = null
    }

    fun destroy() {
        rtmClient.logout(object : ResultCallback<Void> {
            override fun onSuccess(responseInfo: Void?) {
                LogTool.d( "rtm logout onSuccess")
            }

            override fun onFailure(errorInfo: ErrorInfo?) {
                LogTool.e( "rtm logout onFailure:${errorInfo?.errorCode},${errorInfo?.errorReason}")
            }

        })
        innerRtmClient?.let {
            RtmClient.release()
            innerRtmClient = null
        }
    }
}