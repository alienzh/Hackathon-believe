//
//  UnityAppDelegateTools.m
//  NativeIOSProject
//
//  Created by li jia on 2022/11/4.
//

#import "UnityAppDelegateTools.h"

@implementation UnityAppDelegateTools

+ (instancetype)instance {
    static dispatch_once_t once;
    static UnityAppDelegateTools *_instance;
    dispatch_once(&once, ^{
        _instance = [UnityAppDelegateTools new];
    });
    return _instance;
}

@end
