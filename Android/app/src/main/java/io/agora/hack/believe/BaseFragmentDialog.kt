package io.agora.hack.believe

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import androidx.viewbinding.ViewBinding
import android.view.LayoutInflater
import android.view.ViewGroup
import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.DialogFragment

abstract class BaseFragmentDialog<B : ViewBinding> : DialogFragment() {

    lateinit var mBinding: B

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val binding = getViewBinding(inflater, container) ?: return null
        this.mBinding = binding
        return this.mBinding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
    }

    protected abstract fun getViewBinding(inflater: LayoutInflater, container: ViewGroup?): B?

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        dialog?.window?.let {
            WindowCompat.setDecorFitsSystemWindows(it, false)
            it.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT));
        }
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                onHandleOnBackPressed()
            }
        })
    }

    protected fun setOnApplyWindowInsets(root: View) {
        dialog?.window?.let {
            ViewCompat.setOnApplyWindowInsetsListener(root) { v: View?, insets: WindowInsetsCompat ->
                val inset = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                root.setPadding(inset.left, 0, inset.right, inset.bottom + root.paddingBottom)
                WindowInsetsCompat.CONSUMED
            }
        }
    }

    open fun onHandleOnBackPressed() {
        dismiss()
    }
}