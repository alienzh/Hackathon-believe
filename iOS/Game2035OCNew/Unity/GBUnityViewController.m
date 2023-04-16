//
//  GBUnityViewController.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/9.
//

#import "GBUnityViewController.h"
#import "GBUnityAppController.h"
#import "UnityAppInstance.h"
#import "Masonry.h"

@interface GBUnityViewController () <RenderPluginDelegate>

@property (nonatomic) UIView *containerView;

@end

@implementation GBUnityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 调用UnityAppController
    UnityAppController *appController = GetAppController();
    appController.renderDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
//    [self unitySetViewOrientation:GetAppController().rootViewController.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.containerView) {
        [self setupUnityUI];
    }
    [UnityFramework.getInstance pause:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UnityFramework.getInstance pause:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didClickOffButton {
    [UnityAppInstance.instance pause:YES];
    [UnityFramework.getInstance unloadApplication];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mainDisplayInited:(struct UnityDisplaySurfaceBase *)surface {
    if (!self.containerView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupUnityUI];
        });
    }
    
}

- (void)setupUnityUI {
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView = containerView;
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UnityAppController *appController = GetAppController();
    // 将Unity的根视图添加到当前视图控制器的视图层级中
    UIView *uView = appController.unityView;
    [containerView addSubview:uView];
    [uView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
    
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [offButton setTitle:@"关闭" forState:UIControlStateNormal];
    [offButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [offButton setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:offButton];
    [offButton addTarget:self action:@selector(didClickOffButton) forControlEvents:UIControlEventTouchUpInside];
    [offButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.right.mas_equalTo(-50);
    }];
    
    [appController.window resignKeyWindow];
    appController.window.hidden = YES;
    [appController.window removeFromSuperview];
    [self unitySetViewOrientation:GetAppController().rootViewController.interfaceOrientation];
}

-(void)unitySetViewOrientation:(UIInterfaceOrientation) orientation
{
    UIView *view = self.view;
    if (view)
    {
        // 这里假设设备横向为正方向，纵向需要顺时针旋转90度
        float angle = 0.0f;
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
                angle = -90.0f;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = 90.0f;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = 180.0f;
                break;
            default:
                break;
        }
        view.transform = CGAffineTransformMakeRotation(angle * M_PI / 180);
    }
}

@end
