//
//  SZQRCodeViewController.m
//  SZQRCodeViewController
//
//  Created by Stephen Zhuang on 16/5/17.
//  Copyright © 2016年 StephenZhuang. All rights reserved.
//

#import "SZQRCodeViewController.h"
#import "PureLayout.h"

@interface SZQRCodeViewController ()

@end

@implementation SZQRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    
    self.title = @"扫一扫";
    
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有相机权限" message:@"请去设置-隐私-相机中对爱儿邦授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:okAction];
        
        hasCameraRight = NO;
        return;
    }
    hasCameraRight = YES;
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0.8 * self.view.frame.size.width, 0.8 * self.view.frame.size.width)];
    imageView.image = [UIImage imageNamed:@"contact_scanframe"];
    [self.view addSubview:imageView];
    [imageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:100];
    [imageView autoSetDimensionsToSize:CGSizeMake(0.8 * self.view.frame.size.width, 0.8 * self.view.frame.size.width)];
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 30)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.text=@"将取景框对准二维码，即自动扫描";
    [self.view addSubview:labIntroudction];
    [labIntroudction autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:imageView];
    [labIntroudction autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:imageView];
    [labIntroudction autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:imageView withOffset:8];
    
    
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, 220, 2)];
    _line.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:_line];
    [_line autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:imageView withOffset:40];
    [_line autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:imageView withOffset:-40];
    [_line autoSetDimension:ALDimensionHeight toSize:2];
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:imageView withOffset:10];
    
    [self setupCamera];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(CGRectGetMinX(_line.frame), 110+2*num, CGRectGetWidth(_line.frame), CGRectGetHeight(_line.frame));
        if (2 * num == CGRectGetHeight(imageView.frame) - 20) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(CGRectGetMinX(_line.frame), 110+2*num, CGRectGetWidth(_line.frame), CGRectGetHeight(_line.frame));
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

- (BOOL)navigationShouldPopOnBackButton
{
    [timer invalidate];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (hasCameraRight) {
        if (_session && ![_session isRunning]) {
            [_session startRunning];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)setupCamera
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        // Device
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Input
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        // Output
        _output = [[AVCaptureMetadataOutput alloc]init];
        //    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // Session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            // Preview
            _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
            _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            //    _preview.frame =CGRectMake(20,110,280,280);
            _preview.frame = self.view.bounds;
            [self.view.layer insertSublayer:self.preview atIndex:0];
            // Start
            [_session startRunning];
        });
    });
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        
        [_session stopRunning];
        [timer invalidate];
        NSLog(@"%@",stringValue);
        
        if (stringValue.length > 0) {
//            NSString *url = [NSURL URLWithString:@"html/judgement.html" relativeToURL:[ZXApiClient sharedClient].baseURL].absoluteString;
//            
//            if ([stringValue hasPrefix:url]) {
//                NSArray *arr = [stringValue componentsSeparatedByString:@"?"];
//                if (arr.count > 1) {
//                    NSString *uid = [[arr objectAtIndex:1] substringFromIndex:4];
//                    
//                    if (uid.integerValue == GLOBAL_UID) {
//                        ZXMyProfileViewController *vc = [ZXMyProfileViewController viewControllerFromStoryboard];
//                        [self.navigationController pushViewController:vc animated:YES];
//                    } else {
//                        ZXUserProfileViewController *vc = [ZXUserProfileViewController viewControllerFromStoryboard];
//                        vc.uid = uid.integerValue;
//                        [self.navigationController pushViewController:vc animated:YES];
//                    }
//                }
//            }
//            else if ([stringValue hasPrefix:[NSString stringWithFormat:@"%@qrcodelogin?qrcodeId=",@"http://www.aierbon.com/"]]) {
//                NSString *qrcodeId = [[stringValue componentsSeparatedByString:@"="] lastObject];
//                ZXLoginBackendViewController *vc = [ZXLoginBackendViewController viewControllerFromStoryboard];
//                vc.qrcodeid = qrcodeId;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//            else {
                [self.navigationController popViewControllerAnimated:YES];
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
//            }
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
