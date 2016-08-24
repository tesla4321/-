//
//  ViewController.m
//  二维码
//
//  Created by kyle on 2016/8/12.
//  Copyright © 2016年 bestkayle. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic,assign)BOOL isQRCodeCaptured;
@property(nonatomic,strong)UILabel *label;

@end

@implementation ViewController

//-(BOOL)canBecomeFirstResponder {
//    return YES;
//}
//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self becomeFirstResponder];
//}
//- (void)viewWillDisappear:(BOOL)animated {
//    [self resignFirstResponder];
//    [super viewWillDisappear:animated];
//}
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventSubtypeMotionShake) {
//        [self restart];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAutho];
    
    
//    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width - 40, self.view.bounds.size.height - 40)];
//    _label.backgroundColor = [UIColor whiteColor];
//    _label.alpha = 0;
//    _label.adjustsFontSizeToFitWidth = 1;
//    [self.view addSubview:_label];
    
}

- (void)getAutho{
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self startCapture];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"不能访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alert show];
                    NSLog(@"%@", @"访问受限");
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            [self startCapture];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            NSLog(@"%@", @"访问受限");
            break;
        }
            
        default: {
            break;
        }
    }

}

- (void)startCapture{
    
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput) {
        [session addInput:deviceInput];
        
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [session addOutput:metadataOutput]; // 这行代码要在设置 metadataObjectTypes 前
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = self.view.frame;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        
        [session startRunning];
    } else {
        NSLog(@"%@", error);
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isQRCodeCaptured) { // 成功后系统不会停止扫描，可以用一个变量来控制。
        
        NSLog(@"%@", metadataObject.stringValue);
        
        NSString *reStr = @"^(((ht|f)tp(s?))\://)?(www.|[a-zA-Z].)[a-zA-Z0-9\-\.]+\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$|^.*://$";
        NSPredicate *urlPre = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",reStr];
        if ([urlPre evaluateWithObject:metadataObject.stringValue]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:metadataObject.stringValue]];
        }else{
            self.isQRCodeCaptured = YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"信息" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            
//            _label.alpha = 1;
//            _label.text = metadataObject.stringValue;
            
        }
    }
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    self.isQRCodeCaptured = 0;
}

//- (void)restart{
//    _label.alpha = 0;
//    self.isQRCodeCaptured = NO;
//
//}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
