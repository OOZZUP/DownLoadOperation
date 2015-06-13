//
//  DownLoadPauseButton.m
//  0611-下载-NSFileHandle
//
//  Created by lv on 15/6/11.
//  Copyright (c) 2015年 lv. All rights reserved.
//

#import "DownLoadPauseButton.h"

@implementation DownLoadPauseButton


// 重写progress的set方法

- (void)setProgress:(float)progress
{
    _progress = progress;
    
    // 设置按钮中进度的文字
    [self setTitle:[NSString stringWithFormat:@"%0.2f%%",progress * 100] forState:UIControlStateNormal];
    
    [self setNeedsDisplay];
//    self.enabled = NO;
}

- (void)drawRect:(CGRect)rect {
    
    // 贝塞尔路径
    /**
     1. 中心点
     2. 半径
     3. 起始角度
     4. 结束角度
     5. 顺时针
     */
    CGPoint point = CGPointMake(rect.size.width *0.5, rect.size.height *0.5);
    CGFloat radius = MIN(rect.size.width, rect.size.height) *0.5 - self.lineWidth;
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = 2 * M_PI * self.progress + startAngle;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    // 设置线条属性
    [path setLineWidth:self.lineWidth];
    [path setLineCapStyle:kCGLineCapRound];
    [self.lineColor setStroke];
    // 绘制边线路径
    [path stroke];
}
@end
