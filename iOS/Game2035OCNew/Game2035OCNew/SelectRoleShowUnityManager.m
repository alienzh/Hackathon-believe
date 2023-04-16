//
//  SelectRoleShowUnityManager.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/4/15.
//

#import "SelectRoleShowUnityManager.h"
#import "UnityAppInstance.h"
//#import "UnityVC.h"
#import <UnityFramework/UnityFramework.h>
#import <UnityFramework/NativeCallProxy.h>
#import "CameraViewController.h"
#import "MJExtension.h"
#import "MLKPose+Extension.h"
#import "Game2035OCNew-swift.h"
//#import "GBUnityViewController.h"
#import "PublicHeaders.h"

@interface SelectRoleShowUnityManager() <NativeCallsProtocol>

@end

@implementation SelectRoleShowUnityManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initalizeRTM];
    }
    return self;
}

- (void)initalizeRTM {
    [[RtmManager shared] login:nil];
    
    [[FrameworkLibAPI sharedInstance] registerAPIForNativeCalls:self];
}

- (void)showUnityVCWithRole:(GameRole)role {
    if(UnityAppInstance.instance.unityAppController) {
        [self postUnityActiveNotificationWithRole:role];
    }else {
        [UnityAppInstance.instance initUnityWithFrame: UIScreen.mainScreen.bounds withOptions:@{kGameRole: @(role), kRoomId : self.roomId, kSceneId:@(self.sceneId)}];
    }
    [[RtmManager shared]  subscribeChannel:self.roomId receiveMsg:^(NSString * _Nonnull msg) {
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:msg];
        DLog("receive =====  %@",msg);
    }];
}

- (void)postUnityActiveNotificationWithRole:(GameRole)role{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnityBecomeActiveNotification object:nil userInfo:@{kGameRole: @(role), kRoomId : self.roomId,kSceneId:@(self.sceneId)}];
}

- (void)showUnityVC {
    [self showUnityVCWithRole:GameRolePlayer];
}


#pragma mark - NativeCallsProtocol

- (void)onReceiveMessage:(NSString *)key message:(NSString *)message {
    if ([key isEqualToString:@"unityLoadFinish"]) {
//        NSString *msg = [NSString stringWithFormat:@"\"sceneId\":%zd",1];
        NSDictionary *dic = @{@"sceneId" : @(self.sceneId)};
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"loadScene" message: [dic mj_JSONString]];
    }
    DLog("key = %@ ,message = %@",key,message);
}

- (void)onErrorMessage:(NSString *)message {
    DLog("message = %@",message);
}





@end
