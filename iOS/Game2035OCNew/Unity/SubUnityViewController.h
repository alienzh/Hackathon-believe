//
//  SubUnityViewController.h
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/9.
//

#import <UnityFramework/UnityFramework.h>

@interface UnityViewControllerBase : UIViewController

@end

NS_ASSUME_NONNULL_BEGIN

@interface SubUnityViewController : UnityViewControllerBase

@property (nonatomic, retain) id notificationDelegate;

SubUnityViewController* AllocUnitySingleOrientationViewController(UIInterfaceOrientation orient);

@end

NS_ASSUME_NONNULL_END
