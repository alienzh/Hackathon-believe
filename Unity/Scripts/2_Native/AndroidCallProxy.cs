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

            //�����ҵ������(����unity��������apk���Ե�ʱ�򣬴�ʱ��û�м���ͳһͨ�ſ��)
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
                //ע����Ϣ�ص�
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
