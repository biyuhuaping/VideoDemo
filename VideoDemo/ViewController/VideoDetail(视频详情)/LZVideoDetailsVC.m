//
//  LZVideoDetailsVC.m
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/4/19.
//  Copyright © 2017年 XBN. All rights reserved.
//  视频详情

#import "LZVideoDetailsVC.h"
#import "LZVideoEditClipVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LZVideoTools.h"

@interface LZVideoDetailsVC ()
@property (strong, nonatomic) IBOutlet SCVideoPlayerView *videoPlayerView;
@end

@implementation LZVideoDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LZLocalizedString(@"video_details", nil);
    [self configNavigationBar];
    [self.videoPlayerView.player setLoopEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.videoPlayerView.player setItemByAsset:self.recordSession.assetRepresentingSegments];
    [self.videoPlayerView.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoPlayerView.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - configViews
//配置navi
- (void)configNavigationBar{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.selected = NO;
    [button setTitle:LZLocalizedString(@"next", nil) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
    [button sizeToFit];
    button.frame = CGRectMake(0, 0, CGRectGetWidth(button.bounds), 40);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
    [button addTarget:self action:@selector(navbarRightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

#pragma mark - Event
- (void)navbarRightButtonClickAction:(UIButton*)sender {
    NSString * temppath = NSTemporaryDirectory();
    temppath = [temppath stringByAppendingPathComponent:@"ExportVideo"];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:temppath isDirectory:NULL];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:temppath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    temppath = [temppath stringByAppendingPathComponent:@"ConponVideo.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temppath isDirectory:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:temppath error:NULL];
    }
    
    DLog(@"%@", temppath);
    
    WS(weakSelf);
    //    4.导出
    [LZVideoTools compressVideo:self.recordSession.assetRepresentingSegments videoComposition:nil outputFilePath:temppath timeRange:kCMTimeRangeZero completion:^(NSURL *savedPath) {
        if(savedPath) {
            DLog(@"导出视频路径：%@", savedPath);
            //保存到本地
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:savedPath]) {
                [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:savedPath completionBlock:NULL];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else {
            DLog(@"导出视频路径出错：%@", savedPath);
        }
    }];
}

- (IBAction)cutVideoButton:(UIButton *)sender {
    LZVideoEditClipVC * vc = [[LZVideoEditClipVC alloc] initWithNibName:@"LZVideoEditClipVC" bundle:nil];
    vc.recordSession = self.recordSession;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
