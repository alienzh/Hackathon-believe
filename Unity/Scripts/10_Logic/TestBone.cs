using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestBone : MonoBehaviour
{
    private Transform body;
    private Transform upArm;
    private Transform lowArm;
    // Start is called before the first frame update
    void Start()
    {
        body = transform.Find("Body");
        upArm = body.Find("UpArm");
        lowArm = upArm.Find("LowArm");
        upArm.rotation = Quaternion.LookRotation(Vector3.right);
        Test();
    }

    // Update is called once per frame
    void Update()
    {
        Test();
    }

    void Test() 
    {
        
        lowArm.rotation = Quaternion.LookRotation(Vector3.up);
    }
}
