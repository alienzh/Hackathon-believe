using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace WFramework
{
    public class GameLaunch : MonoBehaviour
    {

        private void Start()
        {
            DontDestroyOnLoad(this);
            Debug.Log("wjh unity start");
            AgoraGame.Init(transform, this);
        }

        private void Update()
        {
            float dt = Time.deltaTime;
            AgoraGame.OnUpdate(dt);
        }
        private void FixedUpdate()
        {

        }
        private void LateUpdate()
        {

        }
        private void OnApplicationFocus(bool focus)
        {

        }
        private void OnApplicationPause(bool pause)
        {

        }
        private void OnApplicationQuit()
        {

        }
        private void OnDestroy()
        {

        }

    }
}