package io.agora.hack.believe.utils

import android.os.Build
import android.os.CountDownTimer
import android.text.Html
import androidx.appcompat.widget.AppCompatTextView

class CountDownTimerUtils constructor(
    private val mTvTime: AppCompatTextView,
    millisInFuture: Int,
    countDownInterval: Int
) : CountDownTimer(millisInFuture.toLong(), countDownInterval.toLong()) {

    override fun onTick(millisUntilFinished: Long) {
        mTvTime.isClickable = false
        val openHtmlText =
            "<font color='#F7B500'>重新获取</font><font color='#F7B500'>(${millisUntilFinished / 1000}s)</font>"
        mTvTime.text = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) Html.fromHtml(
            openHtmlText,
            Html.FROM_HTML_MODE_LEGACY
        ) else Html.fromHtml(openHtmlText)
    }

    override fun onFinish() {
        mTvTime.isClickable = true
        mTvTime.text = "重新获取"
    }
}