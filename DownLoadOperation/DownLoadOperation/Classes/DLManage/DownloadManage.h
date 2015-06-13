//
//  DownloadManage.h
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManage : NSObject

// 全局入口
+ (instancetype)sharedManage;

// 下载URL对应的文件

- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float progress)) progress finshed:(void (^)(NSString *targetPath,NSError *error)) finshed;

///  暂停指定url的操作
- (void)pause:(NSURL *)url;
@end
