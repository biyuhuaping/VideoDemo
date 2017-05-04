//
//  SAVideoRangeSlider.m
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Andrei Solovjev - http://solovjev.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SAVideoRangeSlider.h"
#import "LZImageView.h"

@interface SAVideoRangeSlider ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIView * centerView;
@property (nonatomic, strong) UIImageView * dragView;
@property (nonatomic, strong) NSURL * videoUrl;

@property (nonatomic, strong) UIImageView * leftThumb;
@property (nonatomic, strong) UIImageView * rightThumb;

@property (nonatomic) CGFloat frame_width;
@property (nonatomic) Float64 durationSeconds;

@end

@implementation SAVideoRangeSlider

#define SLIDER_BORDERS_SIZE 2.0f
#define BG_VIEW_BORDERS_SIZE 2.0f


- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    _frame_width = SCREEN_WIDTH;
    CGFloat height = self.bounds.size.height;
    _rightPosition = _frame_width;
    _leftPosition = 0;
    
    _bgView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, _frame_width, height)];
    _bgView.clipsToBounds = YES;
    [self addSubview:_bgView];
    
    _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _frame_width, 0)];
    [self addSubview:_topBorder];
    
    _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, height-SLIDER_BORDERS_SIZE, _frame_width, 0)];
    [self addSubview:_bottomBorder];
    
    _centerView = [[UIView alloc] initWithFrame:self.bounds];
    _centerView.backgroundColor = UIColorFromRGB(0x554c9a, 0.5);
    [self addSubview:_centerView];
    
    
    
    //拖拽视图
    _dragView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
    _dragView.image = [UIImage imageNamed:@"lz_videoedit_dragimage"];
    _dragView.center = CGPointMake(_centerView.frame.size.width/2, _centerView.frame.size.height/2);
    [self.centerView addSubview:_dragView];
    
    UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
    [_centerView addGestureRecognizer:centerPan];
    
    
    
    //left Thumb
    _leftThumb = [[LZImageView alloc] initWithFrame:CGRectMake(0, 0, 6, height)];
    _leftThumb.userInteractionEnabled = YES;
    _leftThumb.image = [UIImage imageNamed:@"lz_videoedit_slider"];
    [self addSubview:_leftThumb];
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [_leftThumb addGestureRecognizer:leftPan];
    
    
    
    //right Thumb
    _rightThumb = [[LZImageView alloc] initWithFrame:CGRectMake(0, 0, 6, height)];
    _rightThumb.userInteractionEnabled = YES;
    _rightThumb.image = [UIImage imageNamed:@"lz_videoedit_slider"];
    [self addSubview:_rightThumb];
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [_rightThumb addGestureRecognizer:rightPan];    
}

- (void)setMaxGap:(CGFloat)maxGap {
    _leftPosition = 0;
    _rightPosition = _frame_width*maxGap / _durationSeconds;
    _maxGap = maxGap;
}

- (void)setMinGap:(CGFloat)minGap {
    _leftPosition = 0;
    _rightPosition = _frame_width*minGap / _durationSeconds;
    _minGap = minGap;
}

- (void)delegateNotification
{
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)]){
        [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
}

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        if (_leftPosition < 0) {
            
            _leftPosition = 0;
        }
        
        if ((_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap)) ) {
            
            _leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        
        [self delegateNotification];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        [self hideBubble];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        _rightPosition += translation.x;
        if (_rightPosition < 0) {
            _rightPosition = 0;
        }
        
        if (_rightPosition > _frame_width){
            _rightPosition = _frame_width;
        }
        
        if (_rightPosition-_leftPosition <= 0){
            _rightPosition -= translation.x;
        }
        
        if ((_rightPosition-_leftPosition <= _leftThumb.frame.size.width+_rightThumb.frame.size.width) ||
            ((self.maxGap > 0) && (self.rightPosition-self.leftPosition > self.maxGap)) ||
            ((self.minGap > 0) && (self.rightPosition-self.leftPosition < self.minGap)) ) {
            _rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        
        [self delegateNotification];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        [self hideBubble];
    }
}

- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        _rightPosition += translation.x;
        
        if (_rightPosition > _frame_width || _leftPosition < 0) {
            _leftPosition -= translation.x;
            _rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
        
        [self delegateNotification];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        [self hideBubble];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset = _leftThumb.frame.size.width / 2;
    
    _leftThumb.center = CGPointMake(_leftPosition+inset,
                                    _leftThumb.frame.size.height / 2);
    
    _rightThumb.center = CGPointMake(_rightPosition-inset,
                                     _rightThumb.frame.size.height / 2);
    
    _topBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width,
                                  0,
                                  _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2,
                                  SLIDER_BORDERS_SIZE);
    
    _bottomBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width,
                                     _bgView.frame.size.height-SLIDER_BORDERS_SIZE,
                                     _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2,
                                     SLIDER_BORDERS_SIZE);
    
    _centerView.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width,
                                   _centerView.frame.origin.y,
                                   _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width,
                                   _centerView.frame.size.height);
    
    _dragView.center = CGPointMake(_centerView.frame.size.width/2,
                                   _centerView.frame.size.height/2);
}

#pragma mark - Video

- (void)getMovieFrame:(NSURL *)videoUrl {
    if ([self.bgView subviews].count > 0) {
        for (UIView * v in [self.bgView subviews]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [v removeFromSuperview];
            });
        }
    }
    
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(self.bgView.frame.size.width * 2, self.bgView.frame.size.height * 2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(self.bgView.frame.size.width, self.bgView.frame.size.height);
    }

    int picWidth = 20;
    
    // First image
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    if (halfWayImage != NULL) {
        UIImage *videoScreen;
        if ([self isRetina]) {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationRight];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
    
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect = tmp.frame;
        rect.size.width = picWidth;
        tmp.frame = rect;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bgView addSubview:tmp];
        });
        
        picWidth = tmp.frame.size.width;
        CGImageRelease(halfWayImage);
    }
    
    self.durationSeconds = CMTimeGetSeconds([myAsset duration]);
    
    int picsCnt = ceil(self.bgView.frame.size.width/picWidth);//返回大于或者等于指定表达式的最小整数
    
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    
    int time4Pic = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        int prefreWidth = 0;
        
        for (int i=1, ii=1; i<=picsCnt; i++){
            
            time4Pic = i*picWidth;
            
            CMTime timeFrame = CMTimeMakeWithSeconds(self.durationSeconds*time4Pic/self.bgView.frame.size.width, 600);
            
            [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame actualTime:NULL error:NULL];
            
            UIImage *videoScreen;
            if ([self isRetina]) {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationRight];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
        
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
            
            CGRect currentFrame = tmp.frame;
            currentFrame.origin.x = ii*picWidth;
            
            currentFrame.size.width = picWidth;
            prefreWidth += currentFrame.size.width;
            
            tmp.frame = currentFrame;
            int all = (ii+1)*tmp.frame.size.width;
            
            if (all > self.bgView.frame.size.width) {
                int delta = all - self.bgView.frame.size.width;
                currentFrame.size.width -= delta;
            }
            
            ii++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bgView addSubview:tmp];
            });
            
            CGImageRelease(halfWayImage);
        }
    }
}

#pragma mark - Properties

- (CGFloat)leftPosition {
    return _leftPosition * _durationSeconds / _frame_width;
}

- (void)setNewLeftPosition:(CGFloat)newleftPosition {
    
    if (newleftPosition == 0) {
        _leftPosition = 0;
    } else {
        _leftPosition = newleftPosition * _frame_width / _durationSeconds;
    }
    
    [self setNeedsLayout];
}

- (CGFloat)rightPosition {
    return _rightPosition * _durationSeconds / _frame_width;
}

- (void)setNewRightPosition:(CGFloat)newrightPosition {
    
    if (newrightPosition == 0) {
        _rightPosition = _frame_width;
    } else {
        _rightPosition = newrightPosition * _frame_width / _durationSeconds;
    }
    
    [self setNeedsLayout];
}

#pragma mark - Bubble

- (void)hideBubble
{
    if ([_delegate respondsToSelector:@selector(videoRange:didGestureStateEndedLeftPosition:rightPosition:)]){
        [_delegate videoRange:self didGestureStateEndedLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
}

#pragma mark - Helpers

- (BOOL)isRetina {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}


@end
