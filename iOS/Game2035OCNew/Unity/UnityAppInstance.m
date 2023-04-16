//
//  UnityAppInstance.m
//  NativeIOSProject
//
//  Created by li jia on 2022/11/4.
//

#import "UnityAppInstance.h"
#import "UnityAppDelegateTools.h"
#import "AppDelegate.h"

@interface UnityAppInstance()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, weak) UnityFramework* ufw;

@end

@implementation UnityAppInstance

+ (instancetype)instance {
    static dispatch_once_t once;
    static UnityAppInstance *_instance;
    dispatch_once(&once, ^{
        _instance = [UnityAppInstance new];
    });
    return _instance;
}

- (AppDelegate *)appDelegate {
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    return appDelegate;
}

- (BOOL)unityIsInitialized {
    return [self ufw] && self.unityAppController;
}

- (void)pause:(BOOL)isPause {
    if (self.ufw) {
        [self.ufw pause:isPause];
    }
}

- (void)showNativeView {
    [self.appDelegate.window makeKeyAndVisible];
}

- (void)showUnityView {
    if (![self unityIsInitialized]){
        NSLog(@"Unity 还未初始化");
    }

    [self.ufw showUnityWindow];
}

//游戏物体名称  方法名称  参数
- (void)sendMessageToGOWithName:(NSString *)goName functionName:(NSString *)name message:(NSString *)msg {
    [self.ufw sendMessageToGOWithName:goName.UTF8String functionName:name.UTF8String message:msg.UTF8String];
}

- (void)initUnityWithOptions:(NSDictionary *)options {
//    if ([self unityIsInitialized])  return;
    
    self.ufw = [self UnityFrameworkLoad];
    
    [self.ufw runEmbeddedWithArgc:UnityAppDelegateTools.instance.argc
                        argv:UnityAppDelegateTools.instance.argv appLaunchOpts:options];
}

- (void)initUnityWithFrame:(CGRect)rect withOptions:(nonnull NSDictionary *)options{
    
    [self initUnityWithOptions:options];
    
    self.unityAppController = [self.ufw appController];
    UIWindow *window = self.unityAppController.window;
    window.frame = rect;
}


- (UnityFramework *)UnityFrameworkLoad
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    UnityFramework* ufw = [bundle.principalClass getInstance];
    
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    
    [ufw setDataBundleId:"com.unity3d.framework"];
    
    return ufw;
}

@end
