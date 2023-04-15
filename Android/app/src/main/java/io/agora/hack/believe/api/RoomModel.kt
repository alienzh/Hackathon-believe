package io.agora.hack.believe.api

/**
 * @author create by zhangwei03
 */
data class RoomListData constructor(
    val code: Int,
    val message: String,
    val data: List<RoomList>
)

data class RoomList constructor(
    val roomId: String,
    val roomName: String,
    val sceneId: Int,
    val status: Int,
)

data class RoomInfo constructor(
    val roomId: String,
    val roomName: String,
    val sceneId: String,
    val status: Int,
    val players: List<UserInfo> = mutableListOf(),
    val audience: List<UserInfo> = mutableListOf()
)

data class UserInfo constructor(
    val userId: String,
    val nickname: String,
    val score: Int
)

enum class RoomScene constructor(val value: Int) {
    Welcome(-1),
    Classical(0),
    NightClub(1),
    CutMelons(2)
}

// roomStatus = 0;//0代表不能进入该房间,只能观战，1代表可以进入房间
enum class RoomStatus constructor(val value: Int) {
    Player(1),
    Audience(0)
}