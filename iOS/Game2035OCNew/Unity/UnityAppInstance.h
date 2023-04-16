//
//  UnityAppInstance.h
//  NativeIOSProject
//
//  Created by li jia on 2022/11/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <UnityFramework/UnityFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityAppInstance : NSObject

@property (nonatomic, strong) UnityAppController *unityAppController;


+ (instancetype)instance;

- (void)initUnityWithOptions:(NSDictionary *)options;
- (void)initUnityWithFrame:(CGRect)rect withOptions: (NSDictionary *)options;

- (void)pause:(BOOL)isPause;

- (BOOL)unityIsInitialized;
- (void)showUnityView;
- (void)showNativeView;

//游戏物体名称  方法名称  参数
- (void)sendMessageToGOWithName:(NSString *)goName functionName:(NSString *)name message:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
