package io.agora.hack.believe.ui

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import io.agora.hack.believe.BaseActivity
import io.agora.hack.believe.api.Api
import io.agora.hack.believe.api.RoomList
import io.agora.hack.believe.api.RoomScene
import io.agora.hack.believe.databinding.ActivityRoomListBinding
import io.agora.hack.believe.databinding.ItemRoomListBinding
import io.agora.hack.believe.rtc.AgoraRtcEngineInstance
import io.agora.hack.believe.rtc.RtmEngineInstance
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.LogTool
import io.agora.hack.believe.utils.ThreadTools
import io.agora.hack.believe.utils.ToastTool

class RoomListActivity : BaseActivity<ActivityRoomListBinding>() {

    companion object {
        private const val PERMISSION_REQUESTS = 100
        private val REQUIRED_RUNTIME_PERMISSIONS =
            arrayOf(
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
            )

        fun startActivity(context: Context) {
            val intent = Intent(context, RoomListActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            context.startActivity(intent)
        }
    }

    private val roomAdapter: BaseQuickAdapter<RoomList, RoomListAdapter.VH> by lazy {
        RoomListAdapter()
    }

    override fun getViewBinding(inflater: LayoutInflater): ActivityRoomListBinding {
        return ActivityRoomListBinding.inflate(inflater)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { _, insets ->
            val systemInset = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            LogTool.d("systemInset l:${systemInset.left},t:${systemInset.top},r:${systemInset.right},b:${systemInset.bottom}")
            binding.root.setPaddingRelative(0, systemInset.top, 0, 0)
            WindowInsetsCompat.CONSUMED
        }

        binding.titleView.setRightClick {
            RtmEngineInstance.destroy()
            AgoraRtcEngineInstance.destroy()
            KeyCenter.logout()
            LoginActivity.startActivity(this@RoomListActivity)
            finish()
        }
        binding.swipeRefreshLayout.setOnRefreshListener {
            ThreadTools.get()
                .runOnMainThreadDelay({ binding.swipeRefreshLayout.isRefreshing = false }, 1000)
        }
        roomAdapter.setOnItemClickListener { adapter, view, position ->
            adapter.getItem(position)?.let {
                KeyCenter.curRoomSceneId = it.sceneId
                when (it.sceneId) {
                    RoomScene.Welcome.value -> {
//                        WelcomeActivity.startActivity(this, it.roomId)
                        CameraUdpDemoActivity.startActivity(this)
                    }
                    RoomScene.Classical.value,
                    RoomScene.NightClub.value,
                    RoomScene.CutMelons.value -> {
                        MultiplayerLiveActivity.startActivity(this, it.roomId, it.sceneId)
                    }
                }
            }
        }
        binding.rvRoomList.adapter = roomAdapter
        if (!allRuntimePermissionsGranted()) {
            getRuntimePermissions()
        }
    }

    private fun allRuntimePermissionsGranted(): Boolean {
        for (permission in REQUIRED_RUNTIME_PERMISSIONS) {
            if (!isPermissionGranted(this, permission)) {
                return false
            }
        }
        return true
    }

    private fun getRuntimePermissions() {
        val permissionsToRequest = ArrayList<String>()
        for (permission in REQUIRED_RUNTIME_PERMISSIONS) {
            if (!isPermissionGranted(this, permission)) {
                permissionsToRequest.add(permission)
            }
        }

        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest.toTypedArray(),
                PERMISSION_REQUESTS
            )
        }
    }

    private fun isPermissionGranted(context: Context, permission: String): Boolean {
        if (ContextCompat.checkSelfPermission(
                context,
                permission
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            LogTool.d("Permission granted: $permission")
            return true
        }
        LogTool.e("Permission NOT granted: $permission")
        return false
    }

    override fun onResume() {
        val insetsController = WindowCompat.getInsetsController(window, window.decorView)
        insetsController.isAppearanceLightStatusBars = true
        super.onResume()
        getRoomList()
    }

    private fun getRoomList() {
        Api.fetchRoomList(success = {
            roomAdapter.submitList(it)
        }, failure = {
            it?.let { ToastTool.showToast(it.message) }
        })
    }

    inner class RoomListAdapter constructor() : BaseQuickAdapter<RoomList, RoomListAdapter.VH>() {
        inner class VH constructor(
            val parent: ViewGroup,
            val binding: ItemRoomListBinding = ItemRoomListBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        ) : RecyclerView.ViewHolder(binding.root)

        override fun onCreateViewHolder(context: Context, parent: ViewGroup, viewType: Int): VH {
            return VH(parent)
        }

        override fun onBindViewHolder(holder: VH, position: Int, item: RoomList?) {
            item ?: return
            holder.binding.tvRoomId.text = "Room ID:${item.roomId}"
            holder.binding.tvUserNum.text = "0"
            holder.binding.tvRoomName.text = item.roomName
        }
    }
}