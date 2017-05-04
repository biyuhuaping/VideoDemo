//
//  LZTrimCropViewController.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/9.
//  Copyright © 2016年 XBN. All rights reserved.
//  选择视频剪切页面

#import "LZTrimCropViewController.h"
#import "Masonry.h"

//#import "GVUserDefaults+LZProperties.h"
//#import "UINavigationBar+BackgroundColor.h"

#import "ProgressBar.h"

#import "SCRecordSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SAVideoRangeSlider.h"              //视频剪切
#import "LZVideoTools.h"
#import "LZVideoEditAuxiliary.h"

@interface LZTrimCropViewController () <SAVideoRangeSliderDelegate>

//views
@property (nonatomic, strong) ProgressBar           * progressBar;
@property (nonatomic, strong) SCVideoPlayerView     * videoPlayerView;

@property (nonatomic, strong) SAVideoRangeSlider    * trimmerView;

@property (nonatomic, strong) UIButton              * nextButton;
@property (nonatomic, strong) NSMutableArray        * recordSegments;
@property (strong, nonatomic) AVAssetExportSession  * exportSession;
@property (nonatomic, strong) LZVideoEditAuxiliary *videoEditAuxiliary;

@end

@implementation LZTrimCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LZLocalizedString(@"trim_crop", nil);
    self.view.backgroundColor = UIColorFromRGB(0x000000, 1);
    self.videoEditAuxiliary = [[LZVideoEditAuxiliary alloc]init];

    self.recordSegments = [NSMutableArray arrayWithArray:self.recordSession.segments];
    self.selectSegment.isSelect = [NSNumber numberWithBool:YES];
    [self.recordSegments addObject:self.selectSegment];
    
    [self configView];
    [self initProgressBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.videoPlayerView.player setItemByAsset:self.selectSegment.asset];
    [self.videoPlayerView.player setLoopEnabled:YES];
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

- (void)configView {
    
    WS(weakSelf);
    
    [self.view addSubview:self.videoPlayerView];
    [self.view addSubview:self.trimmerView];
    [self.view addSubview:self.nextButton];

    [self.videoPlayerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(weakSelf.trimmerView.mas_top).with.offset(-37.5);
    }];
    
    [self.nextButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15);
        make.centerX.mas_equalTo(weakSelf.view.centerX);
        make.size.mas_equalTo(CGSizeMake(86.5, 86.5));
    }];
}

- (void)initProgressBar {
    
    WS(weakSelf)
    GET_SCREEN_SCALE(scale);
    self.progressBar = [ProgressBar getInstance];
    self.progressBar.progressIndicator.hidden = YES;
    [self.view addSubview:self.progressBar];
    [self.progressBar makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.videoPlayerView.mas_bottom);
        make.height.mas_equalTo(7.5*scale);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
    }];
    
    [self.videoEditAuxiliary updateProgressBar:self.progressBar :self.recordSegments];
}

//获取视频当前总时间长度
- (float)getAllVideoTimes {
    
    float time = 0;
    for (int i = 0; i < self.recordSegments.count; i++) {
        
        if (i == self.recordSegments.count - 1) {
            break;
        }
        
        SCRecordSessionSegment * segment = self.recordSegments[i];
        if ([segment.startTime floatValue] > 0 || [segment.endTime floatValue] > 0) {
            time += ([segment.endTime floatValue]-[segment.startTime floatValue]);
        } else {
            time += CMTimeGetSeconds(segment.duration);
        }
    }
    
    return time;
}

#pragma mark - PlaybackTimeCheckerTimer
//控制快进，后退
- (void)seekVideoToPos
{
    CMTime time = CMTimeMakeWithSeconds(self.selectSegment.startTime.floatValue, self.videoPlayerView.player.currentTime.timescale);
    [self.videoPlayerView.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)cutVideo {
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.selectSegment.asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        NSURL *tempPath = [LZVideoTools filePathWithFileName:@"ConponVideo.mp4"];
        WS(weakSelf);
        [LZVideoTools cutVideoWith:self.selectSegment filePath:tempPath completion:^{
            SCRecordSessionSegment * newSegment = [[SCRecordSessionSegment alloc] initWithURL:tempPath info:nil];
            [weakSelf.recordSession addSegment:newSegment];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)FileManager{
    
}


#pragma mark - Event
- (void)nextButtonAction:(UIButton *)sender {
    [self cutVideo];
}

#pragma mark - SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    NSAssert(self.selectSegment.url != nil, @"segment must be non-nil");
    if(self.selectSegment) {
        [self.selectSegment setStartTime:[NSNumber numberWithFloat:leftPosition]];
        [self.selectSegment setEndTime:[NSNumber numberWithFloat:rightPosition]];
        
        CGFloat width = (rightPosition-leftPosition) / MAX_VIDEO_DUR * SCREEN_WIDTH;
        [self.progressBar refreshCurrentView:self.recordSegments.count-1 andWidth:width];
        
        DLog(@"%f, %f", self.selectSegment.startTime.floatValue, self.selectSegment.endTime.floatValue);
        
        [self seekVideoToPos];
    }
}

#pragma mark - Setter/Getter

- (SCVideoPlayerView *)videoPlayerView {
    
    if (_videoPlayerView == nil) {
        _videoPlayerView = [[SCVideoPlayerView alloc] init];
        _videoPlayerView.backgroundColor            = UIColorFromRGB(0x000000, 1);
        _videoPlayerView.playerLayer.videoGravity   = AVLayerVideoGravityResizeAspectFill;
    }
    
    return _videoPlayerView;
}

- (SAVideoRangeSlider *)trimmerView {
    
    if (_trimmerView == nil) {
        _trimmerView = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-211-59, SCREEN_WIDTH, 49) ];
        [_trimmerView getMovieFrame:self.selectSegment.url];
        _trimmerView.delegate = self;
        
        float time = 0;
        if (15 - [self getAllVideoTimes] < CMTimeGetSeconds(self.selectSegment.duration)) {
            time = 15 - [self getAllVideoTimes];
            DLog(@"剩余时间：%f", time);
            [self.selectSegment setEndTime:[NSNumber numberWithFloat:time]];
            [_trimmerView setMaxGap:time];
        }
    }
    
    return _trimmerView;
}

- (UIButton *)nextButton {
    
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton setImage:[UIImage imageNamed:@"lz_selectvideo_add"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

@end
