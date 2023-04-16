using System;
using UnityEngine;
using UnityEngine.EventSystems;
using Object = UnityEngine.Object;
using UnityEngine.Animations;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
public class EditorTools : Editor
{
    private static readonly string AssetBundleOutPath = Application.dataPath + "/../Output/AssetBundle/";

    [MenuItem("Tools/Rotate Zero")]
    static void ChangeImageRaycastTarget()
    {
        Transform trans = Selection.activeTransform;
        RotationConstraint[] ts = trans.GetComponentsInChildren<RotationConstraint>(true);
        for (int i = 0; i < ts.Length; i++)
        {
            Debug.Log(ts[i].name);
            ts[i].constraintActive = false;
        }
    }
    [MenuItem("Tools/��ab��(win)")]
    static void BuildABWin() 
    {
        BuildAB(BuildTarget.StandaloneWindows);
    }
    [MenuItem("Tools/��ab��(android)")]
    static void BuildABAndroid()
    {
        BuildAB(BuildTarget.Android);
    }
    [MenuItem("Tools/��ab��(ios)")]
    static void BuildABIOS()
    {
        BuildAB(BuildTarget.iOS);
    }

    [MenuItem("Tools/���ab")]
    static void SignAB() 
    {
        Object o = Selection.activeObject;
        var assetImport = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(o));
        assetImport.assetBundleName = o.name;
        assetImport.assetBundleVariant = "ab";
    }
    static void BuildAB(BuildTarget buildTarget)
    {
        string out_path = AssetBundleOutPath + GetPlatformStrByBuildTarget(buildTarget);

        if (!Directory.Exists(out_path))
        {
            Directory.CreateDirectory(out_path);
        }
        AssetBundleManifest manifest = BuildPipeline.BuildAssetBundles(out_path, BuildAssetBundleOptions.ChunkBasedCompression, buildTarget);
        if (manifest == null)
        {
            Debug.LogError("AssetBundle ���ʧ��");
        }
        else
        {
            Debug.Log("AssetBundle ������");
        }
    }

    private static string GetPlatformStrByBuildTarget(BuildTarget target)
    {
        string str = "None";
        switch (target)
        {
            case BuildTarget.Android:
                str = "Android";
                break;
            case BuildTarget.iOS:
                str = "IOS";
                break;
            case BuildTarget.StandaloneWindows:
                str = "Windows";
                break;
            case BuildTarget.StandaloneOSX:
                str = "Mac";
                break;
        }
        return str;
    }
}
#endif