//
//  LZLevelView.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/25.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZLevelView.h"
#import "XBNSensorManager.h"
#import "Masonry.h"

#define levelNoColor     UIColorFromRGB(0xe0e0e0, 1)
#define levelYesColor    UIColorFromRGB(0x36bb2a, 1)

#define bgViewWidth     (SCREEN_WIDTH-220*scale)

@implementation LZLevelView

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

- (void)initialize {
    
    self.hidden = YES;
    
    [self configView];
    
    [self addAutoLayout];
}

- (void)configView {
    
    [self addSubview:self.leftLine];
    [self addSubview:self.rightLine];
    [self addSubview:self.bgView];
}

- (void)addAutoLayout {
    
    WS(weakSelf);
    GET_SCREEN_SCALE(scale);
    [self.leftLine makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.centerY).with.offset(32);
        make.leading.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(110*scale, 3));
    }];
    
    [self.rightLine makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.centerY).with.offset(32);
        make.trailing.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(110*scale, 3));
    }];
    
    [self.bgView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.centerX);
        make.centerY.mas_equalTo(weakSelf.centerY).with.offset(32);
        make.size.mas_equalTo(CGSizeMake(bgViewWidth, bgViewWidth));
    }];
}

- (UIView *)leftLine {

    if (_leftLine == nil) {
        _leftLine = [[UIView alloc] init];
        _leftLine.backgroundColor = levelNoColor;
        _leftLine.layer.masksToBounds = YES;
        _leftLine.layer.cornerRadius = 1.5;
    }
    
    return _leftLine;
}

- (UIView *)rightLine {
    
    if (_rightLine == nil) {
        _rightLine = [[UIView alloc] init];
        _rightLine.backgroundColor = levelNoColor;
        _rightLine.layer.masksToBounds = YES;
        _rightLine.layer.cornerRadius = 1.5;
    }
    
    return _rightLine;
}

- (UIView *)bgView {

    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        [_bgView.layer addSublayer:self.lineLayer];
        [_bgView addSubview:self.pointView];
    }
    
    return _bgView;
}

- (CAShapeLayer *)lineLayer {

    if (_lineLayer == nil) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.frame = self.bgView.bounds;
        _lineLayer.contentsScale = [UIScreen mainScreen].scale;
        [_lineLayer addSublayer:self.solidLine];
    }
    
    return _lineLayer;
}

- (UIView *)pointView {

    if (_pointView == nil) {
        GET_SCREEN_SCALE(scale);
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(bgViewWidth/2-4, bgViewWidth/2-4, 8, 8)];
        _pointView.backgroundColor = levelNoColor;
        _pointView.layer.masksToBounds = YES;
        _pointView.layer.cornerRadius = 4;
    }
    
    return _pointView;
}

- (CAShapeLayer *)solidLine {

    if (_solidLine == nil) {
        //水平线
        GET_SCREEN_SCALE(scale);
        
        _solidLine = [CAShapeLayer layer];
        _solidLine.lineWidth = 3.0f;
        _solidLine.strokeColor = levelYesColor.CGColor;
        _solidLine.fillColor = [UIColor clearColor].CGColor;
        
        CGMutablePathRef solidPath = CGPathCreateMutable();
        CGPathAddEllipseInRect(solidPath, nil, CGRectMake(bgViewWidth/2-18, bgViewWidth/2-18, 36.0f, 36.0f));
        
        CGPoint aPoints1[2];                                        //坐标点
        aPoints1[0] =CGPointMake(0, bgViewWidth/2);                 //坐标1
        aPoints1[1] =CGPointMake(bgViewWidth/2-18, bgViewWidth/2);  //坐标2
        CGPathAddLines(solidPath, 0, aPoints1, 2);
        
        CGPoint aPoints2[2];                                        //坐标点
        aPoints2[0] =CGPointMake(bgViewWidth/2+18, bgViewWidth/2);  //坐标1
        aPoints2[1] =CGPointMake(bgViewWidth, bgViewWidth/2);       //坐标2
        CGPathAddLines(solidPath, 0, aPoints2, 2);
        
        _solidLine.path = solidPath;
        CGPathRelease(solidPath);
    }
    
    return _solidLine;
}

- (void)showLevelView {
    self.hidden = NO;
    
    WS(weakSelf);
    
    self.manager = [XBNSensorManager sharedInstance];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        weakSelf.manager.updateDeviceMotionBlock = ^(CMDeviceMotion *data){
            
            double rotation = [NSString stringWithFormat:@"%0.2f", atan2(data.gravity.x, data.gravity.y) - M_PI].doubleValue;
            weakSelf.bgView.transform = CGAffineTransformMakeRotation(rotation);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (fabs(rotation) < 0.01) {
                    weakSelf.leftLine.backgroundColor = levelYesColor;
                    weakSelf.rightLine.backgroundColor = levelYesColor;
//                    weakSelf.pointView.backgroundColor = levelYesColor;
                }
                else {
                    weakSelf.leftLine.backgroundColor = levelNoColor;
                    weakSelf.rightLine.backgroundColor = levelNoColor;
//                    weakSelf.pointView.backgroundColor = levelNoColor;
                }
            });
        };
    });
    
    [self.manager startGyroscope];
}

- (void)hideLevelView {
    self.hidden = YES;
    [self.manager stopGyroscope];
}



@end
