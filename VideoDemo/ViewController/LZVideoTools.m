//
//  LZVideoTools.m
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/3/29.
//  Copyright © 2017年 XBN. All rights reserved.
//

#import "LZVideoTools.h"

@implementation LZVideoTools

/**
 视频剪切+导出

 @param selectSegment 所选视频资源
 @param outputFilePath 导出路径
 @param completion 完成回调
 */
+ (void)cutVideoWith:(SCRecordSessionSegment *)selectSegment outputFilePath:(NSString *)outputFilePath completion:(void (^)(void))completion{
    
//    1.将素材拖入到素材库中
    AVAsset *asset = selectSegment.asset;
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];//素材的视频轨
    //    AVAssetTrack *audioAssertTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];//素材的音频轨
    
    
//    2.将素材的视频插入视频轨，音频插入音频轨
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];//这是工程文件
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];//视频轨道
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];//在视频轨道插入一个时间段的视频
    
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];//音频轨道
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];//插入音频数据，否则没有声音
    
    
//    3.裁剪视频，就是要将所有视频轨进行裁剪，就需要得到所有的视频轨，而得到一个视频轨就需要得到它上面所有的视频素材
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    CMTime totalDuration = CMTimeAdd(kCMTimeZero, asset.duration);
    
    CGFloat videoAssetTrackNaturalWidth = videoAssetTrack.naturalSize.width;
    CGFloat videoAssetTrackNaturalHeight = videoAssetTrack.naturalSize.height;
    CGSize renderSize = CGSizeMake(videoAssetTrackNaturalWidth, videoAssetTrackNaturalHeight);
    
    CGFloat renderW = MAX(renderSize.width, renderSize.height);
    CGFloat rate;
    rate = renderW / MIN(videoAssetTrackNaturalWidth, videoAssetTrackNaturalHeight);
    CGAffineTransform layerTransform = CGAffineTransformMake(videoAssetTrack.preferredTransform.a, videoAssetTrack.preferredTransform.b, videoAssetTrack.preferredTransform.c, videoAssetTrack.preferredTransform.d, videoAssetTrack.preferredTransform.tx * rate, videoAssetTrack.preferredTransform.ty * rate);
    //    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(videoAssetTrackNaturalWidth - videoAssetTrackNaturalHeight) / 2.0));//zhoubo fix 2017.03.31
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
    [layerInstruction setTransform:layerTransform atTime:kCMTimeZero];//得到视频素材
    [layerInstruction setOpacity:0.0 atTime:totalDuration];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);//得到视频轨道
    instruction.layerInstructions = @[layerInstruction];
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = @[instruction];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    mainComposition.renderSize = CGSizeMake(renderW, renderW);//裁剪出对应的大小
    
    
//    4.导出
    CMTime start = CMTimeMakeWithSeconds(selectSegment.startTime.floatValue, selectSegment.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(selectSegment.endTime.floatValue - selectSegment.startTime.floatValue, selectSegment.asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);

    
    [self compressVideo:composition videoComposition:mainComposition outputFilePath:outputFilePath timeRange:range completion:^(NSURL *savedPath) {
        if (completion) {
            completion();
            DLog(@"视频导出成功：%@", savedPath);
        }
    }];
}


/**
 导出视频

 @param asset 视频资源
 @param videoComposition 视频合成物
 @param path 导出路径
 @param range 时长范围
 @param completion 完成回调
 */
+ (void)compressVideo:(AVAsset *)asset videoComposition:(AVVideoComposition *)videoComposition outputFilePath:(NSString *)path timeRange:(CMTimeRange)range completion:(void (^)(NSURL *savedPath))completion {
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    session.videoComposition = videoComposition;
    session.outputURL = [NSURL fileURLWithPath:path];
    session.shouldOptimizeForNetworkUse = YES;
    session.outputFileType = AVFileTypeMPEG4;//AVFileTypeQuickTimeMovie
    session.timeRange = range;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ([session status] == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(session.outputURL);
                    DLog(@"视频导出成功：%@", [session.outputURL path]);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil);
                    DLog(@"视频导出失败：%@", [session.outputURL path]);
                }
            });
        }
    }];
}

@end
