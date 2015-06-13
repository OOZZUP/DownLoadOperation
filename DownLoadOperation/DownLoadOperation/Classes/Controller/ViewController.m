//
//  ViewController.m
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//


#import "ViewController.h"
#import "DownLoadPauseButton.h"
#import "DownloadManage.h"
// URL改成自己的服务器路径
#define SERVER_URL @"http://localhost/video/TEST.mp4"

@interface ViewController ()<NSURLConnectionDataDelegate>

// 下载暂停按钮
@property (weak, nonatomic) IBOutlet DownLoadPauseButton *DownLoadPauseButton;

// URL
@property(nonatomic,strong)NSURL  *url;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// 暂停、移除当前下载的网络连接
- (IBAction)pause {
    [[DownloadManage sharedManage] pause:self.url];
}

// 开始下载
- (IBAction)startAndPause:(DownLoadPauseButton *)sender {
    // 获取服务器URL
    NSString *strUrl = SERVER_URL;
    strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    self.url = url;
    
    [[DownloadManage sharedManage]downloadWithURL:url progress:^(float progress) {
        // 主线程更新UI
        self.DownLoadPauseButton.progress = progress;
    } finshed:^(NSString *targetPath, NSError *error) {
        NSLog(@"targetPath:%@ error:%@ NSThread:%@",targetPath,error,[NSThread currentThread]);
    }];
}
@end
