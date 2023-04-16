//
//  SelectRoleShowUnityManager.h
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectRoleShowUnityManager : NSObject

@property (nonatomic, strong) NSString *roomId;

@property (nonatomic, assign) NSInteger sceneId;


- (void)showUnityVC;

@end


NS_ASSUME_NONNULL_END
