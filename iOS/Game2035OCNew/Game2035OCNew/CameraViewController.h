//
//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>
@import MLImage;
@import MLKit;

@class ARSession;

NS_ASSUME_NONNULL_BEGIN

typedef void(^PosesCallback)(NSArray<MLKPose *> * _Nonnull poses, UIImageOrientation orientation);

typedef void(^CameraOffCallback)(void);


@interface CameraViewController : UIViewController

@property(copy, nonatomic) PosesCallback posesCallback;

@property(copy, nonatomic) CameraOffCallback cameraOffCallback;

@property(assign, nonatomic) BOOL isFullScreen;

@property (nonatomic) ARSession *arSession;

@property (nonatomic, copy) NSString * roomId;

@end

NS_ASSUME_NONNULL_END
