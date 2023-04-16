//
//  MLKPose+Extension.m
//  Game2035OC
//
//  Created by FanPengpeng on 2023/2/26.
//

#import "MLKPose+Extension.h"
#import "MJExtension.h"

@import MLKit;

@implementation MLKPose (Extension)

+ (NSString *)unityJsonStringWithPoses:(NSArray<MLKPose *> *)poses uid:(nonnull NSString *)uid orientation:(UIImageOrientation)orientation{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = uid;
    NSMutableDictionary *points = [NSMutableDictionary dictionary];
    [poses  enumerateObjectsUsingBlock:^(MLKPose * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.landmarks enumerateObjectsUsingBlock:^(MLKPoseLandmark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *array = [NSMutableArray array];
            CGPoint p = [self rotatedPoint:obj.position orientation:orientation];
            [array addObject:@(p.x)];
            [array addObject:@(p.y)];
            [array addObject:@(obj.position.z)];
            if (obj.type) {
                NSString *key = [self indexForPoseType:obj.type];
                if (key){
                    points[key] = array;                    
                }
            }
        }];
    }];
    dic[@"point"] = points;
    NSString *jsonStr = [dic mj_JSONString];
    NSLog(@"jsonStr = %@",jsonStr);
    return jsonStr;
}

+ (CGPoint)rotatedPoint:(MLKVision3DPoint*) position orientation:(UIImageOrientation)orientation {
    CGFloat x = position.x;
    CGFloat y = position.y;
  switch (orientation) {
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
          x = -position.x;
          y = -position.y;
      break;
    case UIImageOrientationRightMirrored:
    case UIImageOrientationLeft:
          x = position.x;
          y = position.y;
      break;
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
          x = position.x;
          y = position.y;
      break;
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
          x = position.y;
          y = -position.x;
      break;
  }
    return CGPointMake(x, y);
}

static NSDictionary <MLKPoseLandmarkType, NSNumber *> *PoseLandmarkTypeMap = nil;

+ (NSString *)indexForPoseType:(MLKPoseLandmarkType)type {
    
    if (PoseLandmarkTypeMap == nil) {
        PoseLandmarkTypeMap = @{
//            MLKPoseLandmarkTypeNose: @0,
//            MLKPoseLandmarkTypeLeftEyeInner: @1,
//            MLKPoseLandmarkTypeLeftEye: @2,
//            MLKPoseLandmarkTypeLeftEyeOuter: @3,
//            MLKPoseLandmarkTypeRightEyeInner: @4,
//            MLKPoseLandmarkTypeRightEye:@5,
//            MLKPoseLandmarkTypeRightEyeOuter: @6,
            MLKPoseLandmarkTypeLeftEar: @7,
            MLKPoseLandmarkTypeRightEar: @8,
//            MLKPoseLandmarkTypeMouthLeft: @9,
//            MLKPoseLandmarkTypeMouthRight: @10,
            MLKPoseLandmarkTypeLeftShoulder: @11,
            MLKPoseLandmarkTypeRightShoulder: @12,
            MLKPoseLandmarkTypeLeftElbow: @13,
            MLKPoseLandmarkTypeRightElbow: @14,
            MLKPoseLandmarkTypeLeftWrist: @15,
            MLKPoseLandmarkTypeRightWrist: @16,
//            MLKPoseLandmarkTypeLeftPinkyFinger: @17,
//            MLKPoseLandmarkTypeRightPinkyFinger: @18,
//            MLKPoseLandmarkTypeLeftIndexFinger:@19,
//            MLKPoseLandmarkTypeRightIndexFinger: @20,
//            MLKPoseLandmarkTypeLeftThumb: @21,
//            MLKPoseLandmarkTypeRightThumb: @22,
            MLKPoseLandmarkTypeLeftHip: @23,
            MLKPoseLandmarkTypeRightHip: @24,
            MLKPoseLandmarkTypeLeftKnee: @25,
            MLKPoseLandmarkTypeRightKnee: @26,
            MLKPoseLandmarkTypeLeftAnkle: @27,
            MLKPoseLandmarkTypeRightAnkle: @28,
//            MLKPoseLandmarkTypeLeftHeel: @29,
//            MLKPoseLandmarkTypeRightHeel: @30,
//            MLKPoseLandmarkTypeLeftToe: @31,
//            MLKPoseLandmarkTypeRightToe: @32,
        };
    }
    
    NSNumber *ret = PoseLandmarkTypeMap[type];
    return [ret stringValue];
}


@end
