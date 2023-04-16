//
//  CameraViewController+ForARKit.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/13.
//

#import "CameraViewController+ForARKit.h"
#import <ARKit/ARKit.h>

@interface CameraViewController () <ARSessionDelegate>

@end

@implementation CameraViewController (ForARKit)

- (void)startARKit {
    if (ARBodyTrackingConfiguration.isSupported) {
        ARBodyTrackingConfiguration *configuration = [ARBodyTrackingConfiguration new];
        // 启动AR会话
        [self.arSession runWithConfiguration:configuration];
    }else {
        NSLog(@"设备不支持AR Body Tracking");
    }
}

- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<__kindof ARAnchor *> *)anchors {
    for (ARAnchor *anchor in anchors) { if (![anchor isKindOfClass:[ARBodyAnchor class]]) { continue; }
        
        ARBodyAnchor *bodyAnchor = (ARBodyAnchor *)anchor;
        NSInteger jointsCount = bodyAnchor.skeleton.jointCount; // 关节点数量
        NSLog(@"Found %ld body joints", jointsCount);
        
        for (NSString *jointName in [ARSkeletonDefinition defaultBody3DSkeletonDefinition].jointNames) {
            NSInteger jointIndex = [[ARSkeletonDefinition defaultBody3DSkeletonDefinition] indexForJointName:jointName];
            simd_float4x4 jointLocalTransform = bodyAnchor.skeleton.jointLocalTransforms[jointIndex];
            // 输出关键点的局部坐标
            NSLog(@"%@ - position -> x: %f, y: %f, z: %f", jointName, jointLocalTransform.columns[3][0], jointLocalTransform.columns[3][1], jointLocalTransform.columns[3][2]);
        }
    }
}

@end
