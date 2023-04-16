using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;

namespace WFramework
{
    public class ResMgr
    {
#if UNITY_EDITOR
        private static readonly string AssetBundleOutPath = $"{Application.dataPath}/../Output/AssetBundle/{GetABPlatformStr()}/" + "{0}";
#elif UNITY_ANDROID
        private static readonly string AssetBundleOutPath = Application.streamingAssetsPath + "/{0}";
#elif UNITY_IOS
        private static readonly string AssetBundleOutPath = Application.streamingAssetsPath + "/{0}";
#endif

        public AssetRef assetRef;
        internal void Init()
        {
            assetRef = AgoraGame.Root.GetComponent<AssetRef>();
        }

        public GameObject CreateGo(int index, Transform parent)
        {
            return assetRef.GetGo(index, parent);
        }

        Coroutine coroutine;
        private string curr_scene_name = null;
        public void LoadScene(int index, Action<float> progress_cb)
        {
            string ab_name = AgoraGame.Config.sceneConfig.abNames[index];
            string scene_name = AgoraGame.Config.sceneConfig.sceneNames[index];
            string ab_load_path = string.Format(AssetBundleOutPath, ab_name);
            coroutine = AgoraGame.CoroutineDrive.StartCoroutine(BeginLoadScene(ab_load_path, scene_name, progress_cb));
        }
        private IEnumerator BeginLoadScene(string scene_ab_path, string scene_name, Action<float> progress_cb)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            UnityWebRequest request = UnityWebRequestAssetBundle.GetAssetBundle(scene_ab_path);
            yield return request.SendWebRequest();
            var bundle = DownloadHandlerAssetBundle.GetContent(request);
#else
            var bundleRequest = AssetBundle.LoadFromFileAsync(scene_ab_path);
            while (!bundleRequest.isDone)
            {
                progress_cb?.Invoke(bundleRequest.progress * 0.7f);
                yield return null;
            }
            yield return bundleRequest;
            if (bundleRequest.assetBundle == null)
            {
                yield break;
            }
            var bundle = bundleRequest.assetBundle;
            bundleRequest = null;
#endif

            var sceneLoadOpt = SceneManager.LoadSceneAsync(scene_name, LoadSceneMode.Single);
            while (!sceneLoadOpt.isDone)
            {
                progress_cb?.Invoke(0.7f + sceneLoadOpt.progress * 0.3f);
                yield return null;
            }
            yield return sceneLoadOpt;
            curr_scene_name = scene_name;
            bundle.Unload(false);
            progress_cb?.Invoke(1);
            coroutine = null;
        }
        private static string GetABPlatformStr()
        {
            string ret = "None";
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    ret = "Android";
                    break;
                case RuntimePlatform.IPhonePlayer:
                    ret = "IOS";
                    break;
                case RuntimePlatform.WindowsPlayer:
                case RuntimePlatform.WindowsEditor:
                    ret = "Windows";
                    break;
                case RuntimePlatform.OSXPlayer:
                case RuntimePlatform.OSXEditor:
                    ret = "Mac";
                    break;
            }
            return ret;
        }
    }
}