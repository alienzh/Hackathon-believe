//
//  GBUnityAppController.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/6.
//

#import "GBUnityAppController.h"
#import "CameraViewController.h"
#import <UnityFramework/NativeCallProxy.h>
#import "CameraViewController.h"
#import "MLKPose+Extension.h"
#import "Game2035OCNew-swift.h"
#import "Masonry.h"
#import "UnityAppInstance.h"
#import "SubUnityViewController.h"
#import "PublicHeaders.h"
#import "UIViewController+Extension.h"

//IMPL_APP_CONTROLLER_SUBCLASS(GBUnityAppController)

@interface GBUnityAppController()

@property(weak, nonatomic) CameraViewController *poseVC;
@property(strong, nonatomic) NSDictionary *launchOptions;
@property(copy, nonatomic) NSString *currentRoomId;
@property(strong, nonatomic) UIView *remoteView;
@property(strong, nonatomic) ShowAgoraKitManager *agoraKitManager;
@property(weak, nonatomic)  TestRTCViewController *retmoteVc;

@property(strong, nonatomic) RTCManager *manager;

@end

@implementation GBUnityAppController

- (void)preStartUnity {
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [offButton setTitle:@"关闭" forState:UIControlStateNormal];
    [offButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.rootView addSubview:offButton];
    [offButton addTarget:self action:@selector(didClickOffButton) forControlEvents:UIControlEventTouchUpInside];
    [offButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
}

- (void)startUnity:(UIApplication *)application {
    [super startUnity:application];
    [self configUIWithOptions:self.launchOptions];
}

- (void)didClickOffButton {
    [self removeCameraVC];
    [self removeRemoteRoleView];
    
    [UnityAppInstance.instance pause:YES];
    [self.window resignKeyWindow];
    self.window.hidden = YES;
    [[UIApplication sharedApplication].windows.firstObject makeKeyAndVisible];
    [RtmManager.shared unsubscribleChannel:self.currentRoomId];
    
    [self.remoteView removeFromSuperview];
    [self.agoraKitManager leaveChannel];
    
}

static int sceneId = 1;

- (void)didClickChangeButton {
    sceneId = sceneId == 1 ? 2 : 1;
    [self switchToSceneId:sceneId];
}

- (void)switchToSceneId:(NSInteger)sceneId {
    NSString *msg = [NSString stringWithFormat:@"\"sceneId\":%zd",sceneId];
    [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"loadScene" message: msg];
    DLog("send msg = %@",msg);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    self.launchOptions = launchOptions;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unityBecomeActive:) name:kUnityBecomeActiveNotification object:nil];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)unityBecomeActive:(NSNotification *)notify {
    self.window.hidden = NO;
    [self.window makeKeyAndVisible];
    [UnityAppInstance.instance pause:NO];
    
    [self configUIWithOptions:notify.userInfo];
}

- (void)configUIWithOptions:(NSDictionary *)options {
    GameRole role = [options[kGameRole] integerValue];
    NSString *roomId = options[kRoomId];
    NSNumber *sceneId = options[kSceneId];
    self.currentRoomId = roomId;
    if (roomId.length > 0) {
        if (role == GameRolePlayer){
            [self showCameraVCWithRoomId:roomId];
            if(sceneId.integerValue == 1) {
                [self showRemoteViewWithRoomId2:roomId];
            }
        }else{
            [self showRemoteViewWithRoomId2:roomId];
        }
    }
}

- (void)showCameraVCWithRoomId:(NSString *)roomId {
    CameraViewController *poseVC = [CameraViewController new];
    poseVC.roomId = roomId;
    self.poseVC = poseVC;
    [self.rootViewController addChildViewController:poseVC];
    [self.rootView addSubview:poseVC.view];
    [poseVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.rootView);
        make.width.mas_equalTo(kCameraWidth);
        make.height.mas_equalTo(kCameraHeight);
    }];
    
    [poseVC setPosesCallback:^(NSArray<MLKPose *> * _Nonnull poses, UIImageOrientation orientation) {
        NSString *jsonStr = [MLKPose unityJsonStringWithPoses:poses uid:[AppContext currentUserId] orientation:orientation];
        [[RtmManager shared] sendJsonMessage:jsonStr channel:roomId];
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:jsonStr];
    }];
}

- (void)removeCameraVC {
    [self.poseVC.view removeFromSuperview];
    [self.poseVC removeFromParentViewController];
}

- (void)showRemoteViewWithRoomId:(NSString *)roomId {
    TestRTCViewController *vc = [TestRTCViewController new];
    vc.roomId = roomId;
    self.retmoteVc = vc;
    //    [self.rootViewController addChildViewController:vc];
    //    vc.roomId = roomId;
    //    self.retmoteVc = vc;
    //    [self.rootView addSubview:vc.view];
    //    vc.view.frame = CGRectMake(SCREEN_WIDTH - kCameraHeight - 80, 20, kCameraHeight, kCameraWidth);
    
    
    [self.rootViewController addChildViewController:vc];
    [self.rootView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rootView).offset(20);
        make.right.mas_equalTo(-80);
        make.width.mas_equalTo(kCameraHeight);
        make.height.mas_equalTo(kCameraWidth);
    }];
}


- (void)showRemoteViewWithRoomId2:(NSString *)roomId {
    RTCManager *manager = [RTCManager new];
    manager.view = [UIView new];
    manager.roomId = roomId;
    __weak GBUnityAppController *wSelf = self;
    [manager joinWithSuccess:^{
        [wSelf.rootView addSubview:manager.view];
        [manager.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(wSelf.rootView).offset(20);
            make.right.mas_equalTo(-80);
            make.width.mas_equalTo(kCameraHeight);
            make.height.mas_equalTo(kCameraWidth);
        }];
    }];
    self.manager = manager;
}

- (void)removeRemoteRoleView{
    [self.manager.view removeFromSuperview];
    [self.manager leave];
}


@end
