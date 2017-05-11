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
#import "SCWatermarkOverlayView.h"

@interface LZVideoDetailsVC ()<SCPlayerDelegate>
@property (strong, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
@property (strong, nonatomic) SCPlayer *player;
@end

@implementation LZVideoDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LZLocalizedString(@"video_details", nil);
    [self configNavigationBar];
    
    _player = [SCPlayer player];
    [self.player setLoopEnabled:YES];

    if ([[NSProcessInfo processInfo] activeProcessorCount] > 1) {
//        self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
        
        SCFilter *emptyFilter = [SCFilter emptyFilter];
        emptyFilter.name = @"#nofilter";
        
        self.filterSwitcherView.filters = @[
                                            emptyFilter,
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectChrome"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                            // Adding a filter created using CoreImageShop
                                            [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]],
                                            [self createAnimatedFilter]
                                            ];
        self.player.SCImageView = self.filterSwitcherView;
//        [self.filterSwitcherView addObserver:self forKeyPath:@"selectedFilter" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:self.player];
        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerView.frame = self.filterSwitcherView.frame;
        playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask;
        [self.filterSwitcherView.superview insertSubview:playerView aboveSubview:self.filterSwitcherView];
        [self.filterSwitcherView removeFromSuperview];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player setItemByAsset:self.recordSession.assetRepresentingSegments];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
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
    [button setTitle:@"保存到本地" forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
    [button sizeToFit];
    button.frame = CGRectMake(0, 0, CGRectGetWidth(button.bounds), 40);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
    [button addTarget:self action:@selector(navbarRightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

#pragma mark - Event
- (void)navbarRightButtonClickAction:(UIButton*)sender {
    [self saveToCameraRoll];
    return;
    
    NSURL *tempPath = [LZVideoTools filePathWithFileName:@"ConponVideo.mp4"];

//    4.导出
    WS(weakSelf);
    [LZVideoTools exportVideo:self.recordSession.assetRepresentingSegments videoComposition:nil filePath:tempPath timeRange:kCMTimeRangeZero completion:^(NSURL *savedPath) {
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

//创建动态滤镜
- (SCFilter *)createAnimatedFilter {
    SCFilter *animatedFilter = [SCFilter emptyFilter];
    animatedFilter.name = @"Animated Filter";
    
    SCFilter *gaussian = [SCFilter filterWithCIFilterName:@"CIGaussianBlur"];
    SCFilter *blackAndWhite = [SCFilter filterWithCIFilterName:@"CIColorControls"];
    
    [animatedFilter addSubFilter:gaussian];
    [animatedFilter addSubFilter:blackAndWhite];
    
    double duration = 0.5;
    double currentTime = 0;
    BOOL isAscending = YES;
    
    Float64 assetDuration = CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration);
    
    while (currentTime < assetDuration) {
        if (isAscending) {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@1 endValue:@0 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@0 endValue:@10 startTime:currentTime duration:duration];
        } else {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@0 endValue:@1 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@10 endValue:@0 startTime:currentTime duration:duration];
        }
        
        currentTime += duration;
        isAscending = !isAscending;
    }
    
    return animatedFilter;
}

//保存到相机卷
- (void)saveToCameraRoll {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    SCFilter *currentFilter = [self.filterSwitcherView.selectedFilter copy];
    [_player pause];
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    exportSession.videoConfiguration.filter = currentFilter;
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;
    exportSession.outputUrl = self.recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;
    
//    exportView.hidden = NO;
//    exportView.alpha = 0;
    
    SCWatermarkOverlayView *overlay = [SCWatermarkOverlayView new];
    overlay.date = self.recordSession.date;
    exportSession.videoConfiguration.overlay = overlay;
    
    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        if (strongSelf != nil) {
            [strongSelf.player play];
            strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
            
//            [UIView animateWithDuration:0.3 animations:^{
//                strongSelf.exportView.alpha = 0;
//            }];
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [exportSession.outputUrl saveToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                if (error == nil) {
                    [[[UIAlertView alloc] initWithTitle:@"已保存到相机卷" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"保存失败" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"保存失败" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

@end
