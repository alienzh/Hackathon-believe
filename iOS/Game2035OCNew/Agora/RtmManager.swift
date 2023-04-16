//
//  RtmManager.swift
//  Game2035OC
//
//  Created by FanPengpeng on 2023/3/1.
//

import UIKit
import AgoraRtcKit
import MJExtension
import CommonCrypto




class RtmManager: NSObject {
    
    @objc static let shared = RtmManager()
    
    private var receiveMsgCallbackMap = [String: RTMMessageCallback]()
    
    private var isLogin = false
    
    private lazy var rtmClient: AgoraRtmClientKit? = {
        clientConfig.appId = KeyCenter.AppId
        clientConfig.userId = AppContext.currentUserId!
        let rtmClient = AgoraRtmClientKit(config: clientConfig, delegate: self)
        return rtmClient
    }()
    private let clientConfig = AgoraRtmClientConfig()
    
    deinit {
        rtmClient?.destroy()
        DLog("deinit-- RtmManager")
    }
    
    override init() {
        super.init()
        DLog("init-- RtmManager")
    }
    
    @objc func login(_ completion:(()->())?){
        if isLogin {
            completion?()
            return
        }
        rtmClient?.login(byToken: nil, completion: { [weak self] response, err in
            self?.isLogin = true
            DLog("rtm log err = \(err.reason), operation: \(err.operation), errcode : \(err.errorCode.rawValue)")
            completion?()
        })
    }
    
    @objc func subscribeChannel(_ channel: String, receiveMsg:RTMMessageCallback?) {
        func realSubscribe(){
            DLog("rtmClient === \(rtmClient)")
            let ret = rtmClient?.subscribe(withChannel: channel, option: nil)
            if ret == 0 {
                self.receiveMsgCallbackMap[channel] = receiveMsg
                DLog(" subscribleChannel 成功 channel = \(channel)")
            }else{
                DLog(" subscribleChannel 失败: ret = \(ret!) channel = \(channel)")
            }
        }
        if isLogin {
            realSubscribe()
        }else{
            login {
                realSubscribe()
            }
        }
    }
    
    @objc func unsubscribleChannel(_ channel: String) {
        let ret = rtmClient?.unsubscribe(withChannel: channel)
        if ret == 0 {
            DLog(" unsubscribleChannel 成功 channel = \(channel)")
        }else{
            DLog(" unsubscribleChannel 失败: ret = \(ret!) channel = \(channel)")
            
        }
    }
    
    @objc func sendJsonMessage(_ jsonStr: String, channel: String) {
        func realSend(){
            print("jsonStr.count- === \(jsonStr.count)")
//            guard let data = jsonStr.data(using: .utf8) else { return }
            if let ret = rtmClient?.publish(channel, message: jsonStr, withOption: nil) {
                DLog("sendMessage \(jsonStr) ret = \(ret)")
            }
        }
        
        func realSend2(){
            let chunks = jsonStr.subString(800)
            let msgId = jsonStr.md5
            for (i,str) in chunks.enumerated() {
                var dic = [String: Any]()
                dic["msgId"] = msgId
                dic["index"] = i
                dic["content"] = str
                guard let json = (dic as NSDictionary).mj_JSONString() else { return }
                if let ret = rtmClient?.publish(channel, message: json, withOption: nil) {
                    DLog("sendMessage \(json) ret = \(ret)")
                }
            }
        }
        if isLogin {
            realSend()
        }else{
            login {
                realSend()
            }
        }
    }
    
}

extension String {
    func subString(_ length: Int = 1024) -> [String] {
        var chunks = [String]()

        var index = self.startIndex

        while index < self.endIndex {

            let chunkEndIndex = self.index(index, offsetBy: length, limitedBy: endIndex) ?? endIndex

            let chunk = String(self[index..<chunkEndIndex])

            chunks.append(chunk)

            index = chunkEndIndex
        }

        return chunks
    }
    
    var md5: String {
            let data = Data(utf8)
            let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
                var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
                CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
                return hash
            }
            return hash.map { String(format: "%02x", $0) }.joined()
        }
}


extension RtmManager: AgoraRtmClientDelegate {
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, on event: AgoraRtmMessageEvent) {
        if let msg = event.message as? String {
            DLog("rtmKit event  = \(event), message = \(msg)")
            if let callback = receiveMsgCallbackMap[event.channelName] {
                callback(msg)
            }
        }else {
            DLog("rtmKit event  = \(event), message is empty")
        }
    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, on event: AgoraRtmLockEvent) {
        DLog("rtmKit event = \(event)")

    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, on event: AgoraRtmPresenceEvent) {
        DLog("rtmKit event = \(event)")

    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, on event: AgoraRtmStorageEvent) {
        DLog("rtmKit event = \(event)")

    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, onTokenPrivilegeWillExpire channel: String?) {
        DLog("rtmKit channel  = \(String(describing: channel?.debugDescription))")

    }
    
    func rtmKit(_ kit: AgoraRtmClientKit, channel channelName: String, connectionStateChanged state: AgoraRtmClientConnectionState, result reason: AgoraRtmClientConnectionChangeReason) {
        DLog("rtmKit channel = \(channelName) state = \(state) reason = \(reason.rawValue)")

    }
    
    func rtmKit(_ rtmKit: AgoraRtmClientKit, on event: AgoraRtmTopicEvent) {
        DLog("on event AgoraRtmMessageEvent = \(event)")
    }
}

extension RtmManager {
    typealias RTMMessageCallback  = ((_ jsonMsg: String)->())
}
