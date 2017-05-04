//
//  LZVideoTools.h
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/3/29.
//  Copyright © 2017年 XBN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCRecorder.h"
#import "SCRecordSessionSegment+LZAdd.h"

@interface LZVideoTools : NSObject

/**
 视频剪切+导出
 
 @param selectSegment 所选视频资源
 @param outputFilePath 导出路径
 @param completion 完成回调
 */
+ (void)cutVideoWith:(SCRecordSessionSegment *)selectSegment outputFilePath:(NSString *)outputFilePath completion:(void (^)(void))completion;


/**
 导出视频
 
 @param asset 视频资源
 @param videoComposition 视频合成物
 @param path 导出路径
 @param range 时长范围
 @param completion 完成回调
 */
+ (void)compressVideo:(AVAsset *)asset videoComposition:(AVVideoComposition *)videoComposition outputFilePath:(NSString *)path timeRange:(CMTimeRange)range completion:(void (^)(NSURL *savedPath))completion;

@end
