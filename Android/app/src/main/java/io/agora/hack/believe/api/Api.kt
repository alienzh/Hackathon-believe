package io.agora.hack.believe.api

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

/**
 * @author create by zhangwei03
 *
 */
object Api {

    private val scope = CoroutineScope(Job() + Dispatchers.Main)

    fun fetchRoomList(success: ((List<RoomList>) -> Unit)? = null, failure: ((Exception?) -> Unit)? = null) {
        scope.launch(Dispatchers.Main) {
            try {
                success?.invoke(buildTestRoomList())
            } catch (e: Exception) {
                failure?.invoke(e)
            }
        }
    }

    private fun buildTestRoomList(): List<RoomList> {
        return mutableListOf<RoomList>().apply {
            add(
                RoomList(
                    roomId = "111",
                    roomName = "欢迎",
                    sceneId = RoomScene.Welcome.value,
                    status = RoomStatus.Audience.value
                )
            )
            add(
                RoomList(
                    roomId = "112",
                    roomName = "古风",
                    sceneId = RoomScene.Classical.value,
                    status = RoomStatus.Player.value
                )
            )
            add(
                RoomList(
                    roomId = "113",
                    roomName = "夜店",
                    sceneId = RoomScene.NightClub.value,
                    status = RoomStatus.Player.value
                )
            )
            add(
                RoomList(
                    roomId = "114",
                    roomName = "切瓜",
                    sceneId = RoomScene.CutMelons.value,
                    status = RoomStatus.Player.value
                )
            )
        }
    }
}