//
//  SCRecordSessionSegment+LZAdd.h
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/29.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "SCRecorder.h"

@interface SCRecordSessionSegment (LZAdd)

@property (nonatomic, retain) NSNumber * isSelect;
@property (nonatomic, retain) NSNumber * isVoice;
@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSNumber * endTime;

@property (nonatomic, retain) NSNumber * isReverse;         //是否翻转
@property (nonatomic, retain) NSURL    * assetSourcePath;   //源路径
@property (nonatomic, retain) NSString * assetTargetPath;   //目标路径
@property (nonatomic, retain) NSNumber * maximum;           //当前剪切可以移动的最大限度

@end
