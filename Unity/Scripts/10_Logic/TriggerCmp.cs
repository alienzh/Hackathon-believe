using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerCmp : MonoBehaviour
{
    public System.Action action;
    private void OnTriggerEnter(Collider other)
    {
        if (other.name == "Trigger")
        {
            action?.Invoke();
        }
    }
}
