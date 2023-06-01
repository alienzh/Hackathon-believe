/*
 * Copyright 2020 Google LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.agora.hack.believe.posedetector

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.google.mlkit.vision.common.PointF3D
import com.google.mlkit.vision.pose.Pose
import com.google.mlkit.vision.pose.PoseLandmark
import io.agora.hack.believe.common.GraphicOverlay
import io.agora.hack.believe.unity.UnityProtocol
import java.lang.Math.max
import java.lang.Math.min
import java.util.*

/** Draw the detected pose in preview. */
class PoseGraphic
internal constructor(
    private val overlay: GraphicOverlay,
    private val pose: Pose,
    private val showInFrameLikelihood: Boolean,
    private val visualizeZ: Boolean,
    private val rescaleZForVisualization: Boolean,
    private val poseClassification: List<String>
) : GraphicOverlay.Graphic(overlay) {
    private var zMin = java.lang.Float.MAX_VALUE
    private var zMax = java.lang.Float.MIN_VALUE
    private val classificationTextPaint: Paint
    private val leftPaint: Paint
    private val rightPaint: Paint
    private val whitePaint: Paint

    init {
        classificationTextPaint = Paint()
        classificationTextPaint.color = Color.WHITE
        classificationTextPaint.textSize = POSE_CLASSIFICATION_TEXT_SIZE
        classificationTextPaint.setShadowLayer(5.0f, 0f, 0f, Color.BLACK)

        whitePaint = Paint()
        whitePaint.strokeWidth = STROKE_WIDTH
        whitePaint.color = Color.WHITE
        whitePaint.textSize = IN_FRAME_LIKELIHOOD_TEXT_SIZE
        leftPaint = Paint()
        leftPaint.strokeWidth = STROKE_WIDTH
        leftPaint.color = Color.GREEN
        rightPaint = Paint()
        rightPaint.strokeWidth = STROKE_WIDTH
        rightPaint.color = Color.YELLOW
    }

    override fun draw(canvas: Canvas) {
        val landmarks = pose.allPoseLandmarks
        if (landmarks.isEmpty()) {
            return
        }

        // Draw pose classification text.
        val classificationX = POSE_CLASSIFICATION_TEXT_SIZE * 0.5f
        for (i in poseClassification.indices) {
            val classificationY =
                canvas.height -
                        (POSE_CLASSIFICATION_TEXT_SIZE * 1.5f * (poseClassification.size - i).toFloat())
            canvas.drawText(
                poseClassification[i],
                classificationX,
                classificationY,
                classificationTextPaint
            )
        }

        // Draw all the points
        for (landmark in landmarks) {
//            drawPoint(canvas, landmark, whitePaint)
            if (visualizeZ && rescaleZForVisualization) {
                zMin = min(zMin, landmark.position3D.z)
                zMax = max(zMax, landmark.position3D.z)
            }
        }

        val nose = pose.getPoseLandmark(PoseLandmark.NOSE)
        val leftEyeInner = pose.getPoseLandmark(PoseLandmark.LEFT_EYE_INNER)
        val leftEye = pose.getPoseLandmark(PoseLandmark.LEFT_EYE)
        val leftEyeOuter = pose.getPoseLandmark(PoseLandmark.LEFT_EYE_OUTER)
        val rightEyeInner = pose.getPoseLandmark(PoseLandmark.RIGHT_EYE_INNER)
        val rightEye = pose.getPoseLandmark(PoseLandmark.RIGHT_EYE)
        val rightEyeOuter = pose.getPoseLandmark(PoseLandmark.RIGHT_EYE_OUTER)
        val leftEar = pose.getPoseLandmark(PoseLandmark.LEFT_EAR)
        val rightEar = pose.getPoseLandmark(PoseLandmark.RIGHT_EAR)
        val leftMouth = pose.getPoseLandmark(PoseLandmark.LEFT_MOUTH)
        val rightMouth = pose.getPoseLandmark(PoseLandmark.RIGHT_MOUTH)

        val leftShoulder = pose.getPoseLandmark(PoseLandmark.LEFT_SHOULDER)
        val rightShoulder = pose.getPoseLandmark(PoseLandmark.RIGHT_SHOULDER)
        val leftElbow = pose.getPoseLandmark(PoseLandmark.LEFT_ELBOW)
        val rightElbow = pose.getPoseLandmark(PoseLandmark.RIGHT_ELBOW)
        val leftWrist = pose.getPoseLandmark(PoseLandmark.LEFT_WRIST)
        val rightWrist = pose.getPoseLandmark(PoseLandmark.RIGHT_WRIST)
        val leftHip = pose.getPoseLandmark(PoseLandmark.LEFT_HIP)
        val rightHip = pose.getPoseLandmark(PoseLandmark.RIGHT_HIP)
        val leftKnee = pose.getPoseLandmark(PoseLandmark.LEFT_KNEE)
        val rightKnee = pose.getPoseLandmark(PoseLandmark.RIGHT_KNEE)
        val leftAnkle = pose.getPoseLandmark(PoseLandmark.LEFT_ANKLE)
        val rightAnkle = pose.getPoseLandmark(PoseLandmark.RIGHT_ANKLE)

        val leftPinky = pose.getPoseLandmark(PoseLandmark.LEFT_PINKY)
        val rightPinky = pose.getPoseLandmark(PoseLandmark.RIGHT_PINKY)
        val leftIndex = pose.getPoseLandmark(PoseLandmark.LEFT_INDEX)
        val rightIndex = pose.getPoseLandmark(PoseLandmark.RIGHT_INDEX)
        val leftThumb = pose.getPoseLandmark(PoseLandmark.LEFT_THUMB)
        val rightThumb = pose.getPoseLandmark(PoseLandmark.RIGHT_THUMB)
        val leftHeel = pose.getPoseLandmark(PoseLandmark.LEFT_HEEL)
        val rightHeel = pose.getPoseLandmark(PoseLandmark.RIGHT_HEEL)
        val leftFootIndex = pose.getPoseLandmark(PoseLandmark.LEFT_FOOT_INDEX)
        val rightFootIndex = pose.getPoseLandmark(PoseLandmark.RIGHT_FOOT_INDEX)

        val poseMap = mutableMapOf<Int, PointF3D>().apply {
            nose?.let { put(PoseLandmark.NOSE, it.position3D) } // 0
            leftEyeInner?.let { put(PoseLandmark.LEFT_EYE_INNER, it.position3D) } // 1
            leftEye?.let { put(PoseLandmark.LEFT_EYE, it.position3D) } // 2
            leftEyeOuter?.let { put(PoseLandmark.LEFT_EYE_OUTER, it.position3D) } // 3
            rightEyeInner?.let { put(PoseLandmark.RIGHT_EYE_INNER, it.position3D) } // 4
            rightEye?.let { put(PoseLandmark.RIGHT_EYE, it.position3D) } // 5
            rightEyeOuter?.let { put(PoseLandmark.RIGHT_EYE_OUTER, it.position3D) } // 6
            leftEar?.let { put(PoseLandmark.LEFT_EAR, it.position3D) } // 7
            rightEar?.let { put(PoseLandmark.RIGHT_EAR, it.position3D) } // 8
            leftMouth?.let { put(PoseLandmark.LEFT_MOUTH, it.position3D) } // 9
            rightMouth?.let { put(PoseLandmark.RIGHT_MOUTH, it.position3D) } // 10

            leftShoulder?.let { put(PoseLandmark.LEFT_SHOULDER , it.position3D) } //11
            rightShoulder?.let { put(PoseLandmark.RIGHT_SHOULDER, it.position3D) } //12
            leftElbow?.let { put(PoseLandmark.LEFT_ELBOW, it.position3D) } //13
            rightElbow?.let { put(PoseLandmark.RIGHT_ELBOW , it.position3D) } //14
            leftWrist?.let { put(PoseLandmark.LEFT_WRIST, it.position3D) } //15
            rightWrist?.let { put(PoseLandmark.RIGHT_WRIST , it.position3D) } //16
            leftPinky?.let { put(PoseLandmark.LEFT_PINKY , it.position3D) } //17
            rightPinky?.let { put(PoseLandmark.RIGHT_PINKY , it.position3D) } //18
            leftIndex?.let { put(PoseLandmark.LEFT_INDEX , it.position3D) } //19
            rightIndex?.let { put(PoseLandmark.RIGHT_INDEX , it.position3D) } //20
            leftThumb?.let { put(PoseLandmark.LEFT_THUMB , it.position3D) } //21
            rightThumb?.let { put(PoseLandmark.RIGHT_THUMB , it.position3D) } //22
            leftHip?.let { put(PoseLandmark.LEFT_HIP, it.position3D) } //23
            rightHip?.let { put(PoseLandmark.RIGHT_HIP , it.position3D) }  //24
            leftKnee?.let { put(PoseLandmark.LEFT_KNEE, it.position3D) } //25
            rightKnee?.let { put(PoseLandmark.RIGHT_KNEE , it.position3D) } //26
            leftAnkle?.let { put(PoseLandmark.LEFT_ANKLE, it.position3D) } //27
            rightAnkle?.let { put(PoseLandmark.RIGHT_ANKLE, it.position3D) } //28
            leftHeel?.let { put(PoseLandmark.LEFT_HEEL, it.position3D) } //29
            rightHeel?.let { put(PoseLandmark.RIGHT_HEEL, it.position3D) } //30
            leftFootIndex?.let { put(PoseLandmark.LEFT_FOOT_INDEX, it.position3D) } //31
            rightFootIndex?.let { put(PoseLandmark.RIGHT_FOOT_INDEX, it.position3D) } //32
        }

//        UnityProtocol.sendPosition3DToUdp(poseMap)
        UnityProtocol.sendPosition3DToUnity(poseMap)

        // Face
//        drawLine(canvas, nose, leftEyeInner, whitePaint)
//        drawLine(canvas, leftEyeInner, leftEye, whitePaint)
//        drawLine(canvas, leftEye, leftEyeOuter, whitePaint)
//        drawLine(canvas, leftEyeOuter, leftEar, whitePaint)
//        drawLine(canvas, nose, rightEyeInner, whitePaint)
//        drawLine(canvas, rightEyeInner, rightEye, whitePaint)
//        drawLine(canvas, rightEye, rightEyeOuter, whitePaint)
//        drawLine(canvas, rightEyeOuter, rightEar, whitePaint)
//        drawLine(canvas, leftMouth, rightMouth, whitePaint)
//
//        drawLine(canvas, leftShoulder, rightShoulder, whitePaint)
//        drawLine(canvas, leftHip, rightHip, whitePaint)
//
//        // Left body
//        drawLine(canvas, leftShoulder, leftElbow, leftPaint)
//        drawLine(canvas, leftElbow, leftWrist, leftPaint)
//        drawLine(canvas, leftShoulder, leftHip, leftPaint)
//        drawLine(canvas, leftHip, leftKnee, leftPaint)
//        drawLine(canvas, leftKnee, leftAnkle, leftPaint)
//        drawLine(canvas, leftWrist, leftThumb, leftPaint)
//        drawLine(canvas, leftWrist, leftPinky, leftPaint)
//        drawLine(canvas, leftWrist, leftIndex, leftPaint)
//        drawLine(canvas, leftIndex, leftPinky, leftPaint)
//        drawLine(canvas, leftAnkle, leftHeel, leftPaint)
//        drawLine(canvas, leftHeel, leftFootIndex, leftPaint)

//        // Right body
//        drawLine(canvas, rightShoulder, rightElbow, rightPaint)
//        drawLine(canvas, rightElbow, rightWrist, rightPaint)
//        drawLine(canvas, rightShoulder, rightHip, rightPaint)
//        drawLine(canvas, rightHip, rightKnee, rightPaint)
//        drawLine(canvas, rightKnee, rightAnkle, rightPaint)
//        drawLine(canvas, rightWrist, rightThumb, rightPaint)
//        drawLine(canvas, rightWrist, rightPinky, rightPaint)
//        drawLine(canvas, rightWrist, rightIndex, rightPaint)
//        drawLine(canvas, rightIndex, rightPinky, rightPaint)
//        drawLine(canvas, rightAnkle, rightHeel, rightPaint)
//        drawLine(canvas, rightHeel, rightFootIndex, rightPaint)

        // Draw inFrameLikelihood for all points
       if (showInFrameLikelihood) {
            for (landmark in landmarks) {
                canvas.drawText(
                    String.format(Locale.US, "%.2f", landmark.inFrameLikelihood),
                    translateX(landmark.position.x),
                    translateY(landmark.position.y),
                    whitePaint
                )
            }
        }
    }

    internal fun drawPoint(canvas: Canvas, landmark: PoseLandmark, paint: Paint) {
        val point = landmark.position3D
        updatePaintColorByZValue(
            paint,
            canvas,
            visualizeZ,
            rescaleZForVisualization,
            point.z,
            zMin,
            zMax
        )
        canvas.drawCircle(translateX(point.x), translateY(point.y), DOT_RADIUS, paint)
    }

    internal fun drawLine(
        canvas: Canvas,
        startLandmark: PoseLandmark?,
        endLandmark: PoseLandmark?,
        paint: Paint
    ) {
        val start = startLandmark!!.position3D
        val end = endLandmark!!.position3D

        // Gets average z for the current body line
        val avgZInImagePixel = (start.z + end.z) / 2
        updatePaintColorByZValue(
            paint,
            canvas,
            visualizeZ,
            rescaleZForVisualization,
            avgZInImagePixel,
            zMin,
            zMax
        )

        canvas.drawLine(
            translateX(start.x),
            translateY(start.y),
            translateX(end.x),
            translateY(end.y),
            paint
        )
    }

    companion object {

        private val DOT_RADIUS = 8.0f
        private val IN_FRAME_LIKELIHOOD_TEXT_SIZE = 30.0f
        private val STROKE_WIDTH = 10.0f
        private val POSE_CLASSIFICATION_TEXT_SIZE = 60.0f
    }
}
