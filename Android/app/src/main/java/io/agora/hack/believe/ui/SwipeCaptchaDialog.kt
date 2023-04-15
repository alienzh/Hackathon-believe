package io.agora.hack.believe.ui

import android.graphics.Bitmap
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import androidx.fragment.app.FragmentManager
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition
import io.agora.hack.believe.BaseFragmentDialog
import io.agora.hack.believe.R
import io.agora.hack.believe.databinding.DialogSwipeCaptchaBinding
import io.agora.hack.believe.ui.SwipeCaptchaView.OnCaptchaMatchCallback
import io.agora.hack.believe.utils.DeviceTools.dp2px
import io.agora.hack.believe.utils.ToastTool
import java.util.*

open class SwipeCaptchaDialog constructor() : BaseFragmentDialog<DialogSwipeCaptchaBinding>() {
    override fun getViewBinding(inflater: LayoutInflater, container: ViewGroup?): DialogSwipeCaptchaBinding {
        return DialogSwipeCaptchaBinding.inflate(inflater)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    var matchSuccessCallback: (() -> Unit)? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        dialog?.window?.let {
            it.setLayout(dp2px(295f), dp2px(365f))
            it.attributes.gravity = Gravity.CENTER
        }
        initView()
    }

    private fun initView() {
        mBinding.iBtnRefresh.setOnClickListener { view: View? -> createCaptcha() }
        mBinding.swipeCaptchaView.onCaptchaMatchCallback = object : OnCaptchaMatchCallback {
            override fun matchSuccess(swipeCaptchaView: SwipeCaptchaView) {
                matchSuccessCallback?.invoke()
                mBinding.dragBar.isEnabled = false
                dismiss()
            }

            override fun matchFailed(swipeCaptchaView: SwipeCaptchaView) {
                ToastTool.showToast("请重试")
                createCaptcha()
            }
        }
        mBinding.dragBar.setOnSeekBarChangeListener(object : OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar, progress: Int, fromUser: Boolean) {
                mBinding.swipeCaptchaView.setCurrentSwipeValue(progress)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar) {
                //随便放这里是因为控件
                mBinding.dragBar.max = mBinding.swipeCaptchaView.maxSwipeValue
            }

            override fun onStopTrackingTouch(seekBar: SeekBar) {
                mBinding.swipeCaptchaView.matchCaptcha()
            }
        })
        createCaptcha()
    }

    private fun createCaptcha() {
        Glide.with(mBinding.root.context).asBitmap().load(exampleBackgrounds[Random().nextInt(5)])
            .into(object : SimpleTarget<Bitmap?>() {

                override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap?>?) {
                    mBinding.swipeCaptchaView.setImageBitmap(resource)
                    try {
                        mBinding.swipeCaptchaView.createCaptcha()
                    } catch (e: Exception) {
                        mBinding.swipeCaptchaView.resetCaptcha()
                    }
                }
            })
        mBinding.dragBar.isEnabled = true
        mBinding.dragBar.progress = 0
    }

    override fun show(manager: FragmentManager, tag: String?) {
        super.show(manager, tag)
    }

    companion object {
        val exampleBackgrounds: List<Int> = ArrayList(
            Arrays.asList(
                R.drawable.mvbg1,
                R.drawable.mvbg3,
                R.drawable.mvbg4,
                R.drawable.mvbg7,
                R.drawable.mvbg9
            )
        )
    }
}