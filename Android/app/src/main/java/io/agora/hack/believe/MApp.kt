package io.agora.hack.believe

import android.app.Application

/**
 * @author create by zhangwei03
 */
class MApp : Application() {

    companion object {
        private lateinit var app: Application

        @JvmStatic
        fun get(): Application {
            return app
        }
    }

    override fun onCreate() {
        super.onCreate()
        app = this
    }
}