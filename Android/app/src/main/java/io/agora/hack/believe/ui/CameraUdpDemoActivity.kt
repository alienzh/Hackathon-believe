package io.agora.hack.believe.ui

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.widget.Toast
import io.agora.hack.believe.BaseActivity
import io.agora.hack.believe.common.CameraSource
import io.agora.hack.believe.databinding.ActivityCameraUdpDemoBinding
import io.agora.hack.believe.posedetector.PoseDetectorProcessor
import io.agora.hack.believe.unity.UnityProtocol
import io.agora.hack.believe.utils.LogTool
import io.agora.hack.believe.utils.PreferenceUtils
import io.agora.hack.believe.utils.ThreadTools
import io.agora.hack.believe.utils.UDPClient
import java.io.IOException

class CameraUdpDemoActivity : BaseActivity<ActivityCameraUdpDemoBinding>() {

    companion object {
        private const val POSE_DETECTION = "Pose Detection"
        private const val TAG = "CameraUdpDemoActivity"

        fun startActivity(context: Context) {
            val intent = Intent(context, CameraUdpDemoActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            context.startActivity(intent)
        }
    }

    private var udpClient: UDPClient? = null

    private var cameraSource: CameraSource? = null
    private var selectedModel = POSE_DETECTION

    private val delegateMessage = object : UnityProtocol.IReceiveMessageDelegate{
        override fun onReceivePoint(msg: String) {
            udpClient?.send(msg)
        }
    }

    override fun getViewBinding(inflater: LayoutInflater): ActivityCameraUdpDemoBinding {
        return ActivityCameraUdpDemoBinding.inflate(inflater)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding.ivBack.setOnClickListener {
            finish()
        }
        binding.btnStartData.setOnClickListener {
            val address = binding.etInputAddress.text.toString()
            val port = binding.etInputPort.text.toString().toIntOrNull() ?: 5555
            udpClient = UDPClient(address, port)
            ThreadTools.get().runOnIOThread {
                try {
                    udpClient?.run()
                }catch (e:IOException){
                    e.printStackTrace()
                }

            }
        }
        binding.btnStopData.setOnClickListener {
            udpClient?.stop()
            udpClient = null
        }
        binding.graphicOverlay.setOnClickListener {
            cameraSource?.let {
                if (it.cameraFacing == CameraSource.CAMERA_FACING_FRONT) {
                    it.setFacing(CameraSource.CAMERA_FACING_BACK)
                } else {
                    it.setFacing(CameraSource.CAMERA_FACING_FRONT)
                }
                binding.previewView.stop()
                startCameraSource()
            }
        }
        createCameraSource(selectedModel)
        startCameraSource()
        UnityProtocol.bindRespDelegate(delegateMessage)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (cameraSource != null) {
            cameraSource?.release()
        }
        UnityProtocol.unbindRespDelegate(delegateMessage)
    }

    private fun createCameraSource(model: String) {
        // If there's no existing cameraSource, create one.
        if (cameraSource == null) {
            cameraSource = CameraSource(this, binding.graphicOverlay)
            cameraSource?.setFacing(CameraSource.CAMERA_FACING_FRONT)
        }
        try {
            when (model) {
                POSE_DETECTION -> {
                    val poseDetectorOptions = PreferenceUtils.getPoseDetectorOptionsForLivePreview(this)
                    LogTool.d(TAG, "Using Pose Detector with options $poseDetectorOptions")
                    val shouldShowInFrameLikelihood =
                        PreferenceUtils.shouldShowPoseDetectionInFrameLikelihoodLivePreview(this)
                    val visualizeZ = PreferenceUtils.shouldPoseDetectionVisualizeZ(this)
                    val rescaleZ = PreferenceUtils.shouldPoseDetectionRescaleZForVisualization(this)
                    val runClassification = PreferenceUtils.shouldPoseDetectionRunClassification(this)
                    cameraSource!!.setMachineLearningFrameProcessor(
                        PoseDetectorProcessor(
                            this,
                            poseDetectorOptions,
                            shouldShowInFrameLikelihood,
                            visualizeZ,
                            rescaleZ,
                            runClassification,
                            /* isStreamMode = */ true
                        )
                    )
                }
                else -> LogTool.e(TAG, "Unknown model: $model")
            }
        } catch (e: Exception) {
            LogTool.e(TAG, "Can not create image processor: $model")
            Toast.makeText(
                applicationContext,
                "Can not create image processor: " + e.message,
                Toast.LENGTH_LONG
            )
                .show()
        }
    }

    private fun startCameraSource() {
        if (cameraSource != null) {
            try {
                binding.previewView.start(cameraSource, binding.graphicOverlay)
            } catch (e: IOException) {
                LogTool.e(TAG, "Unable to start camera source.")
                cameraSource?.release()
                cameraSource = null
            }
        }
    }

    public override fun onResume() {
        super.onResume()
        LogTool.d(TAG, "onResume")
        startCameraSource()
    }
}