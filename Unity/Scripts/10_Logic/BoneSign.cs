using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoneSign : MonoBehaviour
{
    [Header("Ñü²¿")]
    public Transform spine;
    [Header("¼ç°ò")]
    public Transform shoulder;
    [Header("²±×Ó")]
    public Transform neck;
    [Header("×ó¸ì²²Root")]
    public Transform leftUpArm;
    [Header("×ó¸ì²²Öâ")]
    public Transform leftElbow;
    [Header("ÓÒ¸ì²²Root")]
    public Transform rightUpArm;
    [Header("ÓÒ¸ì²²Öâ")]
    public Transform rightElbow;
    [Header("×óÍÈRoot")]
    public Transform leftLeg;
    [Header("×óÍÈÏ¥¸Ç")]
    public Transform leftKnee;
    [Header("ÓÒÍÈRoot")]
    public Transform rightLeg;
    [Header("ÓÒÍÈÏ¥¸Ç")]
    public Transform rightKnee;

    [SerializeField] private string[] boneNames;
    float deltaz = 0f;
    Vector3 upperArm = new Vector3(0f, 0f, 0f);
    Quaternion prevQ;
    private void Start()
    {
        //prevQ = leftUpArm.rotation;
        //Quaternion currentQ = Quaternion.Euler(upperArm.x, upperArm.y, upperArm.z);
        //leftUpArm.rotation = currentQ * prevQ;
    }
    private void Update()
    {
        //deltaz += 1f;
        //upperArm.z = deltaz;
        //Quaternion currentQ = Quaternion.Euler(upperArm.x, upperArm.y, upperArm.z);
        //leftUpArm.rotation = currentQ * prevQ;
    }

    [ContextMenu("±£´æ¹Ç÷ÀÃû×Ö")]
    private void SaveBoneName()
    {
        boneNames = new string[11];
        boneNames[0] = spine ? spine.name : null;
        boneNames[1] = shoulder ? shoulder.name : null;
        boneNames[2] = neck ? neck.name : null;
        boneNames[3] = leftUpArm ? leftUpArm.name : null;
        boneNames[4] = leftElbow ? leftElbow.name : null;
        boneNames[5] = rightUpArm ? rightUpArm.name : null;
        boneNames[6] = rightElbow ? rightElbow.name : null;
        boneNames[7] = leftLeg ? leftLeg.name : null;
        boneNames[8] = leftKnee ? leftKnee.name : null;
        boneNames[9] = rightLeg ? rightLeg.name : null;
        boneNames[10] = rightKnee ? rightKnee.name : null;
    }

    [ContextMenu("Ó³Éä¹Ç÷À")]
    private void MapBoneName()
    {
        Transform[] childs = transform.Find("root").GetComponentsInChildren<Transform>();
        System.Func<string, Transform> action = (name) =>
         {
             for (int i = 0; i < childs.Length; i++)
             {
                 if (childs[i].name == name)
                 {
                     return childs[i];
                 }
             }
             return null;
         };
        if (boneNames != null && boneNames.Length > 0)
        {
            spine = boneNames[0] != null ? action(boneNames[0]) : null;
            shoulder = boneNames[1] != null ? action(boneNames[1]) : null;
            neck = boneNames[2] != null ? action(boneNames[2]) : null;
            leftUpArm = boneNames[3] != null ? action(boneNames[3]) : null;
            leftElbow = boneNames[4] != null ? action(boneNames[4]) : null;
            rightUpArm = boneNames[5] != null ? action(boneNames[5]) : null;
            rightElbow = boneNames[6] != null ? action(boneNames[6]) : null;
            leftLeg = boneNames[7] != null ? action(boneNames[7]) : null;
            leftKnee = boneNames[8] != null ? action(boneNames[8]) : null;
            rightLeg = boneNames[9] != null ? action(boneNames[9]) : null;
            rightKnee = boneNames[10] != null ? action(boneNames[10]) : null;
        }
    }

    [ContextMenu("Ó³ÉäAvatar¹Ç÷À")]
    private void MapAvatarBoneName()
    {
        Animator anim = GetComponent<Animator>();
        spine = anim.GetBoneTransform(HumanBodyBones.Spine);
        shoulder = anim.GetBoneTransform(HumanBodyBones.UpperChest);
        neck = anim.GetBoneTransform(HumanBodyBones.Neck);
        leftUpArm = anim.GetBoneTransform(HumanBodyBones.LeftShoulder);
        leftElbow = anim.GetBoneTransform(HumanBodyBones.LeftLowerArm);
        rightUpArm = anim.GetBoneTransform(HumanBodyBones.RightShoulder);
        rightElbow = anim.GetBoneTransform(HumanBodyBones.RightLowerArm);
        leftLeg = anim.GetBoneTransform(HumanBodyBones.LeftUpperLeg);
        leftKnee = anim.GetBoneTransform(HumanBodyBones.LeftLowerLeg);
        rightLeg = anim.GetBoneTransform(HumanBodyBones.RightUpperLeg);
        rightKnee = anim.GetBoneTransform(HumanBodyBones.RightLowerLeg);
    }

    [ContextMenu("Çå¿Õ¹Ç÷ÀÒýÓÃ")]
    private void ClearBoneRef()
    {
        spine = null;
        shoulder = null;
        neck = null;
        leftUpArm = null;
        leftElbow = null;
        rightUpArm = null;
        rightElbow = null;
        leftLeg = null;
        leftKnee = null;
        rightLeg = null;
        rightKnee = null;
    }

    [ContextMenu("Êä³ö¹Ç÷Àglobal rotation")]
    private void PrintBoneRotation()
    {
        Debug.Log("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
        Debug.Log(spine.parent.rotation + " " + spine.parent.eulerAngles + " " + spine.parent.forward);
        Debug.Log("-----------------");
        Debug.Log(spine.rotation + " " + spine.eulerAngles + " " + spine.forward);
        Debug.Log(shoulder.rotation + " " + shoulder.eulerAngles + " " + shoulder.forward);
        Debug.Log(neck.rotation + " " + neck.eulerAngles + " " + neck.forward);
        Debug.Log(leftUpArm.rotation + " " + leftUpArm.eulerAngles + " " + leftUpArm.forward);
        Debug.Log(leftElbow.rotation + " " + leftElbow.eulerAngles + " " + leftElbow.forward);
        Debug.Log(rightUpArm.rotation + " " + rightUpArm.eulerAngles + " " + rightUpArm.forward);
        Debug.Log(rightElbow.rotation + " " + rightElbow.eulerAngles + " " + rightElbow.forward);
        Debug.Log(leftLeg.rotation + " " + leftLeg.eulerAngles + " " + leftLeg.forward);
        Debug.Log(leftKnee.rotation + " " + leftKnee.eulerAngles + " " + leftKnee.forward);
        Debug.Log(rightLeg.rotation + " " + rightLeg.eulerAngles + " " + rightLeg.forward);
        Debug.Log(rightKnee.rotation + " " + rightKnee.eulerAngles + " " + rightKnee.forward);
    }
}
