//
//  DownLoadOperation.m
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//

#import "DownLoadOperation.h"

@interface DownLoadOperation()
// 文件总大小
@property(nonatomic,assign)long long expectedContentLength;

// 文件当前大小
@property(nonatomic,assign)long long fileSize;

// 接受文件数据
@property(nonatomic,strong)NSMutableData *fileData;

// 文件流
@property(nonatomic,strong)NSOutputStream *fileStream;

// 当前下载的网络连接
@property(nonatomic,strong)NSURLConnection *connection;

// 下载目标路径
@property(nonatomic,copy)NSString  *targetPath;

// block 回调属性
@property(nonatomic,copy)void(^progressBlock)(float);
@property(nonatomic,copy)void(^finshedBlock)(NSString *,NSError *);
@end

@implementation DownLoadOperation

// 重写main方法
- (void)main
{
    @autoreleasepool {
        [self downLoadWithURL:self.url];
    }
}


+ (instancetype)downloadOperation:(void (^)(float progress))progress finshed:(void (^)(NSString *targetPath,NSError *error))finshed
{
    // 断言，要求必须传入回调，progress可选
    NSAssert(finshed !=nil, @"必须传入finshed回调");
    
    DownLoadOperation *obj = [[DownLoadOperation alloc]init];
    
    // 记录block (保存到属性，需要的时候进行执行)
    obj.progressBlock = progress;
    obj.finshedBlock = finshed;
    
    return obj;
}


// 下载URL对应资源
- (void)downLoadWithURL:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // * 检查服务器文件信息
        [self checkServerFileInfo:url];
        
        // * 检查本地文件信息
        self.fileSize = [self checkLocalFileInfo];
        NSLog(@"本地文件大小:%lld",self.fileSize);
        
        // 判断本地文件与服务器文件大小
        // 如果本地文件与服务器文件大小相等，直接返回不做下载
        if (self.fileSize == self.expectedContentLength) {
            NSLog(@"此文件已下载！");
            
            if (self.progressBlock != nil) {
                self.progressBlock(1);
            }
            
            // 主线程回调，通知调用方，下载完成
            dispatch_async(dispatch_get_main_queue(), ^{
                self.finshedBlock(self.targetPath,nil);
            });
            return ;
        }
        // 否则本地文件比服务器文件小，继续下载
        // 创建请求 断点续传 - 不能从本地加载缓存
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
        
        // range头
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-",self.fileSize];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 请求连接
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        // 利用runLoop监听设置代理的消息，否则代理方法不会执行
        [[NSRunLoop currentRunLoop]run];
        
        NSLog(@"come here %@",[NSThread currentThread]);
        
    });
}

/**
 *  取消下载操作
 */

- (void)pause
{
    [self.connection cancel];
}

// 检查服务器文件信息
- (void)checkServerFileInfo:(NSURL *)url
{
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    // 向服务器发送请求（同步方法，如果检查没执行完毕，后续的操作都不会执行）
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    // 获取服务器的响应
    // 1.目标文件大小
    self.expectedContentLength = response.expectedContentLength;
    // 2.目标文件路径
    self.targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
    NSLog(@"目标文件路径：%@",self.targetPath);
}

///  检查本地文件信息
- (long long)checkLocalFileInfo
{
    NSFileManager *manager = [NSFileManager defaultManager];
    long long localFileSize = 0;
    // 检查本地是否存在文件
    if ([manager fileExistsAtPath:self.targetPath]) {
        // 获取本地文件的大小
        NSDictionary *attr = [manager attributesOfItemAtPath:self.targetPath error:NULL];
        NSLog(@"%@",attr);

        // 利用字典的分类获取文件的大小
        localFileSize = attr.fileSize;
    }
    
    // 如果本地文件>服务器的文件，直接删除
    if (localFileSize > self.expectedContentLength) {
        [manager removeItemAtPath:self.targetPath error:NULL];
        localFileSize = 0;
    }
    return localFileSize;
}

#pragma mark - 代理方法

// 1.获得服务器响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"1. %@",[NSThread currentThread]);
    
    // 创建并打开流
    self.fileStream = [[NSOutputStream alloc]initToFileAtPath:self.targetPath append:YES];
    [self.fileStream open];
}

// 2.获取到服务器的响应数据(此方法执行多次)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 文件大小累加
    self.fileSize += data.length;
    
    // 下载进度
    float progress = (float)self.fileSize / self.expectedContentLength;
    NSLog(@"文件大小：%lld，完成进度:%0.2f%%",self.fileSize,progress * 100);
    
    // 拼接接受的二进制数据
    [self.fileStream write:data.bytes maxLength:data.length];
    
    // 执行进度回调block
    self.progressBlock(progress);
    
}

// 3.断开连接

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 设置fileSize为0
    self.fileSize = 0;
    
    // 关闭流
    [self.fileStream close];
    NSLog(@"数据下载完成，断开连接！");
    
    // 主线程回调 - 前面使用过断言所以这里不必判断
    dispatch_async(dispatch_get_main_queue(), ^{
        self.finshedBlock(self.targetPath,nil);
    });

}
// 4.网络连接错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.fileStream close];
    
    // 主线程回调
    dispatch_async(dispatch_get_main_queue(), ^{
        self.finshedBlock(@"zz:网络连接错误",error);
    });

}

#pragma mark - 懒加载

- (NSMutableData *)fileData
{
    if (_fileData == nil) {
        _fileData = [[NSMutableData alloc]init];
    }
    return _fileData;
}

@end
