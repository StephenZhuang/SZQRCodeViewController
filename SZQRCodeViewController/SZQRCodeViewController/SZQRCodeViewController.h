//
//  SZQRCodeViewController.h
//  SZQRCodeViewController
//
//  Created by Stephen Zhuang on 16/5/17.
//  Copyright © 2016年 StephenZhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SZQRCodeViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UIImageView * imageView;
    
    BOOL hasCameraRight;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;

@end
