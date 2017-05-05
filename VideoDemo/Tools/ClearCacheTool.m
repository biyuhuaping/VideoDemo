//
//  ClearCacheTool.m
//  VideoDemo
//
//  Created by biyuhuaping on 2017/5/5.
//  Copyright © 2017年 biyuhuaping. All rights reserved.
//

#import "ClearCacheTool.h"

@implementation ClearCacheTool

/**
 清除缓存
 */
//触发清除缓存事件
+ (void)clearAction{
    NSString *path1 = NSTemporaryDirectory();
    NSString *path2 = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path3 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path4 = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSArray *array = @[path1,path2,path3,path4];
    
    CGFloat size = [self folderSizeAtPath:path1] + [self folderSizeAtPath:path2] + [self folderSizeAtPath:path3] + [self folderSizeAtPath:path4];
    NSString *message = size > 1 ? [NSString stringWithFormat:@"缓存%.2fM, 删除缓存", size] : [NSString stringWithFormat:@"缓存%.2fK, 删除缓存", size * 1024.0];
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        for (NSString *path in array) {
            [self cleanCaches:path];
        }
//    }];
    
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
//    [alert addAction:action];
//    [alert addAction:cancel];
//    [self showDetailViewController:alert sender:nil];
}

// 计算目录大小
+ (CGFloat)folderSizeAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 获取该目录下的文件，计算其大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // 将大小转化为M
        return size / 1000.0 / 1000.0;
    }
    return 0;
}

// 根据路径删除文件
+ (void)cleanCaches:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 获取该路径下面的文件名
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

@end
