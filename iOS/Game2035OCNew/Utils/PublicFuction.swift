//
//  PublicFuction.swift
//  Game2035OC
//
//  Created by FanPengpeng on 2023/3/1.
//

import Foundation

func DLog(_ message: Any..., file: String = #file, function: String = #function, lineNumber: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    print("[文件:\(fileName)] [函数:\(function)] [行:\(lineNumber)] \(message)")
}
