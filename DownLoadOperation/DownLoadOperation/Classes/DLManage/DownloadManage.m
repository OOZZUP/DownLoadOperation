//
//  DownloadManage.m
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//

#import "DownloadManage.h"
#import "DownLoadOperation.h"

@interface DownloadManage ()

// 下载操作缓冲池
@property(nonatomic,strong)NSMutableDictionary  *operationCache;

// 全局下载队列
@property(nonatomic,strong)NSOperationQueue *queue;


@end

@implementation DownloadManage

+ (instancetype)sharedManage
{
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float))progress finshed:(void (^)(NSString *, NSError *))finshed
{
    if (self.operationCache[url] != nil) {
        NSLog(@"正在玩命下载中...请稍候！");
        return;
    }
    
    // 实例化下载操作
    DownLoadOperation *dlop = [DownLoadOperation downloadOperation:progress finshed:^(NSString *targetPath, NSError *error) {
        
        
        [self.operationCache removeObjectForKey:url];
        
        // 执行调用方传递的 finishedBlock
        finshed(targetPath, error);
    }];
    
    // 将操作添加到缓冲池中
    [self.operationCache setObject:dlop forKey:url];
    
    // 设置下载操作的URL
    dlop.url = url;
    
    // 将自定义的操作添加到队列中
    [self.queue addOperation:dlop];
}

// 暂停下载操作
- (void)pause:(NSURL *)url
{
    DownLoadOperation *op = self.operationCache[url];
    
    if (op == nil) {
        NSLog(@"没有要暂停的下载操作");
        return;
    }
    // 取消操作
    [op pause];
    
    // 在缓冲池中删除该下载操作
    [self.operationCache removeObjectForKey:url];
    
}

#pragma mark - 懒加载

- (NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
        
        // 设置最大并发数
        _queue.maxConcurrentOperationCount = 2;
    }
    return _queue;
}

- (NSMutableDictionary *)operationCache
{
    if (_operationCache == nil) {
        _operationCache = [NSMutableDictionary dictionary];
    }
    return _operationCache;
}

@end
