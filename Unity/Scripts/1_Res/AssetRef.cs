namespace WFramework
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    public class AssetRef : MonoBehaviour
    {
        [SerializeField] private GameObject[] avatars;
        [SerializeField] private GameObject[] effects;
        [SerializeField] private GameObject[] gos;
        [SerializeField] public RuntimeAnimatorController ac;
        public Sprite[] loadBGs;

        public Sprite[] tipImages;
        public GameObject GetGo(int index, Transform parent)
        {
            if (index < avatars.Length)
            {
                return Instantiate(avatars[index], parent);
            }
            return null;
        }
        public void PlayEffect(int index, Vector3 position, bool isLoop = false, float dur = -1)
        {
            var stack = GetGoStack(effects[index].name);
            GameObject go;
            if (stack.Count > 0)
            {
                go = stack.Pop();
                go.transform.localPosition = position;
            }
            else
            {
                go = Instantiate(effects[index], position, Quaternion.identity);
                go.name = effects[index].name;
            }
            go.SetActive(true);
            ParticleSystem ps = go.transform.Find("Particle System").GetComponent<ParticleSystem>();
            ps.loop = isLoop;
            ps.Simulate(1, false);
            ps.Play();
            if (!isLoop)
            {
                StartCoroutine(StartOnceTimer(dur < 0 ? ps.main.duration : dur, () =>
                   {
                       RecycleGo(go);
                   }));
            }
        }

        public GameObject CreateGo(int index, Vector3 position, Quaternion quaternion)
        {
            var stack = GetGoStack(gos[index].name);
            GameObject go;
            if (stack.Count > 0)
            {
                go = stack.Pop();
                go.transform.localPosition = position;
                go.transform.localRotation = quaternion;
            }
            else
            {
                go = Instantiate(gos[index], position, quaternion);
                go.name = gos[index].name;
            }
            go.SetActive(true);
            return go;
        }
        public void RecycleGo(GameObject go)
        {
            var stack = GetGoStack(go.name);
            go.SetActive(false);
            stack.Push(go);
        }

        Dictionary<string, Stack<GameObject>> go_pool = null;
        private Stack<GameObject> GetGoStack(string asset_name)
        {
            if (go_pool == null)
            {
                go_pool = new Dictionary<string, Stack<GameObject>>();
            }
            if (go_pool.TryGetValue(asset_name, out Stack<GameObject> go_stack))
            {
                return go_stack;
            }
            else
            {
                var stack = new Stack<GameObject>();
                go_pool.Add(asset_name, stack);
                return stack;
            }
        }

        private IEnumerator StartOnceTimer(float timer, System.Action action)
        {
            yield return new WaitForSeconds(timer);
            action();
        }
    }
}