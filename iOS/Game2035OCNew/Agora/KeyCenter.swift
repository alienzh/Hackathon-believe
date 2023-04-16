//
//  KeyCenter.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import Foundation

class KeyCenter: NSObject {
    
    /**
     Agora APP ID.
     Agora assigns App IDs to app developers to identify projects and organizations.
     If you have multiple completely separate apps in your organization, for example built by different teams,
     you should use different App IDs.
     If applications need to communicate with each other, they should use the same App ID.
     In order to get the APP ID, you can open the agora console (https://console.agora.io/) to create a project,
     then the APP ID can be found in the project detail page.
     声网APP ID
     Agora 给应用程序开发人员分配 App ID，以识别项目和组织。如果组织中有多个完全分开的应用程序，例如由不同的团队构建，
     则应使用不同的 App ID。如果应用程序需要相互通信，则应使用同一个App ID。
     进入声网控制台(https://console.agora.io/)，创建一个项目，进入项目配置页，即可看到APP ID。
     */
    static let AppId: String = "84b3743250c24f5e81afb4bcb31e027e"
    
    static let RTCAPPID: String = "014ff505dba840cba44636acf8616601"
    
    static let RTCTOKEN: String = "007eJxTYGh/69bjtU52xhb/k7r/0qR2faxJb/6gsvLVKdaTSjPOpnYqMBgYmqSlmRqYpiQlWpgYJCclmpiYGZslJqdZmBmamRkYdveZpTQEMjL8vVPDzMgAgSA+M4OhoSEDAwCqYiA6"

    @objc static var RTM_UID: String {
        let key = "RTM_UID"
        var uid = UserDefaults.standard.integer(forKey: key)
        if uid == 0 {
            uid = Int(arc4random()) % 100000
            UserDefaults.standard.set(uid, forKey: key)
        }
        return "\(uid)"
    }
    
    // MARK: - 环信
//    @objc static let kEM_APPKEY = "1112220819129969#demo"
//    @objc static let kEM_APPKEY = "1129210531094378#metachat-us"
    @objc static let kEM_APPKEY = "1129210531094378#metachat"
    @objc static let kEM_UserName = RTM_UID
    @objc static let kEM_Password = "123456"
}
