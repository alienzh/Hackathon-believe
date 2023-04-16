using System.Collections.Generic;
using UnityEngine;
namespace WFramework
{
    public class BattleCtrl
    {
        List<string> partNames = null; //顺序为计算的顺序
        List<BoneSign> boneSigns = null;
        List<List<Transform>> partTransformss = null;
        List<List<Quaternion>> partTransformStartRotations = null;
        List<Num2Int> partRelations = null;
        List<Vector3> startDre = null;
        Vector3[] posDatas = null;

        public void Init()
        {
            boneSigns = new List<BoneSign>();
            System.Action<int> action = (i) =>
            {
                GameObject go = AgoraGame.ResMgr.CreateGo(i, AgoraGame.Root.Find("EntityMgr"));

                Vector3 pos = AgoraGame.Config.sceneConfig.posOriginPoint[GameConfig.SceneId];
                Vector3 offset = AgoraGame.Config.sceneConfig.RightDirectionOffset[GameConfig.SceneId];
                float inv = AgoraGame.Config.sceneConfig.posInv[GameConfig.SceneId];
                pos += (i % 2 == 0 ? 1 : -1) * (i / 2 + 1) * inv * offset;
                go.transform.localPosition = pos;

                float currAngle = AgoraGame.Config.sceneConfig.angleArray[GameConfig.SceneId];
                go.transform.localEulerAngles = new Vector3(0, currAngle, 0);

                boneSigns.Add(go.GetComponent<BoneSign>());
            };
            if (GameConfig.SceneId == 2)
            {
                action(3);
            }
            else
                for (int i = 0; i < GameConfig.RoleNum; i++)
                {
                    action(i);
                }

            posDatas = new Vector3[33];
            playerNames = new Dictionary<string, int>();
            _index = 0;

            InitConfig();
        }

        Dictionary<string, int> playerNames = null;
        int _index = 0;

        internal void HandlerPointMove(string userId, Dictionary<string, double[]> datas)
        {
            var config = AgoraGame.Config.generalConfig;
            double scale = config.posScale;
            double zw = config.zWeight;
            float minChange = config.posMinChange;

            for (int i = 0; i < posDatas.Length; i++)
            {
                if (datas.TryGetValue(i.ToString(), out double[] posData))
                {
                    Vector3 pos = new Vector3((float)(posData[0] / scale), (float)(posData[1] / scale), (float)(posData[2] / (-zw)));
                    if ((pos - posDatas[i]).sqrMagnitude > minChange)
                    {
                        posDatas[i] = pos;
                    }
                }
            }
            System.Action<int> action = (_playerIndex) =>
            {
                List<Transform> partTransforms = partTransformss[_playerIndex];
                BoneSign boneSign = boneSigns[_playerIndex];
                float y = boneSign.transform.eulerAngles.y;
                boneSign.transform.rotation = Quaternion.identity;

                for (int i = 0; i < partNames.Count; i++)
                {
                    Transform partTrans = partTransforms[i];
                    if (partTrans == null) continue;
                    Num2Int num2 = partRelations[i];
                    Vector3 angleV3 = (posDatas[num2.a] - posDatas[num2.b]).normalized;

                    Quaternion q = Quaternion.FromToRotation(startDre[i], angleV3);//可能会根据模型做适配,后来发现是左右乘法问题
                    smoothTargets[_playerIndex][i] = q * partTransformStartRotations[_playerIndex][i];
                }

                boneSign.transform.eulerAngles = new Vector3(0, y, 0);
                currSmoothTimes[_playerIndex] = 0f;

                Vector3 rootPointPos = (posDatas[11] + posDatas[12] + posDatas[23] + posDatas[24]) / 4;
                //boneSign.transform.localPosition = startPos[_playerIndex] + rootPointPos + AgoraGame.Config.sceneConfig.rootOffset[GameConfig.SceneId];
                smoothPosTargets[_playerIndex] = startPos[_playerIndex] + rootPointPos + AgoraGame.Config.sceneConfig.rootOffset[GameConfig.SceneId];
            };

            int _playerIndex = 0;
            if (playerNames.TryGetValue(userId, out int playerIndex))
            {
                _playerIndex = playerIndex;
            }
            else
            {
                _playerIndex = _index;
                playerNames.Add(userId, _index);
                _index++;
            }
            if (GameConfig.SceneId == 1)
            {
                action(_playerIndex);
            }
            else
            {
                for (int i = 0; i < GameConfig.RoleNum; i++)
                {
                    action(i);
                }
            }
        }

        List<Vector3> startPos = null;

        //平滑处理
        List<List<Quaternion>> smoothTargets = null;
        List<List<Quaternion>> smoothCurrs = null;

        List<float> currSmoothTimes = null;

        List<Vector3> smoothPosCurrs = null;
        List<Vector3> smoothPosTargets = null;

        internal void OnUpdate(float dt)
        {
            float smooth = AgoraGame.Config.generalConfig.smoothValue;
            for (int i = 0; i < boneSigns.Count; i++)
            {
                currSmoothTimes[i] += dt * smooth;
                //骨骼旋转平滑
                List<Quaternion> st = smoothTargets[i];
                List<Quaternion> sc = smoothCurrs[i];
                for (int j = 0; j < partNames.Count; j++)
                {
                    sc[j] = Quaternion.Slerp(sc[j], st[j], currSmoothTimes[i]);
                    partTransformss[i][j].rotation = sc[j];
                }
                //位置移动平滑
                smoothPosCurrs[i] = Vector3.Lerp(smoothPosCurrs[i], smoothPosTargets[i], currSmoothTimes[i]);
                boneSigns[i].transform.localPosition = smoothPosCurrs[i];
            }
            currTime += dt;
            if (currTime > invTime)
            {
                currTime = 0;

                //AgoraGame.ResMgr.assetRef.PlayEffect(Random.Range(0, 4), AgoraGame.Config.sceneConfig.posArray[0] + new Vector3(Random.Range(-5f, 5f), Random.Range(2f, 4f), Random.Range(-5f, 5f)));
            }
        }
        float currTime = 0f;
        float invTime = 2f;


        private void InitConfig()
        {
            partNames = new List<string>()
            {
                "spine",
                "shoulder",
                "neck",
                "leftUpArm",
                "rightUpArm",
                "leftElbow",
                "rightElbow",
                "leftLeg",
                "rightLeg",
                "leftKnee",
                "rightKnee",
            };
            startDre = new List<Vector3>()
            {
                Vector3.right,
                Vector3.right,
                Vector3.right,

                Vector3.left,
                Vector3.right,
                Vector3.left,
                Vector3.right,

                Vector3.down,
                Vector3.down,
                Vector3.down,
                Vector3.down,
            };
            partTransformss = new List<List<Transform>>();
            partTransformStartRotations = new List<List<Quaternion>>();
            smoothTargets = new List<List<Quaternion>>();
            smoothCurrs = new List<List<Quaternion>>();
            currSmoothTimes = new List<float>();
            smoothPosCurrs = new List<Vector3>();
            smoothPosTargets = new List<Vector3>();
            startPos = new List<Vector3>();
            for (int i = 0; i < boneSigns.Count; i++)
            {
                BoneSign sign = boneSigns[i];
                List<Transform> ts = new List<Transform>()
                {
                    sign.spine,
                    sign.shoulder,
                    sign.neck,
                    sign.leftUpArm,
                    sign.rightUpArm,
                    sign.leftElbow,
                    sign.rightElbow,
                    sign.leftLeg,
                    sign.rightLeg,
                    sign.leftKnee,
                    sign.rightKnee,
                };
                List<Quaternion> qs = new List<Quaternion>()
                {
                    sign.spine.rotation,
                    sign.shoulder.rotation,
                    sign.neck.rotation,
                    sign.leftUpArm.rotation,
                    sign.rightUpArm.rotation,
                    sign.leftElbow.rotation,
                    sign.rightElbow.rotation,
                    sign.leftLeg.rotation,
                    sign.rightLeg.rotation,
                    sign.leftKnee.rotation,
                    sign.rightKnee.rotation,
                };
                partTransformss.Add(ts);
                partTransformStartRotations.Add(qs);

                smoothTargets.Add(new List<Quaternion>() {
                    Quaternion.identity,
                    Quaternion.identity,
                    Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                });
                smoothCurrs.Add(new List<Quaternion>() {
                    Quaternion.identity,
                    Quaternion.identity,
                    Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                    Quaternion.identity,Quaternion.identity,
                });
                currSmoothTimes.Add(0f);

                smoothPosCurrs.Add(sign.transform.localPosition);
                smoothPosTargets.Add(sign.transform.localPosition);

                startPos.Add(sign.transform.localPosition);
            }


            partRelations = new List<Num2Int>()
            {
                new Num2Int(24,23),
                new Num2Int(12,11),
                new Num2Int(8,7),
                new Num2Int(13,11),
                new Num2Int(14,12),
                new Num2Int(15,13),
                new Num2Int(16,14),
                new Num2Int(25,23),
                new Num2Int(26,24),
                new Num2Int(27,25),
                new Num2Int(28,26),
            };

            List<Quaternion> bridg = new List<Quaternion>()
            {
                Quaternion.identity,
                Quaternion.identity,
                Quaternion.identity,
                Quaternion.LookRotation(new Vector3(0, -1, 0)),
                Quaternion.LookRotation(new Vector3(0, -1, 0)),
                Quaternion.LookRotation(new Vector3(0, -1, 0)),
                Quaternion.LookRotation(new Vector3(0, -1, 0)),

                Quaternion.LookRotation(new Vector3(0, -1, 0)),
                Quaternion.LookRotation(new Vector3(0, -1, 0)),

                Quaternion.LookRotation(new Vector3(0, -1, 0))
                    * Quaternion.LookRotation(new Vector3(-1, 0, 0)),
                Quaternion.LookRotation(new Vector3(0, -1, 0))
                    * Quaternion.LookRotation(new Vector3(1, 0, 0)),
            };

        }
    }
}