namespace WFramework
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using Random = UnityEngine.Random;
    public class SpawnGo
    {
        public static List<Tween> tweens = null;
        internal void Init()
        {
            tweens = new List<Tween>();
        }
        float currTimer = 0;
        private static Vector3 startPos = new Vector3(0, 1, 16);
        private static Vector3 dire = new Vector3(0, 0, -1);
        internal void OnUpdate(float dt)
        {
            currTimer += dt;
            if (currTimer > 1.5f)
            {
                currTimer = 0;
                Vector3 start = startPos + new Vector3(Random.Range(-1.5f, 1.5f), Random.Range(-1f, 1f), 0);
                Spawn(Random.Range(0, 5), start, start + dire * 20, Random.Range(5f, 10f));
            }


            for (int i = 0; i < tweens.Count; i++)
            {
                tweens[i].OnUpdate(dt);
            }
        }
        public void Spawn(int index, Vector3 start, Vector3 end, float dur)
        {
            GameObject go = AgoraGame.ResMgr.assetRef.CreateGo(index, start, Quaternion.identity);
            Tween tween = new Tween(start, end, dur, (v) =>
            {
                go.transform.localPosition = v;
            });
            tween.finish = () =>
            {
                AgoraGame.ResMgr.assetRef.RecycleGo(go);
                tweens.Remove(tween);
            };
            tweens.Add(tween);
            go.GetComponent<TriggerCmp>().action = () =>
            {
                AgoraGame.ResMgr.assetRef.PlayEffect(3, go.transform.localPosition, false, 1);
                AgoraGame.ResMgr.assetRef.RecycleGo(go);
                tweens.Remove(tween);
            };
        }


        public class Tween
        {
            private Vector3 start;
            private Vector3 end;
            private float dur;
            private System.Action<Vector3> action;
            public System.Action finish;

            public Tween(Vector3 start, Vector3 end, float dur, Action<Vector3> action)
            {
                this.start = start;
                this.end = end;
                this.dur = dur;
                this.action = action;
                this.curr = 0;
            }

            private float curr;
            public void OnUpdate(float dt)
            {
                curr += dt;
                if (curr > dur)
                {
                    finish();
                    return;
                }
                float t = curr / dur;
                Vector3 ret = start * (1 - t) + end * t;
                action(ret);
            }
        }


    }
}