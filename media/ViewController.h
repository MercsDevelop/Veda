//
//  ViewController.h
//  Media
//
//  Created by Mercsjho on 16/4/25.
//  Copyright © 2016年 Mercsjho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface ViewController : UIViewController
{
    ///负责协调从截取设备到输出设备间的数据流动
    AVCaptureSession *session;
    ///负责实时预览目前相机设备截取到的画面
    AVCaptureVideoPreviewLayer *CaptureVideoPreviewLayer;
    ///用来连接数据的输入端口（例如图像）与输出目标（例如文件）
    AVCaptureConnection *videoConnection;
}

@property (strong, nonatomic)UIView *myView;
@property (strong, nonatomic)UIImageView *myImg;

@end

