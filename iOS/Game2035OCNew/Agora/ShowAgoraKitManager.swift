//
//  ShowAgoraKitManager.swift
//  AgoraEntScenarios
//
//  Created by FanPengpeng on 2022/11/22.
//

import Foundation
import AgoraRtcKit
import UIKit

class ShowAgoraKitManager: NSObject {
    
    let videoEncoderConfig = AgoraVideoEncoderConfiguration()
    let captureConfig = AgoraCameraCapturerConfiguration()
    
    var videoTrackId: UInt?
    
    private var joinSuccess:((_ uid: UInt)->())?
    
    // 是否开启绿幕功能
    private lazy var rtcEngineConfig: AgoraRtcEngineConfig = {
       let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.channelProfile = .liveBroadcasting
        config.areaCode = .global
        return config
    }()
    
    fileprivate(set) lazy var agoraKit: AgoraRtcEngineKit = {
        let kit = AgoraRtcEngineKit.sharedEngine(with: rtcEngineConfig, delegate: self)
        let info = AgoraExtensionInfo()
        info.sourceType = .customVideo
        kit.enableExtension(withVendor: "agora_video_filters_segmentation", extension: "portrait_segmentation", extensionInfo: info, enabled: true)
        return kit
    }()
    
    deinit {
//        AgoraRtcEngineKit.destroy()
        print("deinit-- ShowAgoraKitManager")
    }
    
    override init() {
        super.init()
        print("init-- ShowAgoraKitManager")
    }
    
    @objc func pushExternalVideoFrame(_ vf: AgoraVideoFrame) {
//        agoraKit.pushExternalVideoFrame(vf, videoTrackId: UInt(videoTrackId!))
        let ret = agoraKit.pushExternalVideoFrame(vf)
    }
    
    @objc func setVideoFrameDelegate(_ delegate: AgoraVideoFrameDelegate) {
        agoraKit.setVideoFrameDelegate(delegate)
    }
    
    /// 开启虚化背景
    @objc func enableVirtualBackground(isOn: Bool) {
        let source = AgoraVirtualBackgroundSource()
        source.backgroundSourceType = .blur
        source.blurDegree = .high
//        let ret = agoraKit.enableVirtualBackground(isOn, backData: source, segData: nil)
        agoraKit.setExtensionPropertyWithVendor("agora_video_filters_segmentation", extension: "portrait_segmentation", key: "configs", value: "{\"enable_seg\":true,\"enable_back_replace\":true, \"back_replace_params\":{\"type\":1,\"color\":12345345},\"green_params\":{\"model_type\":2,\"green_capacity\":0.5} }", sourceType: .customVideo)
        
//        背景图source
//
    }

    @objc func cleanCapture() {
        agoraKit.stopPreview()
        agoraKit.setVideoFrameDelegate(nil)
    }
    
    @objc func setExternalVideoSource(){
        agoraKit.setClientRole(.broadcaster)
        agoraKit.enableVideo()
        agoraKit.setExternalVideoSource(true, useTexture: false, sourceType: .videoFrame)
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
    }
    
    @objc func joinChannel(_ channel: String, successBlock:((_ uid: UInt)->())?) {
        joinSuccess = successBlock
        let options = AgoraRtcChannelMediaOptions()
        options.publishCustomAudioTrack = false
        options.publishCameraTrack = false
        options.publishCustomVideoTrack = true

        let ret = agoraKit.joinChannel(byToken: nil, channelId: channel, uid: UInt(KeyCenter.RTM_UID)!, mediaOptions: AgoraRtcChannelMediaOptions())
        DLog("ret = \(ret)")
        
        enableVirtualBackground(isOn: true)

//        videoTrackId = UInt(agoraKit.createCustomVideoTrack())
//        let options = AgoraRtcChannelMediaOptions()
//        options.publishCustomVideoTrack = true
//        options.publishCameraTrack = false
//        options.customVideoTrackId = Int(videoTrackId!)
//
//        let connection = AgoraRtcConnection()
//
//        agoraKit.joinChannelEx(byToken: nil, connection: connection, delegate: nil, mediaOptions: options)
    }
    
    @objc func leaveChannel() {
//        agoraKit.destroyCustomVideoTrack(videoTrackId!)
        agoraKit.leaveChannel()
    }
    
    @objc func setupRemoteVideo(uid: UInt, canvasView: UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = canvasView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }

}


extension ShowAgoraKitManager: AgoraRtcEngineDelegate{
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        joinSuccess?(uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
//        showLogger.info("rtcEngine didJoinedOfUid \(uid) channelId: \(roomId)", context: kShowLogBaseContext)
        joinSuccess?(uid)
    }
}
