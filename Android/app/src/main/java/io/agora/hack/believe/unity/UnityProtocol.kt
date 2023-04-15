package io.agora.hack.believe.unity

import com.google.mlkit.vision.common.PointF3D
import io.agora.hack.believe.rtc.RtmEngineInstance
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.LogTool
import org.json.JSONArray
import org.json.JSONObject

/**
 * @author create by zhangwei03
 */
object UnityProtocol {

    fun sendPosition3DToUnity(pointMap: Map<Int, PointF3D>) {
        if (UnityCallProxy.unityLoadCompleted()) {
            val jsonObj = JSONObject()
            jsonObj.put("userId", KeyCenter.curUid)
            val jsonObjPoint = JSONObject()
            pointMap.entries.forEach {
                val pointF3D = it.value
                jsonObjPoint.put(it.key.toString(), JSONArray().apply {
                    put(pointF3D.x)
                    put(-pointF3D.y)
                    put(pointF3D.z)
                })
            }
            jsonObj.put("point", jsonObjPoint)
            sendMessageToUnity("userState", jsonObj.toString())

            RtmEngineInstance.sendMessage(KeyCenter.channelName, jsonObj.toString())
        }
    }

    fun sendPosition3DToUnity(jsonString: String) {
        sendMessageToUnity("userState", jsonString)
    }

    fun sendLoadScene(sceneId: Int) {
        val jsonObj = JSONObject()
        jsonObj.put("sceneId", sceneId)
        sendMessageToUnity("loadScene", jsonObj.toString())
    }

    private fun sendMessageToUnity(key: String, msg: String) {
        LogTool.d("UnityProtocol", msg)
        UnityCallProxy.sendMessageToUnity(key, msg)
    }
}