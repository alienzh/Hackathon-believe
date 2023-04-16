namespace WFramework
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.UI;
    public class UIMgr
    {
        private const string ProgressFormatTxt = "正在加载场景：{0}%";
        private const string WaitLoadSceneMessage = "等待加载场景消息";

        private Transform loadPanel;
        private Text loadProgressTipText;
        private Image loadProgressValueImg;
        private Button btn1;
        private Button btn2;
        private Button btn3;
        //private Button btn4;
        private Button btnShow;
        private bool isShow = false;
        internal void Init()
        {
            loadPanel = AgoraGame.Root.Find("Canvas/LoadPanel");
            loadProgressTipText = loadPanel.Find("Tip").GetComponent<Text>();
            loadProgressValueImg = loadPanel.Find("ProgressImg").GetComponent<Image>();

            loadProgressTipText.text = WaitLoadSceneMessage;
            loadProgressValueImg.fillAmount = 0;

            btn1 = AgoraGame.Root.Find("Canvas/Btn1").GetComponent<Button>();
            btn2 = AgoraGame.Root.Find("Canvas/Btn2").GetComponent<Button>();
            btn3 = AgoraGame.Root.Find("Canvas/Btn3").GetComponent<Button>();
            //btn4 = AgoraGame.Root.Find("Canvas/Btn4").GetComponent<Button>();
            btn1.onClick.AddListener(() => { AgoraGame.MessageMgr.PlayCamAnim("CamMove3"); });
            btn2.onClick.AddListener(() => { AgoraGame.MessageMgr.PlayCamAnim("CamFar"); });
            btn3.onClick.AddListener(() => { AgoraGame.MessageMgr.PlayCamAnim("CamNear"); });
            InitSlider();
            InitV3SetPanel();
            btnShow = AgoraGame.Root.Find("Canvas/ShowBtn").GetComponent<Button>();
            isShow = false;
            btnShow.onClick.AddListener(() => 
            {
                isShow = !isShow;
                btn1.gameObject.SetActive(isShow);
                btn2.gameObject.SetActive(isShow);
                btn3.gameObject.SetActive(isShow);
                //btn4.gameObject.SetActive(isShow);
            });
            int index = Random.Range(0, 4);
            loadPanel.GetComponent<Image>().sprite = AgoraGame.ResMgr.assetRef.loadBGs[index];
        }

        public void SetProgressValue(float value)
        {
            if (value >= 1)
            {
                loadPanel.gameObject.SetActive(false);
            }
            else
            {
                loadPanel.gameObject.SetActive(true);
                loadProgressTipText.text = string.Format(ProgressFormatTxt, (value * 100).ToString("#0.0"));
                loadProgressValueImg.fillAmount = value;
            }
        }

        private Slider slider1;
        private Slider slider2;
        private Text text1;
        private Text text2;
        private void InitSlider()
        {
            slider1 = AgoraGame.Root.Find("Canvas/Slider1").GetComponent<Slider>();
            slider2 = AgoraGame.Root.Find("Canvas/Slider2").GetComponent<Slider>();
            text1 = AgoraGame.Root.Find("Canvas/Text1").GetComponent<Text>();
            text2 = AgoraGame.Root.Find("Canvas/Text2").GetComponent<Text>();

            slider1.onValueChanged.AddListener((v) =>
            {
                AgoraGame.Config.generalConfig.smoothValue = v;
                text1.text = v.ToString();
            });
            slider2.onValueChanged.AddListener((v) =>
            {
                AgoraGame.Config.generalConfig.zWeight = v;
                text2.text = v.ToString();
            });
            slider1.value = AgoraGame.Config.generalConfig.smoothValue;
            slider2.value = AgoraGame.Config.generalConfig.zWeight;
            text1.text = slider1.value.ToString();
            text2.text = slider2.value.ToString();
        }

        private Button btnSetOffset;
        private InputField inputX;
        private InputField inputY;
        private InputField inputZ;
        private void InitV3SetPanel()
        {
            Transform panel = AgoraGame.Root.Find("Canvas/V3SetPanel");
            inputX = panel.Find("InputX").GetComponent<InputField>();
            inputY = panel.Find("InputY").GetComponent<InputField>();
            inputZ = panel.Find("InputZ").GetComponent<InputField>();
            btnSetOffset = panel.Find("SetOffset").GetComponent<Button>();
            btnSetOffset.onClick.AddListener(() =>
            {
                float x = string.IsNullOrEmpty(inputX.text) ? 0 : float.Parse(inputX.text);
                float y = string.IsNullOrEmpty(inputY.text) ? 0 : float.Parse(inputY.text);
                float z = string.IsNullOrEmpty(inputZ.text) ? 0 : float.Parse(inputZ.text);
                //AgoraGame.Config.sceneConfig.rootOffset = new Vector3(x, y, z);
            });
        }
    }
}
