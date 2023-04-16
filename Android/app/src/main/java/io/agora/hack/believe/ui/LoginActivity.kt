package io.agora.hack.believe.ui

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import androidx.core.view.isVisible
import androidx.core.widget.doAfterTextChanged
import io.agora.hack.believe.BaseActivity
import io.agora.hack.believe.R
import io.agora.hack.believe.databinding.ActivityLoginBinding
import io.agora.hack.believe.rtc.RtmEngineInstance
import io.agora.hack.believe.utils.CountDownTimerUtils
import io.agora.hack.believe.utils.KeyCenter
import io.agora.hack.believe.utils.ThreadTools
import io.agora.hack.believe.utils.ToastTool

/**
 * @author create by zhangwei03
 */
class LoginActivity : BaseActivity<ActivityLoginBinding>() {

    private var swipeCaptchaDialog: SwipeCaptchaDialog? = null

    private var phone: String? = null
    private var countDownTimerUtils: CountDownTimerUtils? = null

    companion object {
        fun startActivity(context: Context) {
            val intent = Intent(context, LoginActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            context.startActivity(intent)
        }
    }

    override fun getViewBinding(inflater: LayoutInflater): ActivityLoginBinding {
        return ActivityLoginBinding.inflate(inflater)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (KeyCenter.isLogin()) {
            RoomListActivity.startActivity(this)
            RtmEngineInstance.loginRtm()
            finish()
        }
        initView()
        countDownTimerUtils = CountDownTimerUtils(binding.tvSendVCode, 60000, 1000)
    }

    private fun initView() {
        binding.btnLogin.setOnClickListener {
            if (binding.cvIAgree.isChecked) {
                if (checkAccount()) {
                    showSwipeCaptchaDialog()
                }
            } else {
                ToastTool.showToast(R.string.app_agreement_tips)
            }
        }
        binding.tvSendVCode.setOnClickListener { view ->
            val account: String = binding.etAccounts.text.toString()
            if (account.length != 11) {
                ToastTool.showToast(R.string.app_phone_tips)
            } else {
                requestSendVCode(account, requestCodeCallback = {
                    if (it) countDownTimerUtils?.start()
                })
            }
            dismissLoading()
        }
        binding.etAccounts.doAfterTextChanged {
            binding.iBtnClearAccount.isVisible = !it.isNullOrEmpty()
        }
        binding.iBtnClearAccount.setOnClickListener { view -> binding.etAccounts.setText("") }
    }


    private fun checkAccount(): Boolean {
        val account: String = binding.etAccounts.text.toString()
        if (account.length != 11) {
            ToastTool.showToast(R.string.app_phone_tips)
            return false
        } else if (phone.isNullOrEmpty()) {
            ToastTool.showToast(R.string.app_v_code_tips)
            return false
        } else if (TextUtils.isEmpty(binding.etVCode.text.toString())) {
            ToastTool.showToast(R.string.app_please_input_v_code)
            return false
        }
        return true
    }

    private fun showSwipeCaptchaDialog() {
        if (swipeCaptchaDialog == null) {
            swipeCaptchaDialog = SwipeCaptchaDialog()
            swipeCaptchaDialog?.matchSuccessCallback = {
                showLoading(false)
                val account: String = binding.etAccounts.text.toString()
                val vCode: String = binding.etVCode.text.toString()
                requestLogin(account, vCode, requestLoginCallback = {
                    if (it) {
                        RoomListActivity.startActivity(this@LoginActivity)
                        this@LoginActivity.finish()
                    } else {
                        dismissLoading()
                    }
                })
            }
        }
        swipeCaptchaDialog?.show(supportFragmentManager, "captcha")
    }

    private fun requestLogin(account: String, vCode: String, requestLoginCallback: (result: Boolean) -> Unit) {
        if (account != phone) {
            requestLoginCallback.invoke(false)
            return
        }
        KeyCenter.setLogin(account)
        RtmEngineInstance.loginRtm()
        // 模拟耗时登录
        ThreadTools.get().runOnMainThreadDelay({ requestLoginCallback.invoke(true) }, 1000)
    }

    private fun requestSendVCode(account: String, requestCodeCallback: (result: Boolean) -> Unit) {
        this.phone = account
        requestCodeCallback.invoke(true)
    }
}