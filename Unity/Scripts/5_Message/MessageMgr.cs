//#define point

using System.Collections.Generic;
using System.IO;
using UnityEngine;
using Newtonsoft.Json;
namespace WFramework
{
    public class MessageMgr
    {
        internal void HandlerNativeMessage(string key, string jsonStr)
        {
            //Debug.Log("wjh " + key + " " + jsonStr);
            switch (key)
            {
                case MessageKeyConst.UserState:
                    UserStateMsg userState = JsonConvert.DeserializeObject<UserStateMsg>(jsonStr);
#if point
                    pointSim?.HandlerPointMove(userState.point);
#endif
                    battleCtrl?.HandlerPointMove(userState.userId, userState.point);
                    break;
                case MessageKeyConst.LoadScene:
                    LoadSceneMsg loadScene = JsonConvert.DeserializeObject<LoadSceneMsg>(jsonStr);
                    GameConfig.SceneId = loadScene.sceneId;
                    GameConfig.RoleNum = AgoraGame.Config.sceneConfig.roleNum[GameConfig.SceneId];
                    AgoraGame.ResMgr.LoadScene(loadScene.sceneId, (v) =>
                    {
                        AgoraGame.UIMgr.SetProgressValue(v);
                        if (v >= 1)
                        {
                            AgoraGame.NativeCallProxy.SendMessageToNative("loadSceneSuccess", "{}");
                            Init();
#if UNITY_EDITOR
                            Test();
#endif
                        }
                    });
                    break;
                default:
                    break;
            }
        }
#if point
        PointSim pointSim = null;
#endif
        BattleCtrl battleCtrl = null;
        Animator anim = null;
        internal void Init()
        {
            //anim = Camera.main.gameObject.AddComponent<Animator>();
            //anim.runtimeAnimatorController = AgoraGame.ResMgr.assetRef.ac;
            battleCtrl = new BattleCtrl();
            battleCtrl.Init();

            Transform trans = Camera.main.transform;
            if (GameConfig.SceneId == 0)
            {
                //trans.localPosition = new Vector3(-4f, 3.8f, -74);
                //trans.localEulerAngles = new Vector3(350, 120, 0);
                trans.localPosition = new Vector3(-1.36381507f, 4.39305639f, -72.6986923f);
                trans.localEulerAngles = new Vector3(0, 150, 0);
            }
            else if (GameConfig.SceneId == 1)
            {

            }
            else if (GameConfig.SceneId == 2)
            {
                spawnGo = new SpawnGo();
                spawnGo.Init();
                trans.localPosition = new Vector3(0f, 2f, -3f);
                trans.localEulerAngles = new Vector3(10f, 0, 0f);
            }
#if point
            pointSim = new PointSim();
            pointSim.CreatePoint();
#endif
        }

        internal void Test()
        {
            int playerCount = 1;

            for (int i = 0; i < playerCount; i++)
            {
                string jsonStr = File.ReadAllText($"{Application.streamingAssetsPath}/TestMessage{i}.json");
                HandlerNativeMessage(MessageKeyConst.UserState, jsonStr);
            }

        }
        public SpawnGo spawnGo;

        internal void OnUpdate(float dt)
        {
#if point
            pointSim?.OnUpdate(dt);
#endif
            battleCtrl?.OnUpdate(dt);
            if (GameConfig.SceneId == 2)
            {
                spawnGo?.OnUpdate(dt);
            }
        }

        internal void PlayCamAnim(string name)
        {
            if (anim)
            {
                anim.enabled = true;
                anim.Play(name, 0, 0);
            }
        }
    }

    public class MessageKeyConst
    {
        public const string UserState = "userState";
        public const string LoadScene = "loadScene";
    }

    public class UserStateMsg
    {
        public string userId;
        public Dictionary<string, double[]> point;
    }
    public class LoadSceneMsg
    {
        public int sceneId;
    }
}