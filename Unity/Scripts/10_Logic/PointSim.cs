using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
namespace WFramework
{
    public class PointSim
    {
        List<Transform> points = null;
        private Vector3 offsetPos;

        public void CreatePoint()
        {
            posDatas = new Vector3[33];
            offsetPos = AgoraGame.Config.sceneConfig.posOriginPoint[0] + new Vector3(0, 4, 0);
            points = new List<Transform>();

            GameObject go = AgoraGame.Root.Find("EntityMgr/Point").gameObject;
            GameObject go1 = AgoraGame.Root.Find("EntityMgr/Point1").gameObject;
            for (int i = 0; i < 33; i++)
            {
                Transform trans;
                if (i > 12 && i < 17)
                {
                    trans = Object.Instantiate(go1).transform;
                }
                else
                {
                    trans = Object.Instantiate(go).transform;
                }
                trans.name = "Point" + i;
                trans.Find("Canvas/NumText").GetComponent<Text>().text = i.ToString();
                trans.gameObject.SetActive(true);
                points.Add(trans);
            }
            go.SetActive(false);
            go1.SetActive(false);
        }

        Vector3[] posDatas;
        public void HandlerPointMove(Dictionary<string, double[]> datas)
        {
            double scale = AgoraGame.Config.generalConfig.posScale;
            double zw = AgoraGame.Config.generalConfig.zWeight;

            for (int i = 0; i < posDatas.Length; i++)
            {
                if (datas.TryGetValue(i.ToString(), out double[] posData))
                {
                    Vector3 pos = new Vector3((float)(posData[0] / scale), (float)(posData[1] / scale), (float)(posData[2] / (-zw)));
                    posDatas[i] = pos;
                    points[i].position = pos + offsetPos;
                }
            }
        }

        internal void OnUpdate(float dt)
        {
        }
    }

    public struct Num2Int
    {
        public int a;
        public int b;

        public Num2Int(int a, int b)
        {
            this.a = a;
            this.b = b;
        }
    }
}