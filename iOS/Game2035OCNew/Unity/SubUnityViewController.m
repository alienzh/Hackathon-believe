//
//  SubUnityViewController.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/9.
//

#import "SubUnityViewController.h"
#import "UnityAppInstance.h"
#import "Masonry.h"

@interface UnityAppController()

- (void)updateAppOrientation:(UIInterfaceOrientation)orientation;

@end

@interface  UnityPortraitOnlySubUnityViewController : SubUnityViewController

@end

@interface  UnityPortraitUpsideDownOnlySubUnityViewController : SubUnityViewController

@end

@interface  UnityLandscapeLeftOnlySubUnityViewController : SubUnityViewController

@end

@interface  UnityLandscapeRightOnlySubUnityViewController : SubUnityViewController

@end


@implementation UnityPortraitOnlySubUnityViewController
- (NSUInteger)supportedInterfaceOrientations
{
    return 1 << UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GetAppController() updateAppOrientation: UIInterfaceOrientationPortrait];
    [super viewWillAppear: animated];
}

@end

@implementation UnityPortraitUpsideDownOnlySubUnityViewController

- (NSUInteger)supportedInterfaceOrientations
{
    return 1 << UIInterfaceOrientationPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GetAppController() updateAppOrientation: UIInterfaceOrientationPortraitUpsideDown];
    [super viewWillAppear: animated];
}

@end

@implementation UnityLandscapeLeftOnlySubUnityViewController

- (NSUInteger)supportedInterfaceOrientations
{
    return 1 << UIInterfaceOrientationLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GetAppController() updateAppOrientation: UIInterfaceOrientationLandscapeLeft];
    [super viewWillAppear: animated];
}

@end


@implementation UnityLandscapeRightOnlySubUnityViewController

- (NSUInteger)supportedInterfaceOrientations
{
    return 1 << UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GetAppController() updateAppOrientation: UIInterfaceOrientationLandscapeRight];
    [super viewWillAppear: animated];
}

@end



@interface SubUnityViewController ()

@end

@implementation SubUnityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)didClickOffButton {
    [UnityAppInstance.instance pause:YES];
    [UnityFramework.getInstance unloadApplication];
    [self.navigationController popViewControllerAnimated:YES];
}


SubUnityViewController* AllocUnitySingleOrientationViewController(UIInterfaceOrientation orient)
{
    switch (orient)
    {
        case UIInterfaceOrientationPortrait:            return [UnityPortraitOnlySubUnityViewController alloc];
        case UIInterfaceOrientationPortraitUpsideDown:  return [UnityPortraitUpsideDownOnlySubUnityViewController alloc];
        case UIInterfaceOrientationLandscapeLeft:       return [UnityLandscapeLeftOnlySubUnityViewController alloc];
        case UIInterfaceOrientationLandscapeRight:      return [UnityLandscapeRightOnlySubUnityViewController alloc];

        default:                                        assert(false && "bad UIInterfaceOrientation provided");
    }
    return nil;
}

@end

