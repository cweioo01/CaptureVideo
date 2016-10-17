//
//  ViewController.m
//  CaptureVideo
//
//  Created by ChenWei on 16/10/17.
//  Copyright © 2016年 cw. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;

@property (weak, nonatomic)  UIImageView *imageOne;
@property (weak, nonatomic)  UIImageView *imageTwo;
@property (weak, nonatomic) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageOne = [[UIImageView alloc] init];
    imageOne.backgroundColor = [UIColor redColor];
    imageOne.frame = CGRectMake(25, 30, 150, 150);
    self.imageOne = imageOne;
    
    
    UIImageView *imageTwo = [[UIImageView alloc] init];
    imageTwo.frame = CGRectMake(50, 60, 50, 50);
    self.imageTwo = imageTwo;
    
    [self.view addSubview:imageOne];
    [self.view addSubview:imageTwo];
    
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(100, 200, 60, 60);
    button.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    self.button = button;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    self.session = session;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    NSError *error ;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    self.input = input;
    if (input) {
        if ([session canAddInput:input]) {
            [session addInput:input];
        }else {
            NSLog(@"session无法添加input");
        }
    }
    
    
    AVCaptureVideoPreviewLayer *videoPreViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    videoPreViewLayer.frame = self.view.bounds;
    
//    [self.view.layer addSublayer:videoPreViewLayer];
    [self.view.layer insertSublayer:videoPreViewLayer atIndex:0];
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.videoSettings =  @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
    
    
    NSLog(@"可用的格式availableImageDataCVPixelFormatTypes = ");
    
    NSLog(@"可用的格式availableImageDataCodecTypes=  ");
        NSError *lockError = nil;
//    [device lockForConfiguration:&lockError];
//    
//    device.activeVideoMaxFrameDuration =  CMTimeMake(1, 15);
//    [device unlockForConfiguration];
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }else {
        NSLog(@"不能添加StillImageOutput");
    }
    
    self.output = output;
    
    [session startRunning];
    
    self.device = device;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)buttonClick {
    dispatch_queue_t queue = dispatch_queue_create("imageFromVideo", DISPATCH_QUEUE_CONCURRENT);
    
    
    [self.output setSampleBufferDelegate:self queue:queue];
    

    
//    AVCaptureConnection *videoConnection = nil;
//    
//    
//    for (AVCaptureConnection *connection in  [_output connections]) {
//        for (AVCaptureInputPort *inputPort in connection.inputPorts) {
//            if ([inputPort.mediaType isEqual:AVMediaTypeVideo] ) {
//                videoConnection = connection;
//            }
//        }
//        if (videoConnection != nil) {
//            break;
//        }
//    }
//    
    [self.session startRunning];
    
    
//    AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPorts:@[self.input] output:output];
    
//    [_output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//        
//       UIImage *image1 = [self imageFromSampleBuffer:imageDataSampleBuffer];
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            
//            self.imageOne.image = image1;
//        });
//        
//    }];

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
     UIImage *image2 =  [self imageFromSampleBuffer:sampleBuffer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.imageOne.image = image2;
        [self.button setImage:image2 forState:UIControlStateNormal];
        [self.button setTitle:@"button" forState:UIControlStateNormal];
    });
}




- (IBAction)record:(id)sender {
}
- (IBAction)exitCamera:(id)sender {
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
   
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}




@end
