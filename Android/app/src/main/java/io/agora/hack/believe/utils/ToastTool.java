package io.agora.hack.believe.utils;

import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import io.agora.hack.believe.MApp;

public class ToastTool {

    private static Handler mainHandler;

    public static void showToast(int resStringId) {
        runOnMainThread(() -> Toast.makeText(MApp.get(), resStringId, Toast.LENGTH_SHORT).show());
    }

    public static void showToast(String str) {
        runOnMainThread(() -> Toast.makeText(MApp.get(), str, Toast.LENGTH_SHORT).show());
    }

    private static void runOnMainThread(Runnable runnable){
        if(mainHandler == null){
            mainHandler = new Handler(Looper.getMainLooper());
        }
        if(Thread.currentThread() == mainHandler.getLooper().getThread()){
            runnable.run();
        }else{
            mainHandler.post(runnable);
        }
    }
}
