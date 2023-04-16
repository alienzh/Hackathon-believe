//
//  RTCManager.swift
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/4/15.
//

import UIKit
import AgoraRtcKit

class RTCManager: NSObject {
    
    private var agoraKit: AgoraRtcEngineKit!
    @objc var roomId: String?
    @objc var view: UIView!
    
    private var joinedSucceed: (()->())?


    func setRemoteView(_ view: UIView, uid: UInt){
        let cavas = AgoraRtcVideoCanvas()
        cavas.uid = uid
        cavas.view = view
        cavas.renderMode = .hidden
        agoraKit.setupRemoteVideo(cavas)
    }
    
    func createEngine(){
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = .global
        
        let agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        self.agoraKit = agoraKit
        // get channel name from configs
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.enableVideo()
    }

    func joinChannel() {
        let option = AgoraRtcChannelMediaOptions()
        option.autoSubscribeAudio = true
        option.autoSubscribeVideo = true
        
        let channelName = self.roomId ?? "113"
        let uid = UInt(AppContext.currentUserId ?? KeyCenter.RTM_UID)!
        print("uid == \(uid)")
        let ret = agoraKit.joinChannel(byToken: nil, channelId: channelName, uid: uid, mediaOptions: option)
        print("ret == \(ret)")
    }
    
    

}

extension RTCManager {
    
    @objc func join(success: (()->())?){
        joinedSucceed = success
        createEngine()
        joinChannel()
        setRemoteView(view, uid: 10019)
    }
    
    @objc func leave(){
        self.agoraKit.leaveChannel()
    }
}


extension RTCManager: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("didJoinChannel = \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("didJoinedOfUid = \(uid)")
        setRemoteView(view, uid: uid)
        joinedSucceed?()
    }
}
