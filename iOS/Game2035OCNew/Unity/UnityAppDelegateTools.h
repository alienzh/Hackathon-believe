//
//  UnityAppDelegateTools.h
//  NativeIOSProject
//
//  Created by li jia on 2022/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityAppDelegateTools : NSObject

+ (instancetype)instance;
@property (strong, nonatomic) NSDictionary *launchOptions;
@property (assign, nonatomic) int argc;
@property (assign, nonatomic) char * _Nonnull * _Nullable argv;

@end

NS_ASSUME_NONNULL_END
