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

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "UIUtilities.h"
#import "Game2035OCNew-swift.h"
#import "Masonry.h"
#import "PublicHeaders.h"


@import MLImage;
@import MLKit;

#define kSafeAreaInsets [UIApplication sharedApplication].delegate.window.safeAreaInsets

NS_ASSUME_NONNULL_BEGIN


static NSString *const videoDataOutputQueueLabel =
@"com.google.mlkit.visiondetector.VideoDataOutputQueue";
static NSString *const sessionQueueLabel = @"com.google.mlkit.visiondetector.SessionQueue";

static const CGFloat MLKSmallDotRadius = 4.0;

@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AgoraVideoFrameDelegate>

typedef NS_ENUM(NSInteger, Detector) {
    DetectorPose = 1,
    DetectorPoseAccurate,
};

@property(nonatomic) Detector currentDetector;
@property(nonatomic) bool isUsingFrontCamera;
@property(nonatomic, nonnull) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic) AVCaptureSession *captureSession;
@property(nonatomic) dispatch_queue_t sessionQueue;
@property(nonatomic) UIView *annotationOverlayView;
@property(nonatomic) UIImageView *previewOverlayView;
@property(strong, nonatomic) UIView *cameraView;
@property(nonatomic) CMSampleBufferRef lastFrame;
@property(nonatomic) UIButton *offButton;

/** Initialized when one of the pose detector rows are chosen. Reset to `nil` when neither are. */
@property(nonatomic, nullable) MLKPoseDetector *poseDetector;

/** Initialized when a segmentation detector row is chosen. Reset to `nil` otherwise. */
//@property(nonatomic, nullable) MLKSegmenter *segmenter;

/**
 * The detector mode with which detection was most recently run. Only used on the video output
 * queue. Useful for inferring when to reset detector instances which use a conventional lifecycle
 * paradigm.
 */
@property(nonatomic) Detector lastDetector;

@property (nonatomic) ShowAgoraKitManager *agoraKitManager;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentDetector = DetectorPose;
    _isUsingFrontCamera = NO;
    self.agoraKitManager = [[ShowAgoraKitManager alloc] init];
    [self.agoraKitManager setVideoFrameDelegate:self];
    [self.agoraKitManager setExternalVideoSource];
    [self setUpUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startSession];
    [self.agoraKitManager joinChannel:self.roomId successBlock:nil];
//    [self.agoraKitManager startPreviewWithCanvasView:self.cameraView];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.agoraKitManager leaveChannel];
    [self stopSession];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = _cameraView.frame;
}

- (void)switchCamera {
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    [self removeDetectionAnnotations];
    [self setUpCaptureSessionInput];
}

#pragma mark - actions
- (void)didClickOffButton{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.cameraOffCallback) {
        self.cameraOffCallback();
    }
}

#pragma mark - On-Device Detections

- (void)detectPoseInImage:(GMLImage *)image width:(CGFloat)width height:(CGFloat)height {
    NSError *error;
    NSArray<MLKPose *> *poses = [self.poseDetector resultsInImage:image error:&error];
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updatePreviewOverlayViewWithLastFrame];
        [strongSelf removeDetectionAnnotations];
        
        if (poses.count == 0) {
            if (error != nil) {
                NSLog(@"Failed to detect pose with error: %@", error.localizedDescription);
            }
            return;
        }
        if (self.posesCallback) {
            self.posesCallback(poses, image.orientation);
        }
        // Pose detection currently only supports single pose.
        MLKPose *pose = poses.firstObject;
        
        UIView *poseOverlay = [UIUtilities poseOverlayViewForPose:pose
                                                 inViewWithBounds:self.annotationOverlayView.bounds
                                                        lineWidth:3.0f
                                                        dotRadius:MLKSmallDotRadius
                                      positionTransformationBlock:^(MLKVisionPoint *position) {
            return [strongSelf normalizedPointFromVisionPoint:position
                                                        width:width
                                                       height:height];
        }];
        [strongSelf rotateView:strongSelf.cameraView orientation:image.orientation];
        [strongSelf.annotationOverlayView addSubview:poseOverlay];
    });
}

#pragma mark - Private

- (void)setUpUI{
    _captureSession = [[AVCaptureSession alloc] init];
    _sessionQueue = dispatch_queue_create(sessionQueueLabel.UTF8String, nil);
    _previewOverlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _previewOverlayView.contentMode = UIViewContentModeScaleAspectFill;
    _previewOverlayView.clipsToBounds = YES;
    _previewOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    _annotationOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    _annotationOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    
    [self setUpCameraView];
    [self setUpPreviewOverlayView];
    [self setUpAnnotationOverlayView];
    [self setUpCaptureSessionOutput];
    [self setUpCaptureSessionInput];
    if (_isFullScreen){
        [self.cameraView addSubview:self.offButton];
        [self.offButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(40);
        }];
    }
}

- (void)setUpCameraView {
    self.cameraView = [[UIView alloc] init];
//    self.cameraView.alpha = 0.5;
    [self.view addSubview: self.cameraView];
    
    if (_isFullScreen) {
        self.cameraView.frame = self.view.bounds;
    }else {
        self.cameraView.translatesAutoresizingMaskIntoConstraints = NO;
        CGFloat cameraWidth = kCameraWidth;
        CGFloat cameraHeight = kCameraHeight;
        [NSLayoutConstraint activateConstraints:@[
            [self.cameraView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [self.cameraView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [self.cameraView.widthAnchor constraintEqualToConstant:cameraWidth],
            [self.cameraView.heightAnchor constraintEqualToConstant:cameraHeight]
        ]];
    }
  
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCamera)];
    [self.cameraView addGestureRecognizer:tap];
}

- (void)setUpCaptureSessionOutput {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            NSLog(@"Failed to setUpCaptureSessionOutput because self was deallocated");
            return;
        }
        [strongSelf.captureSession beginConfiguration];
        // When performing latency tests to determine ideal capture settings,
        // run the app in 'release' mode to get accurate performance metrics
        strongSelf.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        output.videoSettings = @{
            (id)
            kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
        };
        output.alwaysDiscardsLateVideoFrames = YES;
        dispatch_queue_t outputQueue = dispatch_queue_create(videoDataOutputQueueLabel.UTF8String, nil);
        [output setSampleBufferDelegate:self queue:outputQueue];
        if ([strongSelf.captureSession canAddOutput:output]) {
            [strongSelf.captureSession addOutput:output];
            [strongSelf.captureSession commitConfiguration];
        } else {
            NSLog(@"%@", @"Failed to add capture session output.");
        }
    });
}

- (void)setUpCaptureSessionInput {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            NSLog(@"Failed to setUpCaptureSessionInput because self was deallocated");
            return;
        }
        AVCaptureDevicePosition cameraPosition =
        strongSelf.isUsingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        AVCaptureDevice *device = [strongSelf captureDeviceForPosition:cameraPosition];
        if (device) {
            [strongSelf.captureSession beginConfiguration];
            NSArray<AVCaptureInput *> *currentInputs = strongSelf.captureSession.inputs;
            for (AVCaptureInput *input in currentInputs) {
                [strongSelf.captureSession removeInput:input];
            }
            NSError *error;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                                error:&error];
            if (error) {
                NSLog(@"Failed to create capture device input: %@", error.localizedDescription);
                return;
            } else {
                if ([strongSelf.captureSession canAddInput:input]) {
                    [strongSelf.captureSession addInput:input];
                } else {
                    NSLog(@"%@", @"Failed to add capture session input.");
                }
            }
            [strongSelf.captureSession commitConfiguration];
        } else {
            NSLog(@"Failed to get capture device for camera position: %ld", cameraPosition);
        }
    });
}

- (void)startSession {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        [weakSelf.captureSession startRunning];
    });
}

- (void)stopSession {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        [weakSelf.captureSession stopRunning];
    });
}

- (void)setUpPreviewOverlayView {
    [_cameraView addSubview:_previewOverlayView];
    [NSLayoutConstraint activateConstraints:@[
//        [_previewOverlayView.centerYAnchor constraintEqualToAnchor:_cameraView.centerYAnchor],
//        [_previewOverlayView.centerXAnchor constraintEqualToAnchor:_cameraView.centerXAnchor],
        [_previewOverlayView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor],
        [_previewOverlayView.topAnchor constraintEqualToAnchor:_cameraView.topAnchor],
        [_previewOverlayView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor],
        [_previewOverlayView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor]
    ]];
}
- (void)setUpAnnotationOverlayView {
    [_cameraView addSubview:_annotationOverlayView];
    [NSLayoutConstraint activateConstraints:@[
        [_annotationOverlayView.topAnchor constraintEqualToAnchor:_cameraView.topAnchor],
        [_annotationOverlayView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor],
        [_annotationOverlayView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor],
        [_annotationOverlayView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor]
    ]];
}

- (AVCaptureDevice *)captureDeviceForPosition:(AVCaptureDevicePosition)position {
    if (@available(iOS 10, *)) {
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
                                                             discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                                                             mediaType:AVMediaTypeVideo
                                                             position:AVCaptureDevicePositionUnspecified];
        for (AVCaptureDevice *device in discoverySession.devices) {
            if (device.position == position) {
                return device;
            }
        }
    }
    return nil;
}

- (void)removeDetectionAnnotations {
    for (UIView *annotationView in _annotationOverlayView.subviews) {
        [annotationView removeFromSuperview];
    }
}

- (void)updatePreviewOverlayViewWithLastFrame {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_lastFrame);
    [self updatePreviewOverlayViewWithImageBuffer:imageBuffer];
}

- (void)updatePreviewOverlayViewWithImageBuffer:(CVImageBufferRef)imageBuffer {
    if (imageBuffer == nil) {
        return;
    }
    UIImageOrientation orientation =
    _isUsingFrontCamera ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
    UIImage *image = [UIUtilities UIImageFromImageBuffer:imageBuffer orientation:orientation];
    _previewOverlayView.image = image;
}

- (CGPoint)normalizedPointFromVisionPoint:(MLKVisionPoint *)point
                                    width:(CGFloat)width
                                   height:(CGFloat)height {
    CGPoint cgPointValue = CGPointMake(point.x, point.y);
    CGPoint normalizedPoint = CGPointMake(cgPointValue.x / width, cgPointValue.y / height);
    CGPoint cgPoint = [_previewLayer pointForCaptureDevicePointOfInterest:normalizedPoint];
    return cgPoint;
}


- (void)rotateView:(UIView *)view orientation:(UIImageOrientation)orientation {
    CGFloat degree = 0.0;
    switch (orientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            degree = 270.0;
            break;
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeft:
            degree = 180.0;
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            degree = 270.0;
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
            degree = 0.0;
            break;
    }
    view.transform = CGAffineTransformMakeRotation(degree * 3.141592654 / 180);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer) {
        // Evaluate `self.currentDetector` once to ensure consistency throughout this method since it
        // can be concurrently modified from the main thread.
        Detector activeDetector = self.currentDetector;
        [self resetManagedLifecycleDetectorsForActiveDetector:activeDetector];
        
        _lastFrame = sampleBuffer;
        MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithBuffer:sampleBuffer];
        UIImageOrientation orientation = [UIUtilities
                                          imageOrientationFromDevicePosition:_isUsingFrontCamera ? AVCaptureDevicePositionFront
                                          : AVCaptureDevicePositionBack];
        
        visionImage.orientation = orientation;
        
        GMLImage *inputImage = [[GMLImage alloc] initWithSampleBuffer:sampleBuffer];
        inputImage.orientation = orientation;
        CGFloat imageWidth = CVPixelBufferGetWidth(imageBuffer);
        CGFloat imageHeight = CVPixelBufferGetHeight(imageBuffer);
        [self detectPoseInImage:inputImage width:imageWidth height:imageHeight];
        [self.agoraKitManager pushExternalVideoFrame:[self agoraVideoFrameFrom:sampleBuffer]];

    } else {
        NSLog(@"%@", @"Failed to get image buffer from sample buffer.");
    }
}

#pragma mark - AgoraVideoFrameDelegate

- (BOOL)onCaptureVideoFrame:(AgoraOutputVideoFrame *)videoFrame {
    Detector activeDetector = self.currentDetector;
    UIImageOrientation orientation = [UIUtilities
                                      imageOrientationFromDevicePosition:_isUsingFrontCamera ? AVCaptureDevicePositionFront
                                      : AVCaptureDevicePositionBack];
    GMLImage *inputImage = [[GMLImage alloc] initWithPixelBuffer:videoFrame.pixelBuffer];
    inputImage.orientation = orientation;
    CGFloat imageWidth = videoFrame.width;
    CGFloat imageHeight = videoFrame.height;
    [self detectPoseInImage:inputImage width:imageWidth height:imageHeight];
    return YES;
}

#pragma mark - Private

- (AgoraVideoFrame *)agoraVideoFrameFrom:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    AgoraVideoFrame *videoFrame = [AgoraVideoFrame new];
    videoFrame.format = 12;
    videoFrame.textureBuf = pixelBuffer;
    videoFrame.time = time;
//    videoFrame.rotation = 180;
    return videoFrame;
}


/**
 * Resets any detector instances which use a conventional lifecycle paradigm. This method is
 * expected to be invoked on the AVCaptureOutput queue - the same queue on which detection is run.
 *
 * @param activeDetector The detector mode for which detection will be run.
 */
- (void)resetManagedLifecycleDetectorsForActiveDetector:(Detector)activeDetector {
    if (activeDetector == self.lastDetector) {
        // Same row as before, no need to reset any detectors.
        return;
    }
    // Clear the old detector, if applicable.
    switch (self.lastDetector) {
        case DetectorPose:
        case DetectorPoseAccurate:
            self.poseDetector = nil;
            break;
        default:
            break;
    }
    // Initialize the new detector, if applicable.
    switch (activeDetector) {
        case DetectorPose:
        case DetectorPoseAccurate: {
            // The `options.detectorMode` defaults to `MLKPoseDetectorModeStream`.
            MLKCommonPoseDetectorOptions *options = activeDetector == DetectorPose
            ? [[MLKPoseDetectorOptions alloc] init] : [[MLKAccuratePoseDetectorOptions alloc] init];
            self.poseDetector = [MLKPoseDetector poseDetectorWithOptions:options];
            break;
        }
        default:
            break;
    }
    self.lastDetector = activeDetector;
}

#pragma mark - getter

- (UIButton *)offButton {
    if (!_offButton) {
        _offButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_offButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_offButton addTarget:self action:@selector(didClickOffButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _offButton;
}

@end

NS_ASSUME_NONNULL_END
