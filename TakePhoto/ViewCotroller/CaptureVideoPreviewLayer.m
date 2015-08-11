//
//  CaptureVideoPreviewLayer.m
//  TakePhoto
//
//  Created by Eternity° on 15/8/11.
//  Copyright (c) 2015年 Eternity. All rights reserved.
//

#import "CaptureVideoPreviewLayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CaptureVideoPreviewLayer ()
@property (weak, nonatomic) IBOutlet UIView *viewContrainer;

@property (nonatomic, strong)AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation CaptureVideoPreviewLayer
//1、物理设备 前置摄像头
- (AVCaptureDevice *)captureDevice {
    if (!_captureDevice) {
        NSArray *arrDevice = [AVCaptureDevice devices];
        for (AVCaptureDevice *device in arrDevice) {
            if ([device hasMediaType:AVMediaTypeVideo]) {
                if (device.position == AVCaptureDevicePositionFront) {
                    _captureDevice = device;
                }
            }
        }
    }
    return _captureDevice;
}
//2、初始化预览层
- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer {
    if (!_captureVideoPreviewLayer) {
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
//        _captureVideoPreviewLayer.frame = self.viewContrainer.frame;
//        _captureVideoPreviewLayer.position = self.view.center;
        [_captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _captureVideoPreviewLayer;
}
//3、会话
- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc]init];
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;//决定了视频输入每一帧图像质量的大小,即采集质量
    }
    return _captureSession;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.captureVideoPreviewLayer.frame = self.viewContrainer.bounds;
    [self.viewContrainer.layer addSublayer:self.captureVideoPreviewLayer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //4、输出设备
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:&error];
    if (error) {
        NSLog(@"暂不支持照相功能");
    }
    
    if ([self.captureSession canAddInput:captureDeviceInput]) {
        [self.captureSession addInput:captureDeviceInput];
    }
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}
@end
