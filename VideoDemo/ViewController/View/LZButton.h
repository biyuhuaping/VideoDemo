//
//  LZButton.h
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/24.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZButton : UIButton

- (void)setLoopImages:(NSArray *)images;
- (void)setLoopImages:(NSArray *)images andHighlightedImages:(NSArray *)highlightedImages;

@property (nonatomic) NSUInteger currentIndex;

@end
