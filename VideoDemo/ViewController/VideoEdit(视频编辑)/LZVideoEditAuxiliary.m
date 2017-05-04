//
//  LZVideoEditAuxiliary.m
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/3/30.
//  Copyright © 2017年 XBN. All rights reserved.
//

#import "LZVideoEditAuxiliary.h"

@implementation LZVideoEditAuxiliary


/**
 获取当前segment

 @param recordSegments <#recordSegments description#>
 @param idx <#idx description#>
 @return <#return value description#>
 */
- (SCRecordSessionSegment *)getCurrentSegment:(NSArray *)recordSegments index:(NSInteger)idx {
    
    if (recordSegments.count == 0) {
        return nil;
    }
    
    SCRecordSessionSegment * segment = recordSegments[idx];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    return segment;
}



/**
 获取视频当前总时间长度

 @param recordSegments <#recordSegments description#>
 @return <#return value description#>
 */
- (float)getAllVideoTimesRecordSegments:(NSArray *)recordSegments {
    
    float time = 0;
    for (int i = 0; i < recordSegments.count; i++) {
        SCRecordSessionSegment * segment = recordSegments[i];
        if ([segment.startTime floatValue] > 0 || [segment.endTime floatValue] > 0) {
            time += ([segment.endTime floatValue]-[segment.startTime floatValue]);
        } else {
            time += CMTimeGetSeconds(segment.duration);
        }
    }
    
    return time;
}


/**
 更新进度条

 @param progressBar <#progressBar description#>
 @param recordSegments <#recordSegments description#>
 */
- (void)updateProgressBar:(ProgressBar *)progressBar :(NSArray *)recordSegments {
    [progressBar removeAllSubViews];
    
    for (int i = 0; i < recordSegments.count; i++) {
        SCRecordSessionSegment * segment = recordSegments[i];
        NSAssert(segment != nil, @"segment must be non-nil");
        CMTime currentTime = kCMTimeZero;
        if (segment) {
            
            CGFloat width = 0;
            if ([segment.startTime floatValue] > 0 || [segment.endTime floatValue] > 0) {
                width = ([segment.endTime floatValue] - [segment.startTime floatValue]) / MAX_VIDEO_DUR * SCREEN_WIDTH;
            } else {
                currentTime = segment.duration;
                width = CMTimeGetSeconds(currentTime) / MAX_VIDEO_DUR * SCREEN_WIDTH;
            }
            
            [progressBar setCurrentProgressToWidth:width];
            
            if ([segment.isSelect boolValue] == YES) {
                [progressBar setCurrentProgressToStyle:ProgressBarProgressStyleSelect andIndex:i];
            }
            else {
                [progressBar setCurrentProgressToStyle:ProgressBarProgressStyleNormal andIndex:i];
            }
        }
    }
}




/**
 更新剪切片段

 @param trimmerView <#trimmerView description#>
 @param recordSegments <#recordSegments description#>
 @param currentSelected <#currentSelected description#>
 */
- (void)updateTrimmerView:(SAVideoRangeSlider *)trimmerView recordSegments:(NSArray *)recordSegments index:(NSInteger)currentSelected{
    SCRecordSessionSegment *sessionSegment = [self getCurrentSegment:recordSegments index:currentSelected];
    [trimmerView getMovieFrame:sessionSegment.url];
    
    SCRecordSessionSegment * segment = sessionSegment;
    DLog(@"\r starttime:%f, \r endtime:%f \r url:%@ \r maximun: %f",
         segment.startTime.floatValue,
         segment.endTime.floatValue,
         segment.url,
         segment.maximum.floatValue);
    
    //剩余秒数
    float timeToSpare = 15 - [self getAllVideoTimesRecordSegments:recordSegments];
    //当前视频秒数
    float currentVideoTime = CMTimeGetSeconds(segment.duration);
    //当前视频截取的秒数
    float cutVideotime = [segment.endTime floatValue]-[segment.startTime floatValue];
    
    DLog(@"timeToSpare:%f, currentVideoTime:%f, cutVideotime:%f", timeToSpare, currentVideoTime, cutVideotime);
    
    //设置当前能移动的最大限度
    if (([segment.startTime floatValue] > 0 || [segment.endTime floatValue] > 0) && cutVideotime+timeToSpare < currentVideoTime) {
        [trimmerView setMaxGap:cutVideotime+timeToSpare];
    }
    else {
        [trimmerView setMaxGap:currentVideoTime];
    }
    
    [trimmerView setNewLeftPosition:[segment.startTime floatValue]];
    [trimmerView setNewRightPosition:[segment.endTime floatValue]];
}

@end
