namespace WFramework
{
    public static class AgoraGame
    {
        public static INativeCallProxy NativeCallProxy = null;

        public static GameConfig Config = null;

        public static MessageMgr MessageMgr = null;

        public static ResMgr ResMgr = null;

        public static UIMgr UIMgr = null;

        public static UnityEngine.Transform Root = null;

        public static UnityEngine.MonoBehaviour CoroutineDrive = null;
        internal static void Init(UnityEngine.Transform transform, UnityEngine.MonoBehaviour mono)
        {
            Root = transform;
            CoroutineDrive = mono;

            Config = new GameConfig();
            Config.Init();
#if UNITY_EDITOR
            NativeCallProxy = new EditorCallProxy();
#elif UNITY_ANDROID
            NativeCallProxy = new AndroidCallProxy();
#elif UNITY_IOS
            NativeCallProxy = new IOSCallProxy();
#endif
            NativeCallProxy.Init();


            ResMgr = new ResMgr();
            ResMgr.Init();

            MessageMgr = new MessageMgr();

            NativeCallProxy.OnReceiveNativeMessage += MessageMgr.HandlerNativeMessage;

            UIMgr = new UIMgr();
            UIMgr.Init();

            NativeCallProxy.SendMessageToNative("unityLoadFinish", "{}");
#if UNITY_EDITOR
            MessageMgr.HandlerNativeMessage("loadScene", "{\"sceneId\":1}");
#endif
        }

        internal static void OnUpdate(float dt)
        {
            MessageMgr.OnUpdate(dt);
        }

        internal static void Clear()
        {
            CoroutineDrive.StopAllCoroutines();
            CoroutineDrive = null;
            NativeCallProxy.Clear();
            NativeCallProxy = null;
            Config = null;
            MessageMgr = null;
            ResMgr = null;
            Root = null;
        }
    }
}