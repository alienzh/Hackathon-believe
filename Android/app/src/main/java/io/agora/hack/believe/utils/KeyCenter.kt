package io.agora.hack.believe.utils

import android.content.Context
import android.content.SharedPreferences
import io.agora.hack.believe.MApp
import io.agora.hack.believe.ai.model.AvatarB
import io.agora.hack.believe.ai.model.AvatarCtrlB
import java.io.IOException
import java.util.*
import kotlin.math.abs

/**
 * @author create by zhangwei03
 */
object KeyCenter {

    private const val SHARED_NAME = "MAPP_Member"

    const val base_url: String = "https://www.baidu.com"

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

    //发音人id
    private val avatarIds = arrayOf(
        "110022010",
        "110017006"
    )


    var aiUid: String = "d15968687895"

    @JvmStatic
    var avatarUid: String = avatarIds[0]

    // 虚拟人对象
    lateinit var avatarCtrlB: AvatarCtrlB

    lateinit var avatarB: AvatarB

    fun initAIAvatar() {
        val jsonText: String = readAssets("data/Virtual-ActioLlist.json")
        if (!::avatarCtrlB.isInitialized) {
            val bean = GsonTools.toBean(jsonText, AvatarCtrlB::class.java)
            if (bean == null) {
                throw java.lang.RuntimeException("init ai avatar error!")
                return
            }
            avatarCtrlB = bean
            val avatarList = avatarCtrlB.avatar_list
            val abilityAvatar = avatarList.filter { avatarIds.contains(it.avatar_id) }
            avatarCtrlB.avatar_list = abilityAvatar
            setCurrentAvatar(0)
        }
    }

    fun setCurrentAvatar(position: Int) {
        if (position >= avatarIds.size) {
            LogTool.e("虚拟形象选择异常")
        }
        avatarCtrlB.currentSelect = position
        avatarB = avatarCtrlB.currentSelectItem
        avatarUid = avatarB.avatar_id
    }

    private fun readAssets(assetsPath: String): String {
        val assetManager = MApp.get().resources.assets
        var jsonText = ""
        try {
            val ins = assetManager.open(assetsPath)
            val buffer = ByteArray(ins.available())
            ins.read(buffer)
            ins.close()
            jsonText = String(buffer)
        } catch (e: IOException) {
            e.printStackTrace()
        }
        LogTool.d("readAssets:$jsonText")
        return jsonText
    }
}