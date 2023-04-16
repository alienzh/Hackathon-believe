namespace WFramework
{
    using System;
    public interface INativeCallProxy
    {
        public event Action<string, string> OnReceiveNativeMessage;
        public void Init();
        public void SendMessageToNative(string key, string value);
        public void Clear();
    }

    public class EditorCallProxy : INativeCallProxy
    {
        public event Action<string, string> OnReceiveNativeMessage;

        public void Clear()
        {
            UnityEngine.Debug.Log("wjh EditorCallProxy Clear");
        }

        public void Init()
        {
            UnityEngine.Debug.Log("wjh EditorCallProxy Init");
        }

        public void SendMessageToNative(string key, string value)
        {
            
        }
    }
}