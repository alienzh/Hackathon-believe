//
//  PublicHeaders.h
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/13.
//

#ifndef PublicHeaders_h
#define PublicHeaders_h


#define k_safeAreaInsets [UIApplication sharedApplication].keyWindow.safeAreaInsets

static CGFloat const kCameraWidth = 150;
static CGFloat const kCameraHeight = (kCameraWidth / 3.0 * 4.0);

static NSString * const kGameRole = @"kGameRole";
static NSString * const kRoomId = @"kRoomId";
static NSString * const kSceneId = @"kSceneId";

static NSString * const kUnityBecomeActiveNotification = @"kUnityBecomeActiveNotification";

typedef enum : NSUInteger {
    GameRoleUnknown = 0,
    GameRolePlayer = 1,
    GameRoleAudience = 2,
} GameRole;


#endif /* PublicHeaders_h */
