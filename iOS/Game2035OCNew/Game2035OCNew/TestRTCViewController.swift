//
//  TestRTCViewController.swift
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/18.
//

import UIKit
import AgoraRtcKit

class TestRTCViewController: UIViewController {
    
    var agoraKit: AgoraRtcEngineKit!
    @objc var roomId: String?
    
    private var testView: UIView = {
        let view = UIView()
        view.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height * 0.5)
        return view
    }()
    
    private var targetView: UIView = {
        let view = UIView()
        view.frame = CGRectMake(0, view.bounds.height * 0.5, view.bounds.width, view.bounds.height * 0.5)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        createEngine()
        joinChannel()
        setRemoteView(uid: 10019)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.agoraKit.leaveChannel()
    }
    
    func setRemoteView(uid: UInt){
//        view.addSubview(testView)
//        view.addSubview(targetView)
        
//        let cavas = AgoraRtcVideoCanvas()
//        cavas.uid = 12345
//        cavas.view = self.testView
//        cavas.renderMode = .fit
//        agoraKit.setupRemoteVideo(cavas)
//
        let cavas2 = AgoraRtcVideoCanvas()
        cavas2.uid = uid
        cavas2.view = self.view
        cavas2.renderMode = .hidden
        agoraKit.setupRemoteVideo(cavas2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        testView.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height * 0.5)
        targetView.frame = CGRectMake(0, view.bounds.height * 0.5, view.bounds.width, view.bounds.height * 0.5)
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
//        option.audienceLatencyLevel = .lowLatency
        
        let channelName = self.roomId ?? "113"
        let uid = UInt(AppContext.currentUserId ?? KeyCenter.RTM_UID)!
        print("uid == \(uid)")
        let ret = agoraKit.joinChannel(byToken: nil, channelId: channelName, uid: uid, mediaOptions: option)
        print("ret == \(ret)")
//        agoraKit.joinChannel(byToken: nil, channelId: channelName, info: nil, uid: 0)
//        agoraKit.joinChannel(byToken: nil, channelId: channelName, info: nil, uid: 0, options: option)
//        agoraKit.joinChannel(byToken: KeyCenter.RTCTOKEN, channelId: channelName, info: nil, uid: 0)
        
       
    }
    
    
    


}

extension TestRTCViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("didJoinChannel = \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("didJoinedOfUid = \(uid)")
        setRemoteView(uid: uid)
    }
}
