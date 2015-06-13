//
//  DownLoadPauseButton.h
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//
// IB_DESIGNABLE 表示这个类可以在 `IB` 中设计
// IBInspectable 表示属性可以在 `IB` 中定义
#import <UIKit/UIKit.h>

@interface DownLoadPauseButton : UIButton

// 进度
@property(nonatomic,assign)IBInspectable float progress;

// 线宽
@property(nonatomic,assign)IBInspectable CGFloat lineWidth;
// 线色
@property(nonatomic,strong)IBInspectable UIColor *lineColor;

// 是否下载
@property(nonatomic,assign,getter=isDownload)BOOL pauseAndGoOn;
@end
