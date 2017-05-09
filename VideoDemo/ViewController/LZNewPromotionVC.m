//
//  LZNewPromotionVC.m
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/3/31.
//  Copyright © 2017年 XBN. All rights reserved.
//  视频录制页面

#import "LZNewPromotionVC.h"
#import "LZSelectVideoViewController.h"
#import "LZVideoDetailsVC.h"//视频详情

#import "LZGridView.h"
#import "LZLevelView.h"
#import "ProgressBar.h"
#import "LZButton.h"

#import "SCRecorder.h"
#import "SCRecordSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ClearCacheTool.h"

@interface LZNewPromotionVC ()<SCRecorderDelegate>
@property (strong, nonatomic) IBOutlet UIView *previewView;         //试映view
@property (strong, nonatomic) IBOutlet LZGridView *girdView;        //网格view
@property (strong, nonatomic) IBOutlet UIImageView *ghostImageView; //快照imageView
@property (strong, nonatomic) IBOutlet LZLevelView *levelView;      //水平仪view
@property (strong, nonatomic) IBOutlet ProgressBar *progressBar;    //进度条
@property (strong, nonatomic) IBOutlet SCRecorderToolsView *focusView;


@property (strong, nonatomic) IBOutlet UIButton *cancelButton;      //删除按钮
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;     //确认按钮
@property (strong, nonatomic) IBOutlet LZButton *gridOrlineButton;  //网格按钮
@property (strong, nonatomic) IBOutlet UIButton *snapshotButton;    //快照按钮

//recorder
@property (nonatomic, strong) SCRecorder *recorder;
@property (nonatomic, strong) NSMutableArray *videoListSegmentArrays; //音频库

@end

@implementation LZNewPromotionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.videoListSegmentArrays = [NSMutableArray array];    
    [_gridOrlineButton setLoopImages:@[[UIImage imageNamed:@"lz_recorder_grid"], [UIImage imageNamed:@"lz_recorder_grid_hd"], [UIImage imageNamed:@"lz_recorder_line_hd"]] ];
    
    [self configNavigationBar];
    [self initSCRecorder];
    [self.progressBar startShining];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self enumVideoUrl];
    [self updateGhostImage];
    [self updateProgressBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_recorder stopRunning];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    //清除缓存
    [ClearCacheTool clearAction];
}

#pragma mark - configViews
//配置navi
- (void)configNavigationBar{
    UIImage *btn_image = [UIImage imageNamed:@"lz_new_rightbutton"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.selected = NO;
    [button setImage:btn_image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(navbarRightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

//初始化录制
- (void)initSCRecorder {
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(15, 1); //设置记录的最大持续时间
//    _recorder.fastRecordMethodEnabled = YES;
    _recorder.videoConfiguration.size = CGSizeMake(480, 480);
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    _recorder.previewView = self.previewView;

    //初始Session
    SCRecordSession *session = [SCRecordSession recordSession];
    session.fileType = AVFileTypeMPEG4;
    _recorder.session = session;
    
    self.focusView.recorder = _recorder;
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"lz_recorder_change_hd"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"lz_recorder_change"];
}

- (void)enumVideoUrl {
    WS(weakSelf);
    [self.videoListSegmentArrays removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
                NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                if([assetType isEqualToString:ALAssetTypeVideo]){
                    DLog(@"Video");
                    NSDictionary *assetUrls = [result valueForProperty:ALAssetPropertyURLs];
                    NSUInteger assetCounter = 0;
                    for (NSString *assetURLKey in assetUrls) {
                        DLog(@"Asset URL %lu = %@",(unsigned long)assetCounter, assetUrls[assetURLKey]);
                        SCRecordSessionSegment * segment = [[SCRecordSessionSegment alloc] initWithURL:assetUrls[assetURLKey] info:nil];
                        [weakSelf.videoListSegmentArrays addObject:segment];
                    }
                    DLog(@"Representation Size = %lld",[[result defaultRepresentation]size]);
                }
            }];
        } failureBlock:^(NSError *error) {
            DLog(@"Enumerate the asset groups failed.");
        }];
    });
}

//更新进度条
- (void)updateProgressBar {
    if (self.recorder.session.segments.count == 0) {
        return;
    }
    
    self.cancelButton.enabled = YES;
    if (CMTimeGetSeconds(self.recorder.session.duration) >= 3) {
        self.confirmButton.enabled = YES;
    } else {
        self.confirmButton.enabled = NO;
    }
    
    [self.progressBar removeAllSubViews];
    for (int i = 0; i < self.recorder.session.segments.count; i++) {
        SCRecordSessionSegment * segment = self.recorder.session.segments[i];
        
        NSAssert(segment != nil, @"segment must be non-nil");
        CMTime currentTime = kCMTimeZero;
        if (segment) {
            currentTime = segment.duration;
            CGFloat width = CMTimeGetSeconds(currentTime) / MAX_VIDEO_DUR * SCREEN_WIDTH;
            [self.progressBar setCurrentProgressToWidth:width];
        }
    }
}

//更新快照
- (void)updateGhostImage {
    if (self.snapshotButton.selected && self.recorder.session.segments.count > 0) {
        SCRecordSessionSegment *segment = [self.recorder.session.segments lastObject];
        self.ghostImageView.image = segment.lastImage;
        self.ghostImageView.hidden = NO;
    }else{
        self.ghostImageView.hidden = YES;
    }
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    self.recorder.session = recordSession;
    
    //视频详情
    LZVideoDetailsVC * vc = [[LZVideoDetailsVC alloc]initWithNibName:@"LZVideoDetailsVC" bundle:nil];
    vc.recordSession = self.recorder.session;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Event
- (void)navbarRightButtonClickAction:(UIButton*)sender {
    if (self.videoListSegmentArrays.count > 0) {
        LZSelectVideoViewController * vc = [[LZSelectVideoViewController alloc] init];
        vc.recordSession = self.recorder.session;
        vc.videoListSegmentArrays = self.videoListSegmentArrays;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"暂无可选视频" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//取消/删除视频按钮
- (IBAction)cancelButton:(UIButton *)sender {
    if (sender.selected == NO && sender.enabled == YES) {//第一次按下删除按钮
        sender.selected = YES;
        [self.progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
    }
    else if (sender.selected == YES) {//第二次按下删除按钮
        [self.recorder.session removeLastSegment];
        [self.progressBar deleteLastProgress];
        
        if (self.recorder.session.segments.count > 0) {
            sender.selected = NO;
            sender.enabled = YES;
            
            if (CMTimeGetSeconds(self.recorder.session.duration) >= 3) {
                self.confirmButton.enabled = YES;
            } else {
                self.confirmButton.enabled = NO;
            }
        } else {
            sender.selected = NO;
            sender.enabled = NO;
            self.confirmButton.enabled = NO;
        }
    }
}

//开始录制按钮
- (IBAction)recordButton:(UIControl *)sender {
    [self.progressBar setLastProgressToStyle:ProgressBarProgressStyleNormal];
    self.ghostImageView.hidden = YES;
    [self.recorder record];
}

//暂停录制
- (IBAction)recordPauseButton:(id)sender {
    [self.recorder pause];
}

//确认按钮
- (IBAction)confirmButton:(UIButton *)sender {
    [self saveAndShowSession:self.recorder.session];
}

//切换摄像头按钮
- (IBAction)changeButton:(UIButton *)sender {
    [UIView animateWithDuration:0.7 animations:^{
        CATransition *animation = [CATransition animation];
        animation.duration = 0.7f;
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
        [self.previewView.layer addAnimation:animation forKey:@"animation"];
    } completion:^(BOOL finished) {
        if (finished) {
            [self.recorder switchCaptureDevices];
        }
    }];
}

//网格或线按钮
- (IBAction)gridOrlineButton:(LZButton *)sender {
    if (sender.currentIndex == 1) {
        self.girdView.hidden = NO;
    } else {
        self.girdView.hidden = YES;
    }
    
    if (sender.currentIndex == 2) {
        [self.levelView showLevelView];
    } else {
        [self.levelView hideLevelView];
    }
}

//快照按钮
- (IBAction)snapshotButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self updateGhostImage];
}

//闪光按钮
- (IBAction)flashButton:(UIButton *)sender {
    if (sender.selected == NO) {
        sender.selected = YES;
        self.recorder.flashMode = SCFlashModeLight;
    }
    else {
        sender.selected = NO;
        self.recorder.flashMode = SCFlashModeOff;
    }
}

#pragma mark - SCRecorderDelegate
- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    DLog(@"Skipped video buffer(跳过视频缓冲)");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    DLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    DLog(@"Reconfigured video input: %@", videoInputError);
}

//启动录制
- (void)recorder:(SCRecorder *__nonnull)recorder didBeginSegmentInSession:(SCRecordSession *__nonnull)session error:(NSError *__nullable)error {
    [self.progressBar addProgressView];
    [self.progressBar stopShining];
    self.cancelButton.enabled = YES;
}

//更新进度条
- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    CMTime recorderTime = kCMTimeZero;
    CMTime currentTime = kCMTimeZero;
    if (recordSession != nil) {
        currentTime = recordSession.currentSegmentDuration;
        recorderTime = recordSession.duration;
    }
    
    DLog(@"%@", [NSString stringWithFormat:@"current:%.2f sec, all:%.2f sec", CMTimeGetSeconds(currentTime), CMTimeGetSeconds(recorderTime)]);
    
    CGFloat width = CMTimeGetSeconds(currentTime) / MAX_VIDEO_DUR * SCREEN_WIDTH;
    [self.progressBar setLastProgressToWidth:width];
    
    if (CMTimeGetSeconds(recorderTime) >= 3) {
        self.confirmButton.enabled = YES;
    } else {
        self.confirmButton.enabled = NO;
    }
}

//更新快照
- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    [self.progressBar startShining];
    DLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    [self updateGhostImage];
}

//录制完成
- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    DLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}


@end
