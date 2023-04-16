//
//  main.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/4.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UnityAppDelegateTools.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    
    UnityAppDelegateTools.instance.argv = argv;
    UnityAppDelegateTools.instance.argc = argc;
    
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
