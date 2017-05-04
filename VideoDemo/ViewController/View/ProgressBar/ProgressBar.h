//
//  ProcessBar.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SBCaptureDefine.h"

typedef enum {
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
    ProgressBarProgressStyleSelect
} ProgressBarProgressStyle;

@interface ProgressBar : UIView

@property (strong, nonatomic) NSMutableArray *progressViewArray;
@property (strong, nonatomic) UIImageView *progressIndicator;

+ (ProgressBar *)getInstance;

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style;
- (void)setLastProgressToWidth:(CGFloat)width;
- (void)setCurrentProgressToWidth:(CGFloat)width;
- (void)setCurrentProgressToStyle:(ProgressBarProgressStyle)style andIndex:(NSInteger)idx;
- (void)refreshCurrentView:(NSInteger)idx andWidth:(CGFloat)width;

- (void)deleteLastProgress;
- (void)addProgressView;

- (void)stopShining;
- (void)startShining;

- (void)removeAllSubViews;


@end
