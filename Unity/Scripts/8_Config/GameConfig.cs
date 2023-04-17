namespace WFramework
{
    using UnityEngine;
    using System.IO;
    using UnityEngine.Networking;
    using System.Collections;

    public class GameConfig
    {
        public static int SceneId = 0;
        public static int RoleNum = 1;


        public GeneralConfig generalConfig = null;
#if UNITY_ANDROID && !UNITY_EDITOR
        private static string ConfigFilePath = Application.persistentDataPath + "/config.json";
#else
        private static string ConfigFilePath = Application.streamingAssetsPath + "/config.json";
#endif

        public SceneConfig sceneConfig = null;
        public void Init()
        {
            Debug.Log("wjh GameConfig Init");
            /*string jsonStr = File.ReadAllText(ConfigFilePath);
            generalConfig = JsonUtility.FromJson<GeneralConfig>(jsonStr);*/
            generalConfig = new GeneralConfig()
            {
                zWeight = 330f,
                posScale = 170f,
                posMinChange = 0.05f,
                smoothValue = 3f,
            };
            sceneConfig = new SceneConfig()
            {
                abNames = new string[] {
                    "firstscene.ab",
                    "secondscene.ab",
                    "thirdscene.ab",
                },
                sceneNames = new string[] {
                    "Assets/Scenes/FirstScene.unity",
                    "Assets/Scenes/SecondScene.unity",
                    "Assets/Scenes/ThirdScene.unity",
                },

                posOriginPoint = new Vector3[]
                {
                    new Vector3(-1,3,-76.5f),
                    new Vector3(-2.75f,0,2f),
                    new Vector3(1f,0.5f,0f),
                },
                RightDirectionOffset = new Vector3[]
                {
                    //new Vector3(-1,0,-1).normalized,
                    Vector3.left,
                    Vector3.right,
                    Vector3.left,
                },
                angleArray = new float[] {
                    //300f,
                    0,
                    0,
                    0,
                },
                posInv = new float[] {
                    1,
                    2,
                    0,
                },
                roleNum = new int[] {
                    2,
                    2,
                    1,
                },
                rootOffset = new Vector3[]
                {
                    new Vector3(2f, 1f, 0),
                    new Vector3(0f, 1f, 0),
                    new Vector3(0f, 1f, 0),
                },
            };
        }
    }

    public class GeneralConfig
    {
        public float zWeight;
        public float posScale;
        public float posMinChange;
        public float smoothValue;
    }
    public class SceneConfig
    {
        public string[] abNames;
        public string[] sceneNames;

        public Vector3[] posOriginPoint;
        public Vector3[] RightDirectionOffset;
        public float[] angleArray;
        public float[] posInv;
        public int[] roleNum;

        public Vector3[] rootOffset;
    }
}