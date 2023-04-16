//
//  MLKPose+Extension.h
//  Game2035OC
//
//  Created by FanPengpeng on 2023/2/26.
//

#import <MLKitPoseDetectionCommon/MLKitPoseDetectionCommon.h>

@import MLImage;

NS_ASSUME_NONNULL_BEGIN

@interface MLKPose (Extension)

+ (NSString *)unityJsonStringWithPoses:(NSArray <MLKPose *> *)poses uid:(NSString *)uid orientation: (UIImageOrientation) orientation;

@end

NS_ASSUME_NONNULL_END
