//
//  LZVideoEditAuxiliary.h
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/3/30.
//  Copyright © 2017年 XBN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCRecordSessionSegment+LZAdd.h"
#import "ProgressBar.h"
#import "SAVideoRangeSlider.h"              //视频剪切

@interface LZVideoEditAuxiliary : NSObject

/**
 获取当前segment
 
 @param recordSegments <#recordSegments description#>
 @param idx <#idx description#>
 @return <#return value description#>
 */
- (SCRecordSessionSegment *)getCurrentSegment:(NSArray *)recordSegments index:(NSInteger)idx;


/**
 获取视频当前总时间长度
 
 @param recordSegments <#recordSegments description#>
 @return <#return value description#>
 */
- (float)getAllVideoTimesRecordSegments:(NSArray *)recordSegments;


/**
 更新进度条
 
 @param progressBar <#progressBar description#>
 @param recordSegments <#recordSegments description#>
 */
- (void)updateProgressBar:(ProgressBar *)progressBar :(NSArray *)recordSegments;


/**
 更新剪切片段
 
 @param trimmerView <#trimmerView description#>
 @param recordSegments <#recordSegments description#>
 @param currentSelected <#currentSelected description#>
 */
- (void)updateTrimmerView:(SAVideoRangeSlider *)trimmerView recordSegments:(NSArray *)recordSegments index:(NSInteger)currentSelected;

@end
