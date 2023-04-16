//
//  AppContext.swift
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/8.
//

import UIKit

private let kIsLogin = "kIsLogin"
private let kCurrentUserId = "kCurrentUserId"
class AppContext: NSObject {
    @objc static var isLogin: Bool {
       return currentUserId != nil
    }
    
    @objc static var currentUserId: String? {
        set{
            let value = String(newValue!.suffix(7))
            DLog("currentUserId === \(value)")
            UserDefaults.standard.set(value, forKey: kCurrentUserId)
        }
        
        get{
            UserDefaults.standard.string(forKey: kCurrentUserId)
        }
    }
    
    
    
    
}
