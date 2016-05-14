//
//  ViewController.m
//  Media
//
//  Created by Mercsjho on 16/4/25.
//  Copyright © 2016年 Mercsjho. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

@interface ViewController ()

@property (strong ,nonatomic) UIButton *startBtn;
@property (strong ,nonatomic) UIButton *stopBtn;
@property (strong ,nonatomic) UIButton *takeBtn;

@end

@implementation ViewController
- (void)viewDidAppear:(BOOL)animated {
    CaptureVideoPreviewLayer.frame = self.myView.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup ater loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    session = [AVCaptureSession new];
    //设置未来获取的画面质量为相片质量（最高质量）
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    //循环中设置要搜索的设备类型为vedio(相机)
    for(AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]){
        //选用后置摄像头
        if ([device position] == AVCaptureDevicePositionBack) {
            //将后置摄像头设置为session的数据来源
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            [session addInput:input];
        }
    }
    
    //设置session的输出端为stillImage(静态图片)，格式为JPEG
    AVCaptureStillImageOutput *outPut = [AVCaptureStillImageOutput new];
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    [outPut setOutputSettings:outputSettings];
    [session addOutput:outPut];
    
    //应用layer的方式将镜头目前“看到”的图像实时显示到view组件上
    CaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    CaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.myView.layer addSublayer:CaptureVideoPreviewLayer];
    
    [self createView];
}

#pragma 创建界面
- (void)createView {
    __weak typeof(self) wSelf = self;
    //imgView
    self.myImg = [[UIImageView alloc] init];
    [self.view addSubview:self.myImg];
    [self.myImg mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(wSelf.view.mas_left).left.offset(30);
        make.top.equalTo(wSelf.view.mas_top).top.offset(30);
        make.width.mas_equalTo(40);
    }];
    self.myView.backgroundColor = [UIColor clearColor];
    //开始按钮
    self.startBtn = [UIButton new];
    [self.view addSubview:self.startBtn];
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(wSelf.myImg.mas_left).left.offset(15);
        make.top.equalTo(wSelf.view.mas_top).top.offset(30);
        make.width.mas_equalTo(40);
    }];
    self.startBtn.backgroundColor = [UIColor cyanColor];
    self.startBtn.titleLabel.text = NSLocalizedString(@"开始", nil);
    self.startBtn.titleLabel.textColor = [UIColor purpleColor];
    [self.startBtn addTarget:self action:@selector(startButton:) forControlEvents:UIControlEventTouchUpInside];
    //停止按钮
    self.stopBtn = [UIButton new];
    [self.view addSubview:self.stopBtn];
    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(wSelf.startBtn.mas_left).left.offset(15);
        make.top.equalTo(wSelf.view.mas_top).top.offset(30);
        make.width.mas_equalTo(40);
    }];
    self.stopBtn.backgroundColor = [UIColor cyanColor];
    self.stopBtn.titleLabel.text = NSLocalizedString(@"停止", nil);
    self.stopBtn.titleLabel.textColor = [UIColor purpleColor];
    [self.stopBtn addTarget:self action:@selector(stopButton:) forControlEvents:UIControlEventTouchUpInside];
    //停止按钮
    self.takeBtn = [UIButton new];
    [self.view addSubview:self.takeBtn];
    [self.takeBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(wSelf.stopBtn.mas_left).left.offset(15);
        make.top.equalTo(wSelf.view.mas_top).top.offset(30);
        make.width.mas_equalTo(40);
    }];
    self.takeBtn.backgroundColor = [UIColor cyanColor];
    self.takeBtn.titleLabel.text = NSLocalizedString(@"获取", nil);
    self.takeBtn.titleLabel.textColor = [UIColor purpleColor];
    [self.takeBtn addTarget:self action:@selector(takeButton:) forControlEvents:UIControlEventTouchUpInside];
    //view
    self.myView = [[UIView alloc] init];
    [self.view addSubview:self.myView];
    [self.myView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(wSelf.view.mas_left).left.offset(30);
        make.top.equalTo(wSelf.takeBtn.mas_top).top.offset(30);
        make.size.mas_equalTo(CGSizeMake(200, 300));
    }];
    self.myView.backgroundColor = [UIColor clearColor];
}

#pragma 点击事件
- (void)startButton:(id)sender {
    //开始取得数据
    [session startRunning];
}

- (void)stopButton:(id)sender {
    //停止取得数据
    [session stopRunning];
}

- (void)takeButton:(id)sender {
    //必须在session中找出获取设备的输出端口为video的connection
    for (AVCaptureConnection *connection in ((AVCaptureStillImageOutput *)session.outputs[0]).connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (connection) {
            break;
        }
    }
    
    [session.outputs[0] captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer,NSError *error){
        CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
            //解析exif信息
            NSDictionary *dictExif = (__bridge NSDictionary *)exifAttachments;
            for (NSString *key in dictExif) {
                NSLog(@"%@ : %@", key, [dictExif valueForKey:key]);
            }
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        //将图片显示在预览的UIImage组件上
        self.myImg.image = [[UIImage alloc] initWithData:imageData];
        //图片存盘
        UIImageWriteToSavedPhotosAlbum(self.myImg.image, nil, nil, nil);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
