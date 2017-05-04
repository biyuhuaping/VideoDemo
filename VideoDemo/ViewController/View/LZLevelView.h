//
//  LZLevelView.h
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/25.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBNSensorManager;

@interface LZLevelView : UIView

@property (nonatomic, strong) UIView * leftLine;
@property (nonatomic, strong) UIView * rightLine;
@property (nonatomic, strong) UIView * bgView;

@property (nonatomic, strong) CAShapeLayer * lineLayer;
@property (nonatomic, strong) UIView * pointView;
@property (nonatomic, strong) CAShapeLayer * solidLine;

@property (nonatomic, strong) XBNSensorManager *manager;

- (void)showLevelView;
- (void)hideLevelView;

@end
