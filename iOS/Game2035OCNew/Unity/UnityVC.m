//
//  UnityVC.m
//  NativeIOSProject
//
//  Created by li jia on 2022/11/4.
//

#import "UnityVC.h"
#import "UnityAppInstance.h"
#import <UnityFramework/UnityFramework.h>
#import <UnityFramework/NativeCallProxy.h>
#import "CameraViewController.h"
#import "MLKPose+Extension.h"
#import "Game2035OCNew-swift.h"

@import MLImage;
@import MLKit;

@interface UnityVC () <RenderPluginDelegate>

@property (nonatomic, assign) BOOL isFirstFrame;

@end

@implementation UnityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstFrame = true;
    
    [UnityAppInstance.instance initUnityWithFrame: self.view.bounds withOptions:nil];
    [UnityAppInstance.instance unityAppController].renderDelegate = self;
}

- (void)testSetupUI {
    UIViewController *unityVC = [UnityAppInstance instance].unityAppController.window.rootViewController;
    UIView *view = [UnityAppInstance instance].unityAppController.rootView;
    CameraViewController *poseVC = [CameraViewController new];
    [unityVC addChildViewController:poseVC];

    [poseVC setPosesCallback:^(NSArray<MLKPose *> * _Nonnull poses, UIImageOrientation orientation) {
        NSString *jsonStr = [MLKPose unityJsonStringWithPoses:poses uid:AppContext.currentUserId orientation:orientation];
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:jsonStr];
    }];
    __weak CameraViewController *vc = poseVC;
    __weak typeof(self) wSelf = self;
    [poseVC setCameraOffCallback:^{
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [wSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [view addSubview:poseVC.view];
    poseVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    [self presentViewController:unityVC animated:YES completion:nil];
    
}

- (void)setupUI {
//    [self testSetupUI];
//    return;
    
    [UnityAppInstance.instance pause:NO];
    [UnityAppInstance.instance showUnityView];
    
    UIViewController *unityVC = [UnityAppInstance instance].unityAppController.window.rootViewController;
    UIView *view = [UnityAppInstance instance].unityAppController.rootView;
    CameraViewController *poseVC = [CameraViewController new];
    [unityVC addChildViewController:poseVC];
    
    [poseVC setPosesCallback:^(NSArray<MLKPose *> * _Nonnull poses, UIImageOrientation orientation) {
        NSString *jsonStr = [MLKPose unityJsonStringWithPoses:poses uid:AppContext.currentUserId orientation:orientation];
        [[FrameworkLibAPI sharedInstance] sendMessageToUnity:@"userState" message:jsonStr];
    }];
    __weak CameraViewController *vc = poseVC;
    __weak typeof(self) wSelf = self;
    [poseVC setCameraOffCallback:^{
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [unityVC removeFromParentViewController];
        [wSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [view addSubview:poseVC.view];
    poseVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UnityAppInstance.instance pause:NO];
    [UnityAppInstance.instance showUnityView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [UnityAppInstance.instance pause:YES];
    [[UIApplication sharedApplication].windows.firstObject makeKeyAndVisible];
}


#pragma mark - LifeCycleListener

- (void)mainDisplayInited:(struct UnityDisplaySurfaceBase*)surface {
    NSLog(@" unity ===  mainDisplayInited");
//    __weak typeof(self) wself = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [wself setupUI];
//    });
//
}

- (void)onBeforeMainDisplaySurfaceRecreate:(struct RenderingSurfaceParams*)params {
    NSLog(@" unity ===  onBeforeMainDisplaySurfaceRecreate");

}

- (void)onAfterMainDisplaySurfaceRecreate {
    NSLog(@" unity ===  onAfterMainDisplaySurfaceRecreate");

}

- (void)onFrameResolved {
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(wself.isFirstFrame) {
            [wself setupUI];
            wself.isFirstFrame = false;
        }
    });
}

- (void)didFinishLaunching:(NSNotification*)notification {
    NSLog(@" unity ===  didFinishLaunching");
}
- (void)didBecomeActive:(NSNotification*)notification {
    NSLog(@" unity ===  didBecomeActive");

}
- (void)willResignActive:(NSNotification*)notification{
    NSLog(@" unity ===  willResignActive");

}
- (void)didEnterBackground:(NSNotification*)notification {
    NSLog(@" unity ===  didEnterBackground");

}
- (void)willEnterForeground:(NSNotification*)notification {
    NSLog(@" unity ===  willEnterForeground");

}
- (void)willTerminate:(NSNotification*)notification {
    NSLog(@" unity ===  willTerminate");

}
- (void)unityDidUnload:(NSNotification*)notification {
    NSLog(@" unity ===  unityDidUnload");

}
- (void)unityDidQuit:(NSNotification*)notification {
    NSLog(@" unity ===  unityDidQuit");

}


@end
