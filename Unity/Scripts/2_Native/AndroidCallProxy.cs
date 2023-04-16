namespace WFramework
{
#if UNITY_ANDROID
    using System;
    using UnityEngine;
    public class AndroidCallProxy : INativeCallProxy
    {
        private AndroidJavaClass mCallProxy = null;
        public event Action<string, string> OnReceiveNativeMessage = null;

        public void Init()
        {
            Debug.Log("AndroidMgr init");

            //尝试找到这个类(用于unity单独生成apk调试的时候，此时并没有集成统一通信框架)
            string className = $"{NativeConst.AndroidJavaPackageName}/{NativeConst.AndroidJavaClassNameCallProxy}";
            IntPtr ptr = AndroidJNI.FindClass(className);
            if (ptr == IntPtr.Zero)
            {
                Debug.LogWarning("class : UnityCallProxy not found");
                AndroidJNI.ExceptionClear();
            }
            else
            {
                mCallProxy = new AndroidJavaClass(className);
                //注册消息回调
                mCallProxy.CallStatic("RegisterUnityCallBack", new AndroidCallback<AndroidJavaObject>((cb) =>
                {
                     if (cb != null)
                     {
                         OnReceiveNativeMessage?.Invoke(cb.Get<string>("key"), cb.Get<string>("jsonMessage"));
                     }
                }));
            }
        }

        public void SendMessageToNative(string key, string json)
        {
            mCallProxy?.CallStatic("OnReceiveUnityMessage", key, json);
        }

        public void Clear()
        {
            if (mCallProxy != null)
            {
                mCallProxy.Dispose();
                mCallProxy = null;
            }
            OnReceiveNativeMessage = null;
        }
    }
#endif
}
