using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
namespace WFramework
{
#if UNITY_IOS
    public class IOSCallProxy : INativeCallProxy
    {
        public event Action<string, string> OnReceiveNativeMessage;

        public void Clear()
        {
        }

        public void Init()
        {
            RegisterCallback(IOSMessageCallback);
        }

        public void SendMessageToNative(string key, string value)
        {
            ReceiveMessage(key, value);
        }
        internal delegate void CallBack(string key, string message);

        [DllImport("__Internal")]
        internal static extern void RegisterCallback(CallBack callBack);

        [DllImport("__Internal")]
        internal static extern void ReceiveMessage(string key, string message);

        [DllImport("__Internal")]
        internal static extern void ErrorMessage(string message);

        [AOT.MonoPInvokeCallback(typeof(CallBack))]
        static void IOSMessageCallback(string key, string message)
        {
            (AgoraGame.NativeCallProxy as IOSCallProxy).OnReceiveNativeMessage?.Invoke(key, message);
        }
    }
    public class IOSUnityToNative
    {
        [StructLayout(LayoutKind.Sequential)]
        internal struct Parameter
        {
            public string cmd;
            public string message;
        }
    }
#endif
}