//
//  CaptureVideoPreviewLayer.m
//  TakePhoto
//
//  Created by Eternity° on 15/8/11.
//  Copyright (c) 2015年 Eternity. All rights reserved.
//

#import "CaptureVideoPreviewLayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CaptureVideoPreviewLayer ()<AVCaptureVideoDataOutputSampleBufferDelegate>
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
    
    [self.captureSession beginConfiguration];
    //4、输出设备
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:&error];
    if (error) {
        NSLog(@"暂不支持照相功能");
    }
    if ([self.captureSession canAddInput:captureDeviceInput]) {
        [self.captureSession addInput:captureDeviceInput];
    }

    //5、视频输出
    AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];//丢弃延迟的帧
    [captureVideoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}];
    [captureVideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([self.captureSession canAddOutput:captureVideoDataOutput]) {
        [self.captureSession addOutput:captureVideoDataOutput];
    }
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}
- (IBAction)onBtnTakePhoto:(UIButton *)sender {
    [self.captureSession stopRunning];
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    [self imageFromSampleBuffer:pixelBuffer];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

}
// pixelBuffer transform image
- (UIImage *)imageFromSampleBuffer:(CVPixelBufferRef)pixelBuffer {
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
//    CIContext *temporaryContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(YES)}];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:image fromRect:CGRectMake(0, 0,CVPixelBufferGetWidth(pixelBuffer),CVPixelBufferGetHeight(pixelBuffer) )];
    UIImage *imageGet = [UIImage imageWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(videoImage);
    
    UIImage *imagePortrait = [self cropImage:imageGet atRect:CGRectMake(0, 0, imageGet.size.width, imageGet.size.height)];
    return imagePortrait;
}
//change image's orientation
- (UIImage *)cropImage:(UIImage *)image atRect:(CGRect) rect
{
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [image drawInRect:drawRect];
    croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}
@end
