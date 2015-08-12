//
//  CaptureStillImageOutput.m
//  TakePhoto
//
//  Created by Eternity° on 15/8/11.
//  Copyright (c) 2015年 Eternity. All rights reserved.
//

#import "CaptureStillImageOutput.h"
#import <AVFoundation/AVFoundation.h>

@interface CaptureStillImageOutput ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewContrainer;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;

@property (nonatomic, strong)AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;

@end

@implementation CaptureStillImageOutput

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
//5、获取静态图
- (AVCaptureStillImageOutput *)captureStillImageOutput {
    if (!_captureStillImageOutput) {
        _captureStillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        [_captureStillImageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];//输出设置
    }
    return _captureStillImageOutput;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.captureVideoPreviewLayer.frame = self.viewContrainer.bounds;
    [self.viewContrainer.layer addSublayer:self.captureVideoPreviewLayer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CaptureStillImageOutput";
    
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
    
    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        [self.captureSession addOutput:self.captureStillImageOutput];
    }
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}
- (IBAction)onBtnTakePhoto:(UIButton *)sender {
    if (!sender.selected) {
        
        AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (captureConnection) {
            [self.captureStillImageOutput
             captureStillImageAsynchronouslyFromConnection:captureConnection
             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                 if (imageDataSampleBuffer) {
                     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                     UIImage *image = [[UIImage alloc] initWithData:imageData];
                     //save photo to album
                     UIImageWriteToSavedPhotosAlbum(image, self, NULL, NULL);
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         UILabel *noteLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.view.frame.size.width * 0.5 + 20, self.view.frame.size.width - 100 *2, 30)];
                         noteLabel.backgroundColor = [UIColor blackColor];
                         noteLabel.alpha = 1;
                         noteLabel.textColor = [UIColor whiteColor];
                         noteLabel.textAlignment = NSTextAlignmentCenter;
                         noteLabel.font = [UIFont systemFontOfSize:15.0f];
                         noteLabel.text = @"保存图片成功";
                         [self.view addSubview:noteLabel];
                         
                         [UIView animateWithDuration:2.0 animations:^{
                             noteLabel.alpha = 0;
                         }completion:^(BOOL finished) {
                             [noteLabel removeFromSuperview];
                         }];
                     });
                 }
             }];
        }
        sender.selected = YES;
        [self.captureSession stopRunning];
    }else {
        sender.selected = NO;
        [self.captureSession startRunning];
    }
}
@end
