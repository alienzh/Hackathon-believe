package io.agora.hack.believe.unity;

import androidx.annotation.Nullable;

import io.agora.hack.believe.utils.DelegateHelper;

public class UnityCallProxy {
    private static IUnityEngineMessageCallBack<UnityEngineMessageWrapper> mUnityEngineMessageCallBack;

    private static boolean unityLoadFinish = false;

    private static DelegateHelper<IReceiveUnityMessageDelegate> delegateHelper = new DelegateHelper<>();

    public static void bindRespDelegate(@Nullable IReceiveUnityMessageDelegate delegate) {
        delegateHelper.bindDelegate(delegate);
    }

    public static void unbindRespDelegate(@Nullable IReceiveUnityMessageDelegate delegate) {
        delegateHelper.unBindDelegate(delegate);
    }

    public static void sendMessageToUnity(String key, String jsonMessage) {
        if (mUnityEngineMessageCallBack != null && unityLoadFinish) {
            UnityEngineMessageWrapper Message = new UnityEngineMessageWrapper();
            Message.key = key;
            Message.jsonMessage = jsonMessage;

            mUnityEngineMessageCallBack.OnResult(Message);
        }
    }

    public static boolean unityLoadCompleted(){
        return mUnityEngineMessageCallBack!=null && unityLoadFinish;
    }

    //Unity Call
    public static void OnReceiveUnityMessage(String key, String jsonMessage) {
        //native
        switch (key) {
            case "unityLoadFinish":
                unityLoadFinish = true;
                delegateHelper.notifyDelegate(IReceiveUnityMessageDelegate::onUnityLoadFinish);
                break;
            default:
                break;
        }
    }

    //Unity Call
    public static void RegisterUnityCallBack(IUnityEngineMessageCallBack<UnityEngineMessageWrapper> cb) {
        mUnityEngineMessageCallBack = cb;
    }

    public interface IReceiveUnityMessageDelegate {
        default void onUnityLoadFinish() {
        }
    }
}