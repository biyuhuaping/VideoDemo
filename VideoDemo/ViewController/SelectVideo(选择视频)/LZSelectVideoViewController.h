//
//  LZSelectVideoViewController.h
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/9.
//  Copyright © 2016年 XBN. All rights reserved.
//  选择视频页面

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface LZSelectVideoViewController : UIViewController
@property (nonatomic, strong) SCRecordSession * recordSession;
@property (nonatomic, strong) NSMutableArray * videoListSegmentArrays;
@end
