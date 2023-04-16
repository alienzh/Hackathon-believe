using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.EventSystems;
namespace WFramework.Cmp
{
    public class UIEvent : MonoBehaviour , IPointerDownHandler, IPointerUpHandler, IDragHandler
    {
        Action<PointerEventData> dragAction = null;
        Action<PointerEventData> downAction = null;
        Action<PointerEventData> upAction = null;

        public void RegisterDrag(Action<PointerEventData> cb) 
        {
            dragAction = cb;
        }
        public void RegisterDown(Action<PointerEventData> cb)
        {
            downAction = cb;
        }
        public void RegisterUp(Action<PointerEventData> cb)
        {
            upAction = cb;
        }
        public void Clear() 
        {
            dragAction = null;
            downAction = null;
            upAction = null;
        }
        void IDragHandler.OnDrag(PointerEventData eventData)
        {
            dragAction?.Invoke(eventData);
        }

        void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
        {
            downAction?.Invoke(eventData);
        }

        void IPointerUpHandler.OnPointerUp(PointerEventData eventData)
        {
            upAction?.Invoke(eventData);
        }
    }
}