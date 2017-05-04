//
//  ProcessBar.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import "ProgressBar.h"
#import "SBCaptureToolKit.h"
#import "SBCaptureToolKit.h"

#define BAR_BLUE_COLOR      UIColorFromRGB(0x36bb2a, 1)
#define BAR_RED_COLOR       UIColorFromRGB(0xfa5a5a, 1)
#define BAR_BG_COLOR        UIColorFromRGB(0x454545, 1)
#define BAR_SELECT_COLOR    UIColorFromRGB(0x554c9a, 1)

#define BAR_H               7.5
#define BAR_MIN_W           75
#define INDICATOR_W         5
#define TIMER_INTERVAL      1.0f

@interface ProgressBar ()

@property (strong, nonatomic) UIView *barView;

@property (strong, nonatomic) NSTimer *shiningTimer;

@end

@implementation ProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    GET_SCREEN_SCALE(scale);
    self.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundColor = BAR_BG_COLOR;
    self.progressViewArray = [[NSMutableArray alloc] init];
    
    //barView
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BAR_H)];
    _barView.backgroundColor = BAR_BG_COLOR;
    [self addSubview:_barView];
    
    //最短分割线
    UIView *intervalView = [[UIView alloc] initWithFrame:CGRectMake(BAR_MIN_W*scale, 0, 1, BAR_H)];
    intervalView.backgroundColor = [UIColor blackColor];
    [_barView addSubview:intervalView];
    
    //indicator
    self.progressIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_W, BAR_H)];
    _progressIndicator.backgroundColor = UIColorFromRGB(0xff6600, 1);
    _progressIndicator.center = CGPointMake(0, BAR_H / 2);
    [self addSubview:_progressIndicator];
}

- (UIView *)getProgressView
{
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, BAR_H)];
    progressView.backgroundColor = BAR_BLUE_COLOR;
    progressView.autoresizesSubviews = YES;
    
    return progressView;
}

- (void)refreshIndicatorPosition
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        _progressIndicator.center = CGPointMake(0, BAR_H / 2);
        return;
    }
    
    _progressIndicator.center = CGPointMake(MIN(lastProgressView.frame.origin.x + lastProgressView.frame.size.width, self.frame.size.width - _progressIndicator.frame.size.width / 2 + 2), BAR_H / 2);
}

- (void)refreshCurrentView:(NSInteger)idx andWidth:(CGFloat)width {

    if (self.progressViewArray.count == 0) {
        return;
    }

    for (int i = 0; i < self.progressViewArray.count; i++) {

        if (i > idx) {
            
            UIView * foreProgressView = self.progressViewArray[i-1];
            CGRect foreViewFrame = foreProgressView.frame;
            
            UIView *currentProgressView = self.progressViewArray[i];
            CGRect frame = currentProgressView.frame;
            frame.origin.x = foreViewFrame.origin.x+foreViewFrame.size.width+1;
            
            if (i == idx) {
                frame.size.width = width - 1;
            }
            
            currentProgressView.frame = frame;
        }
        else {
            UIView *currentProgressView = self.progressViewArray[idx];
            CGRect frame = currentProgressView.frame;
            frame.size.width = width - 1;
            currentProgressView.frame = frame;
        }
    }
}

- (void)onTimer:(NSTimer *)timer
{
    [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
        _progressIndicator.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
            _progressIndicator.alpha = 1;
        }];
    }];
}

#pragma mark - method
- (void)startShining
{
    self.shiningTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)stopShining
{
    [_shiningTimer invalidate];
    self.shiningTimer = nil;
    _progressIndicator.alpha = 1;
}

- (void)addProgressView
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    CGFloat newProgressX = 0.0f;
    
    if (lastProgressView) {
        CGRect frame = lastProgressView.frame;
        frame.size.width -= 1;
        lastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
    }
    
    UIView *newProgressView = [self getProgressView];
    
    [SBCaptureToolKit setView:newProgressView toOriginX:newProgressX];
    [_barView addSubview:newProgressView];
    
    [_progressViewArray addObject:newProgressView];
}

- (void)setLastProgressToWidth:(CGFloat)width
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    [SBCaptureToolKit setView:lastProgressView toSizeWidth:width];
    [self refreshIndicatorPosition];
}

- (void)setCurrentProgressToWidth:(CGFloat)width {

    UIView *lastProgressView = [_progressViewArray lastObject];
    CGFloat newProgressX = 0.0f;
    if (!lastProgressView) {
        UIView *newProgressView = [self getProgressView];
        [SBCaptureToolKit setView:newProgressView toOriginX:newProgressX];
        [SBCaptureToolKit setView:newProgressView toSizeWidth:width];
        [_barView addSubview:newProgressView];
        [_progressViewArray addObject:newProgressView];
    }
    else {
        CGRect frame = lastProgressView.frame;
        frame.size.width -= 1;
        lastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
        
        UIView *newProgressView = [self getProgressView];
        [SBCaptureToolKit setView:newProgressView toOriginX:newProgressX];
        [SBCaptureToolKit setView:newProgressView toSizeWidth:width];
        [_barView addSubview:newProgressView];
        [_progressViewArray addObject:newProgressView];
    }
    
    [self refreshIndicatorPosition];
}

- (void)setCurrentProgressToStyle:(ProgressBarProgressStyle)style andIndex:(NSInteger)idx {
    UIView * currentProgressView = [_progressViewArray objectAtIndex:idx];
    if (!currentProgressView) {
        return;
    }
    
    switch (style) {
        case ProgressBarProgressStyleSelect:
        {
            currentProgressView.backgroundColor = BAR_SELECT_COLOR;
        }
            break;
        case ProgressBarProgressStyleNormal:
        {
            currentProgressView.backgroundColor = BAR_BLUE_COLOR;
        }
            break;
        default:
            break;
    }
}

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    switch (style) {
        case ProgressBarProgressStyleDelete:
        {
            lastProgressView.backgroundColor = BAR_RED_COLOR;
            _progressIndicator.hidden = YES;
        }
            break;
        case ProgressBarProgressStyleNormal:
        {
            lastProgressView.backgroundColor = BAR_BLUE_COLOR;
            _progressIndicator.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)deleteLastProgress
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    [lastProgressView removeFromSuperview];
    [_progressViewArray removeLastObject];
    
    _progressIndicator.hidden = NO;
    
    [self refreshIndicatorPosition];
}

- (void)removeAllSubViews {
    for (UIView * v in self.progressViewArray) {
        [v removeFromSuperview];
    }
    [self.progressViewArray removeAllObjects];
}

+ (ProgressBar *)getInstance
{
    ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BAR_H)];
    return progressBar;
}

@end
























