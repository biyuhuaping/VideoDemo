//
//  LZImageView.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/2.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZImageView.h"

@implementation LZImageView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    CGFloat widthDelta = 22.0 - bounds.size.width;
    bounds = CGRectInset(bounds, -0.5*widthDelta, 0);
    return CGRectContainsPoint(bounds, point);
}

@end
