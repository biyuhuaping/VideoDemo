//
//  SCRecordSessionSegment+LZAdd.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/29.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "SCRecordSessionSegment+LZAdd.h"
#import <objc/runtime.h>

@implementation SCRecordSessionSegment (LZAdd)

@dynamic isSelect;
@dynamic isVoice;
@dynamic startTime;
@dynamic endTime;
@dynamic isReverse;
@dynamic assetSourcePath;
@dynamic assetTargetPath;
@dynamic maximum;

//是否选中
- (void)setIsSelect:(NSNumber *)isSelect {
    objc_setAssociatedObject(self, @selector(isSelect), isSelect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)isSelect {
    return objc_getAssociatedObject(self, @selector(isSelect));
}

//是否关闭声音
- (void)setIsVoice:(NSNumber *)isVoice{
    objc_setAssociatedObject(self, @selector(isVoice), isVoice, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)isVoice {
    return objc_getAssociatedObject(self, @selector(isVoice));
}

//截取起始时间
- (void)setStartTime:(NSNumber *)startTime {
    objc_setAssociatedObject(self, @selector(startTime), startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)startTime {
    return objc_getAssociatedObject(self, @selector(startTime));
}

//截取结束时间
- (void)setEndTime:(NSNumber *)endTime {
    objc_setAssociatedObject(self, @selector(endTime), endTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)endTime {
    return objc_getAssociatedObject(self, @selector(endTime));
}

//是否倒序播放
- (void)setIsReverse:(NSNumber *)isReverse{
    objc_setAssociatedObject(self, @selector(isReverse), isReverse, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)isReverse {
    return objc_getAssociatedObject(self, @selector(isReverse));
}

//源路径
- (void)setAssetSourcePath:(NSURL *)assetSourcePath {
    objc_setAssociatedObject(self, @selector(assetSourcePath), assetSourcePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURL *)assetSourcePath {
    return objc_getAssociatedObject(self, @selector(assetSourcePath));
}

//目标路径
- (void)setAssetTargetPath:(NSString *)assetTargetPath{
    objc_setAssociatedObject(self, @selector(assetTargetPath), assetTargetPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)assetTargetPath {
    return objc_getAssociatedObject(self, @selector(assetTargetPath));
}

//
- (void)setMaximum:(NSNumber *)maximum {
    objc_setAssociatedObject(self, @selector(maximum), maximum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)maximum {
    return objc_getAssociatedObject(self, @selector(maximum));
}

@end
