namespace WFramework
{
#if UNITY_ANDROID
    using System;
    using UnityEngine;
    public class AndroidCallback<T> : AndroidJavaProxy
    {
        private Action<T> callback;
        private T data;

        public AndroidCallback(Action<T> cb) : base($"{NativeConst.AndroidJavaPackageName}.{NativeConst.AndroidJavaClassNameCallback}")
        {
            callback = cb;
            data = default(T);//≥ı ºªØ
        }

        public void OnResult(T t)
        {
            data = t;

            if (callback != null)
            {
                callback(data);
            }
        }
    }
#endif
}