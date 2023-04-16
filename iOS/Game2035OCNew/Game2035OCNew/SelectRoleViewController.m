//
//  ViewController.m
//  Game2035OC
//
//  Created by FanPengpeng on 2023/2/25.
//

#import "SelectRoleViewController.h"
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

@interface SelectRoleViewController () <NativeCallsProtocol>

@end

@implementation SelectRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RtmManager shared] login:nil];
    
    [[FrameworkLibAPI sharedInstance] registerAPIForNativeCalls:self];
}

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

- (IBAction)didClickPlayerButton:(id)sender {
//    TestRTCViewController *vc = [TestRTCViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
//    return;
    [self showUnityVCWithRole:GameRolePlayer];
}

- (IBAction)didClickAudienceButton:(id)sender {
    [self showUnityVCWithRole:GameRoleAudience];
}

- (IBAction)didClickCameraButton:(id)sender {
    [self showCameraVC];
}

- (void)showUnityVCWithRole:(GameRole)role {
    if(UnityAppInstance.instance.unityAppController) {
        [self postUnityActiveNotificationWithRole:role];
    }else {
        [UnityAppInstance.instance initUnityWithFrame: self.view.bounds withOptions:@{kGameRole: @(role), kRoomId : self.roomId}];
    }
    [[RtmManager shared] subscribeChannel:self.roomId receiveMsg:^(NSString * _Nonnull msg) {
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:msg];
    }];
}


- (void)showCameraVC {
    __weak typeof(self) weakSelf = self;
    [[RtmManager shared] subscribeChannel:self.roomId receiveMsg:^(NSString * _Nonnull msg) {
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:msg];
    }];
    CameraViewController *poseVC = [CameraViewController new];
    poseVC.roomId = self.roomId;
    poseVC.isFullScreen = YES;
    poseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [poseVC setPosesCallback:^(NSArray<MLKPose *> * _Nonnull poses, UIImageOrientation orientation) {
        NSString *jsonStr = [MLKPose unityJsonStringWithPoses:poses uid:AppContext.currentUserId orientation:orientation];
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:jsonStr];
        [[RtmManager shared] sendJsonMessage:jsonStr channel:weakSelf.roomId];
    }];
    [poseVC setCameraOffCallback:^{
        [[RtmManager shared] unsubscribleChannel:weakSelf.roomId];
    }];
    [self presentViewController:poseVC animated: YES completion: nil];
}

- (void)postUnityActiveNotificationWithRole:(GameRole)role{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnityBecomeActiveNotification object:nil userInfo:@{kGameRole: @(role), kRoomId : self.roomId}];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
