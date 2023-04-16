//
//  AppDelegate.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/4.
//

#import "AppDelegate.h"
#import "Game2035OCNew-swift.h"
#import "GBLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *mainVC = [sb instantiateViewControllerWithIdentifier:@"mainVC"];
    self.window = window;
    if (![AppContext isLogin]) {
//        LoginViewController *loginVC = [sb instantiateViewControllerWithIdentifier:@"LoginVC"];
        GBLoginViewController *loginVC = [GBLoginViewController new];
        [loginVC setLoginSuccessCallback:^{
            window.rootViewController = mainVC;
        }];
        window.rootViewController = loginVC;
    }else {
        window.rootViewController = mainVC;
    }
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (window == self.window){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - UISceneSession lifecycle
/*

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}
*/

@end
