//
//  GBLoginViewController.h
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GBLoginSuccess)(void);

@interface GBLoginViewController : UIViewController

@property (nonatomic, copy)GBLoginSuccess loginSuccessCallback;

@end

NS_ASSUME_NONNULL_END
