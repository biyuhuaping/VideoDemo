//
//  LZMusicEditClipViewController.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/28.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZMusicEditClipViewController.h"

#import "Masonry.h"

#import "GVUserDefaults+LZProperties.h"
#import "UINavigationBar+BackgroundColor.h"
#import "UIViewController+NavigationItemSetting.h"

#import "ProgressBar.h"

#import "SCRecordSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface LZMusicEditClipViewController ()

//navi
@property (nonatomic, strong) UIButton          * nav_right_button;

//
@property (nonatomic, strong) ProgressBar       * progressBar;

//views
@property (nonatomic, strong) SCVideoPlayerView * videoPlayerView;

@property (nonatomic, strong) UIButton          * voiceButton;

//@property (nonatomic, strong) ICGVideoTrimmerView * trimmerView;
@property (nonatomic, strong) AVURLAsset        * songAsset;

@end

@implementation LZMusicEditClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.umLogPageViewName = @"音频编辑页面";
    self.title = @"Edit Audio";
    self.view.backgroundColor = UIColorFromRGB(0x000000, 1);
    
    DLog(@"1-%@", self.song.title);
    DLog(@"2-%@", self.song.artist);
    DLog(@"3-%@", self.song.assetURL);
    
    self.songAsset = [AVURLAsset URLAssetWithURL:self.song.assetURL options:nil]; //初始化音频媒体文件
    
    //
    [self configNavigationBar];
    [self configView];
    [self initProgressBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.videoPlayerView.player setItemByAsset:self.recordSession.assetRepresentingSegments];
    [self.videoPlayerView.player setLoopEnabled:YES];
    [self.videoPlayerView.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.videoPlayerView.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//配置navi
- (void)configNavigationBar{
    
    self.nav_right_button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nav_right_button.titleLabel.font = [UIFont systemFontOfSize:15];
    self.nav_right_button.selected = NO;
    [self.nav_right_button setTitle:LZLocalizedString(@"add", @"") forState:UIControlStateNormal];
    [self.nav_right_button setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
    [self.nav_right_button sizeToFit];
    self.nav_right_button.frame = CGRectMake(0, 0, CGRectGetWidth(self.nav_right_button.bounds), 40);
    [self.nav_right_button addTarget:self action:@selector(navbarRightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self navigationItemSetting:@[self.nav_right_button] type:NAVIGATIONITEMSETTING_RIGHT];
}

- (void)configView {
    
    WS(weakSelf);
    
    [self.view addSubview:self.videoPlayerView];
    [self.view addSubview:self.voiceButton];
//    [self.view addSubview:self.trimmerView];
    
    [self.videoPlayerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(SCREEN_WIDTH);
    }];
    
    [self.voiceButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15);
        make.centerX.mas_equalTo(weakSelf.view.centerX);
        make.size.mas_equalTo(CGSizeMake(44, 44));
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
    
    [self updateProgressBar];
}

- (void)updateProgressBar {
    
    for (SCRecordSessionSegment * segment in self.recordSession.segments) {
        
        CMTime currentTime = kCMTimeZero;
        if (segment != nil) {
            currentTime = segment.duration;
            CGFloat width = CMTimeGetSeconds(currentTime) / MAX_VIDEO_DUR * SCREEN_WIDTH;
            [self.progressBar setCurrentProgressToWidth:width];
        }
    }
}

#pragma mark - Event

- (void)navbarRightButtonClickAction:(UIButton*)sender {
    
}

- (void)voiceButtonAction:(UIButton *)sender {

}

//#pragma mark - ICGVideoTrimmerDelegate
//
//- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
//{
//    
//}

#pragma mark - Setter/Getter

- (SCVideoPlayerView *)videoPlayerView {
    
    if (_videoPlayerView == nil) {
        _videoPlayerView = [[SCVideoPlayerView alloc] init];
        _videoPlayerView.backgroundColor = UIColorFromRGB(0x000000, 1);
        _videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return _videoPlayerView;
}

- (UIButton *)voiceButton {

    if (_voiceButton == nil) {
        _voiceButton = [[UIButton alloc] init];
        [_voiceButton setImage:[UIImage imageNamed:@"lz_videoedit_voice_on"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _voiceButton;
}

//- (ICGVideoTrimmerView *)trimmerView {
//
//    if (_trimmerView == nil) {
//        
//        _trimmerView = [[ICGVideoTrimmerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 49) asset:self.songAsset];
//        [_trimmerView setDelegate:self];
//        [_trimmerView resetSubviews];
//        [_trimmerView setHidden:NO];
//    }
//
//    return _trimmerView;
//}

@end
