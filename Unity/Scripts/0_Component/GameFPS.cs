using UnityEngine;
using UnityEngine.UI;

namespace Agora
{
    public class GameFPS : MonoBehaviour
    {
        private Text text;
        [SerializeField] private float interval = 1f;

        private int count = 0;
        private float timer = 0f;

        private float fps = 0;

        void Start()
        {
            text = GetComponent<Text>();
        }

        void Update()
        {
            count++;
            timer += Time.unscaledDeltaTime;
            if (timer >= interval)
            {
                fps = count / timer;
                count = 0;
                timer = 0f;
                text.text = fps.ToString("0.00");
            }
        }
    }
}