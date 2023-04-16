package io.agora.hack.believe.utils

import android.content.Context
import android.content.SharedPreferences
import io.agora.hack.believe.MApp
import io.agora.hack.believe.api.RoomScene

/**
 * @author create by zhangwei03
 */
object KeyCenter {

    private const val SHARED_NAME = "MAPP_Member"

    // 当前场景，CutMelons 前置摄像头，其他后置摄像头
    var curRoomSceneId = RoomScene.Welcome.value

    private fun sp(): SharedPreferences? {
        return MApp.get().getSharedPreferences(SHARED_NAME, Context.MODE_PRIVATE)
    }

    fun isLogin(): Boolean {
        val phoneNumber = sp()?.getString("phone", "")
        if (phoneNumber.isNullOrEmpty()) return false
        if (phoneNumber.length != 11) return false
        val subPhone = phoneNumber.substring(4, 11)
        val uid = subPhone.toIntOrNull() ?: 0
        if (uid == 0) return false
        curUid = uid
        return true
    }

    fun setLogin(phoneNumber: String) {
        if (phoneNumber.length != 11) return
        val subPhone = phoneNumber.substring(4, 11)
        val uid = subPhone.toIntOrNull() ?: 0
        if (uid == 0) return
        sp()?.edit()?.let {
            it.putString("phone", phoneNumber)
            it.putInt("userId", uid)
            it.commit()
        }
        curUid = uid
    }

    fun logout() {
        sp()?.edit()?.let {
            it.putString("phone", "")
            it.putInt("userId", 0)
            it.commit()
        }
        curUid = 0
    }

    /**
     * rtc/rtm uid
     */
    var curUid: Int = 0

    var channelName: String = "Test1"
}