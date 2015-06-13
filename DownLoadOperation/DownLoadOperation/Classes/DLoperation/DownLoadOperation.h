//
//  DownLoadOperation.h
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadOperation : NSOperation

// 当前下载的URL
@property(nonatomic,strong)NSURL *url;

+ (instancetype)downloadOperation:(void (^)(float progress))progress finshed:(void (^)(NSString *targetPath,NSError *error))finshed;

// 下载指定的URL资源
- (void)downLoadWithURL:(NSURL *)url;

// 取消下载操作
- (void)pause;

@end
