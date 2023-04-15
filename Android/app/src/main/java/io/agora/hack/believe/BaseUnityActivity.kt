package io.agora.hack.believe

import android.app.Activity
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.viewbinding.ViewBinding
import com.unity3d.player.IUnityPlayerLifecycleEvents
import com.unity3d.player.UnityPlayer
import com.unity3d.player.UnityPlayerEx
import io.agora.hack.believe.utils.LogTool
import io.agora.hack.believe.rtc.AgoraRtcEngineInstance
import io.agora.hack.believe.unity.UnityCallProxy

abstract class BaseUnityActivity<B : ViewBinding> : AppCompatActivity(), IUnityPlayerLifecycleEvents {

    lateinit var binding: B

    private var loadingDialog: AlertDialog? = null

    protected var mUnityPlayer: UnityPlayer? = null

    protected val rtcEngine by lazy { AgoraRtcEngineInstance.rtcEngine }
    protected val rtcClient by lazy { AgoraRtcEngineInstance.rtcClient }

    private val delegateUnity = object : UnityCallProxy.IReceiveUnityMessageDelegate{
        override fun onUnityLoadFinish() {
            super.onUnityLoadFinish()
            sendSceneToUnity()
        }
    }

    open fun sendSceneToUnity() {

    }

    open fun showLoading(cancelable: Boolean) {
        if (loadingDialog == null) {
            loadingDialog = AlertDialog.Builder(this).setView(R.layout.view_base_loading).create().apply {
                // 背景修改成透明
                window?.decorView?.setBackgroundColor(Color.TRANSPARENT)
            }
        }
        loadingDialog?.setCancelable(cancelable)
        loadingDialog?.show()
    }

    open fun dismissLoading() {
        loadingDialog?.dismiss()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes.apply {
                layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                window.attributes = this
            }
        }
        super.onCreate(savedInstanceState)
        val binding = getViewBinding(layoutInflater)
        if (binding == null) {
            LogTool.e("Inflate Error")
            finish()
        } else {
            this.binding = binding
            super.setContentView(this.binding.root)
        }

        WindowCompat.setDecorFitsSystemWindows(window, false)

        initData()
        mUnityPlayer = UnityPlayerEx(this, this)
        mUnityPlayer?.let {
            setUpUnityPlayer(it)
            it.requestFocus()
        }
        UnityCallProxy.bindRespDelegate(delegateUnity)
    }

    protected abstract fun initData()

    protected abstract fun setUpUnityPlayer(unityPlayer: UnityPlayer)

    protected abstract fun getViewBinding(inflater: LayoutInflater): B?

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        UnityCallProxy.bindRespDelegate(delegateUnity)
        setIntent(intent)
        initData()
        mUnityPlayer?.newIntent(intent)
    }

    override fun onStart() {
        super.onStart()
        mUnityPlayer?.resume()
    }

    override fun onPause() {
        super.onPause()
        mUnityPlayer?.pause()
    }

    override fun onResume() {
        super.onResume()
        mUnityPlayer?.resume()
    }

    override fun onDestroy() {
        super.onDestroy()
        mUnityPlayer?.destroy()
        UnityCallProxy.unbindRespDelegate(delegateUnity)
    }

    override fun onLowMemory() {
        super.onLowMemory()
        mUnityPlayer?.lowMemory()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        mUnityPlayer?.configurationChanged(newConfig)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        mUnityPlayer?.windowFocusChanged(hasFocus)
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        return if (event.action == KeyEvent.ACTION_MULTIPLE) mUnityPlayer?.injectEvent(event) ?: false
        else
            super.dispatchKeyEvent(event)
    }
    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        return mUnityPlayer?.injectEvent(event)?:false
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return mUnityPlayer?.injectEvent(event)?:false
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return mUnityPlayer?.injectEvent(event)?:false
    }

    /*API12*/
    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        return mUnityPlayer?.injectEvent(event)?:false
    }

    fun hideKeyboard() {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        if (window.attributes.softInputMode != WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN) {
            if (currentFocus != null) {
                imm.hideSoftInputFromWindow(currentFocus?.windowToken, InputMethodManager.HIDE_NOT_ALWAYS)
            }
        }
    }

    open fun showKeyboard(editText: EditText) {
        val imm = editText.context.getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(editText, 0)
    }

    fun getCurActivity(): Activity = this

    override fun onUnityPlayerUnloaded() {
        moveTaskToBack(true)
    }

    // Callback before Unity player process is killed
    override fun onUnityPlayerQuitted() {}

}