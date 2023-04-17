using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace WFramework
{
    public class AudioPlay
    {
        AudioSource bgmAudio;
        AudioSource effectAudio;
        public void Init()
        {
            Transform trans = GameObject.Find("Audio").transform;
            var audios = trans.GetComponents<AudioSource>();
            bgmAudio = audios[0];
            effectAudio = audios[1];
        }
        public void PlayBGM()
        {
            bgmAudio.Play();
        }
        public void PlayEffectAudio()
        {
            if (effectAudio.clip == null)
            {
            }
            effectAudio.Play();
        }
    }
}