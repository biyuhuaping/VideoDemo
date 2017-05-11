//
//  LZVideoEditClipVC.m
//  laziz_Merchant
//
//  Created by biyuhuaping on 2017/4/24.
//  Copyright © 2017年 XBN. All rights reserved.
//  视频编辑页面

#import "LZVideoEditClipVC.h"
#import "LewReorderableLayout.h"            //拖动排序
#import "LZVideoEditCollectionViewCell.h"

#import "ProgressBar.h"

#import "LZVideoEditAuxiliary.h"
#import "LZVideoTools.h"

@interface LZVideoEditClipVC ()<LewReorderableLayoutDelegate, LewReorderableLayoutDataSource, SAVideoRangeSliderDelegate>

@property (strong, nonatomic) IBOutlet SCVideoPlayerView *videoPlayerView;  //视频播放View
@property (strong, nonatomic) IBOutlet SAVideoRangeSlider *trimmerView;     //微调视图
@property (strong, nonatomic) IBOutlet ProgressBar *progressBar;            //进度条

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *lzCopyButton;              //复制按钮
@property (strong, nonatomic) IBOutlet UIButton *lzVoiceButton;             //声音按钮
@property (strong, nonatomic) IBOutlet UIButton *lzDeleteButton;            //删除按钮
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;                  //提示信息

@property (strong, nonatomic) LZVideoEditAuxiliary *videoEditAuxiliary;
@property (assign, nonatomic) NSInteger currentSelected;
@property (strong, nonatomic) NSMutableArray *recordSegments;

@end

@implementation LZVideoEditClipVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = LZLocalizedString(@"edit_video", nil);
    _hintLabel.text = LZLocalizedString(@"all_video_delete", nil);
    self.currentSelected = 0;
    self.progressBar.progressIndicator.hidden = YES;
    self.videoEditAuxiliary = [[LZVideoEditAuxiliary alloc]init];
    self.recordSegments = [NSMutableArray arrayWithArray:self.recordSession.segments];

    [self.videoPlayerView.player setLoopEnabled:YES];
    [self.videoEditAuxiliary updateProgressBar:self.progressBar :self.recordSegments];

    [self configNavigationBar];
    [self configCollectionView];
    
    [self.trimmerView getMovieFrame:[self.videoEditAuxiliary getCurrentSegment:self.recordSegments index:0].url];
    self.trimmerView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showVideo:self.currentSelected];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoPlayerView.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    DLog(@"=========");
}

#pragma mark - configViews
//配置navi
- (void)configNavigationBar{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.selected = NO;
    [button setTitle:LZLocalizedString(@"edit_done", @"") forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
    [button sizeToFit];
    button.frame = CGRectMake(0, 0, CGRectGetWidth(button.bounds), 40);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
    [button addTarget:self action:@selector(navbarRightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
}

//配置collectionView
- (void)configCollectionView{
    LewReorderableLayout *layout = [LewReorderableLayout new];
    layout.itemSize                 = CGSizeMake(60, 60);
    layout.minimumInteritemSpacing  = 10;
    layout.minimumLineSpacing       = 10;
    layout.sectionInset             = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection          = UICollectionViewScrollDirectionHorizontal;
    layout.delegate                 = self;
    layout.dataSource               = self;
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView registerClass:[LZVideoEditCollectionViewCell class] forCellWithReuseIdentifier:@"VideoEditCollectionCell"];
}

//播放视频
- (void)showVideo:(NSInteger)idx {
    if (idx < 0) {
        idx = 0;
    }
    
    //更新进度条
    [self.videoEditAuxiliary updateProgressBar:self.progressBar :self.recordSegments];
    
    
    if (idx < self.recordSegments.count) {
        SCRecordSessionSegment *segment = self.recordSegments[idx];
        NSAssert(segment != nil, @"segment must be non-nil");
        
        [self.videoPlayerView.player setItemByAsset:segment.asset];
        
        //切换视频的时候，移动到剪切位置
        if(segment.startTime.floatValue > 0) {
//            [self startTimer];
            [self seekVideoToPos];
        }
    
        [self.videoPlayerView.player play];
    }
    
    for (int i = 0; i < self.recordSegments.count; i++) {
        SCRecordSessionSegment * segment = self.recordSegments[i];
        NSAssert(segment != nil, @"segment must be non-nil");
        
        if (self.currentSelected == i) {
            segment.isSelect = [[NSNumber alloc] initWithBool:YES];//设置选中
            [self.progressBar setCurrentProgressToStyle:ProgressBarProgressStyleSelect andIndex:i];//设置当前进度条的颜色
            [self setVoice:i];//设置声音
        }
        else {
            segment.isSelect = [[NSNumber alloc] initWithBool:NO];
            [self.progressBar setCurrentProgressToStyle:ProgressBarProgressStyleNormal andIndex:i];
        }
    }
    
    [self.collectionView reloadData];
}

//设置声音
- (void)setVoice:(NSInteger)idx {
    SCRecordSessionSegment * segment = self.recordSegments[idx];
    //判断当前片段的声音设置
    if (segment.isVoice) {
        if ([segment.isVoice boolValue] == YES) {
            self.videoPlayerView.player.volume = 1;
            [self.lzVoiceButton setImage:[UIImage imageNamed:@"lz_videoedit_voice_on"] forState:UIControlStateNormal];
        }
        else {
            self.videoPlayerView.player.volume = 0;
            [self.lzVoiceButton setImage:[UIImage imageNamed:@"lz_videoedit_voice_off"] forState:UIControlStateNormal];
        }
    }
    else { //没有设置过音频
        self.videoPlayerView.player.volume = 1;
        [self.lzVoiceButton setImage:[UIImage imageNamed:@"lz_videoedit_voice_on"] forState:UIControlStateNormal];
    }
}

//控制快进，后退
- (void)seekVideoToPos {
    SCRecordSessionSegment * segment = [self.videoEditAuxiliary getCurrentSegment:self.recordSegments index:self.currentSelected];
    CMTime time = CMTimeMakeWithSeconds(segment.startTime.floatValue, self.videoPlayerView.player.currentTime.timescale);
    [self.videoPlayerView.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - Event
//保存
- (void)navbarRightButtonClickAction:(UIButton*)sender {
    [self.recordSession removeAllSegments:NO];
    
    WS(weakSelf);
    dispatch_group_t serviceGroup = dispatch_group_create();
    for (int i = 0; i < weakSelf.recordSegments.count; i++) {
        DLog(@"执行剪切：%d", i);
        SCRecordSessionSegment * segment = weakSelf.recordSegments[i];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:segment.asset];
        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {

            NSString *filename = [NSString stringWithFormat:@"SCVideoEditCut-%ld.mp4", (long)i];
            NSURL *tempPath = [LZVideoTools filePathWithFileName:filename];
            
            CMTime start = CMTimeMakeWithSeconds(segment.startTime.floatValue, segment.duration.timescale);
            CMTime duration = CMTimeMakeWithSeconds(segment.endTime.floatValue - segment.startTime.floatValue, segment.asset.duration.timescale);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            
            dispatch_group_enter(serviceGroup);
            [LZVideoTools exportVideo:segment.asset videoComposition:nil filePath:tempPath timeRange:range completion:^(NSURL *savedPath) {
                SCRecordSessionSegment * newSegment = [[SCRecordSessionSegment alloc] initWithURL:tempPath info:nil];
                DLog(@"剪切url:%@", [tempPath path]);
                
                newSegment.startTime = nil;
                newSegment.endTime = nil;
                
                [weakSelf.recordSegments removeObject:segment];
                [weakSelf.recordSegments insertObject:newSegment atIndex:i];
                dispatch_group_leave(serviceGroup);
            }];
        }
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
        DLog(@"保存到recordSession");
        for (int i = 0; i < weakSelf.recordSegments.count; i++) {
            SCRecordSessionSegment * segment = weakSelf.recordSegments[i];
            NSAssert(segment.url != nil, @"segment url must be non-nil");
            if (segment.url != nil) {
                [weakSelf.recordSession insertSegment:segment atIndex:i];
            }
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}

//复制
- (IBAction)lzCopyButtonAction:(UIButton *)sender {
    if (self.recordSegments.count == 0) {
        return;
    }
    
    SCRecordSessionSegment * segment = [self.videoEditAuxiliary getCurrentSegment:self.recordSegments index:self.currentSelected];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    
    if (CMTimeGetSeconds(segment.duration)+[self.videoEditAuxiliary getAllVideoTimesRecordSegments:self.recordSegments] > 15) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:LZLocalizedString(@"edit_message", nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        return;
    }
    
    SCRecordSessionSegment * newSegment = [SCRecordSessionSegment segmentWithURL:segment.url info:nil];
    NSAssert(newSegment.url != nil, @"segment must be non-nil");
    newSegment.startTime = nil;
    newSegment.endTime = nil;
    
    [self.recordSegments addObject:newSegment];
    
    //更新进度条
    [self.videoEditAuxiliary updateProgressBar:self.progressBar :self.recordSegments];
    
    //更新剪切片段
    [self.videoEditAuxiliary updateTrimmerView:self.trimmerView recordSegments:self.recordSegments index:self.currentSelected];
    
    //更新片段view
    [self.collectionView reloadData];
}

//声音
- (IBAction)lzVoiceButtonAction:(UIButton *)sender {
    if (self.recordSegments.count == 0) {
        return;
    }
    
    SCRecordSessionSegment * segment = [self.videoEditAuxiliary getCurrentSegment:self.recordSegments index:self.currentSelected];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    if ([segment.isVoice boolValue] == YES) {
        [segment setIsVoice:[NSNumber numberWithBool:NO]];
        [self.lzVoiceButton setImage:[UIImage imageNamed:@"lz_videoedit_voice_off"] forState:UIControlStateNormal];
        self.videoPlayerView.player.volume = 0;
    }
    else {
        [segment setIsVoice:[NSNumber numberWithBool:YES]];
        [self.lzVoiceButton setImage:[UIImage imageNamed:@"lz_videoedit_voice_on"] forState:UIControlStateNormal];
        self.videoPlayerView.player.volume = 1;
    }
}

//删除
- (IBAction)lzDeleteButtonAction:(UIButton *)sender {
    if (self.recordSegments.count == 0) {
        return;
    }
    
    if(self.recordSegments.count > 0) {
        [self.recordSegments removeObject:[self.videoEditAuxiliary getCurrentSegment:self.recordSegments index:self.currentSelected]];
        if (self.currentSelected >= self.recordSegments.count) {
            self.currentSelected = self.recordSegments.count-1;
        }
        [self showVideo:self.currentSelected];
    }
    
    //这里不能用 else if ，因为当删掉最后一个元素后，self.recordSegments.count 就等于0，需要进入方法内执行。
    if (self.recordSegments.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self.videoPlayerView.player pause];
        
        self.videoPlayerView.hidden = YES;
        self.progressBar.hidden     = YES;
        self.trimmerView.hidden     = YES;
        self.collectionView.hidden  = YES;
        
        self.lzCopyButton.hidden    = YES;
        self.lzVoiceButton.hidden   = YES;
        self.lzDeleteButton.hidden  = YES;
        
        self.hintLabel.hidden = NO;
    }
}

#pragma mark - SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
//    [self startTimer];
    
    SCRecordSessionSegment * segment = [self.videoEditAuxiliary getCurrentSegment:self.recordSegments index:self.currentSelected];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    if(segment) {
        [segment setStartTime:[NSNumber numberWithFloat:leftPosition]];
        [segment setEndTime:[NSNumber numberWithFloat:rightPosition]];
        
        CGFloat width = (rightPosition-leftPosition) / MAX_VIDEO_DUR * SCREEN_WIDTH;
        [self.progressBar refreshCurrentView:self.currentSelected andWidth:width];
        
        DLog(@"%f, %f", segment.startTime.floatValue, segment.endTime.floatValue);
        
        [self seekVideoToPos];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recordSegments.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"VideoEditCollectionCell";
    LZVideoEditCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    SCRecordSessionSegment * segment = self.recordSegments[indexPath.row];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    if (segment) {
        cell.imageView.image = segment.thumbnail;
        if ([segment.isSelect boolValue] == YES) {
            cell.markView.hidden = YES;
            cell.imageView.layer.borderWidth = 2;
            cell.imageView.layer.borderColor = UIColorFromRGB(0x554c9a, 1).CGColor;
        }
        else {
            cell.markView.hidden = NO;
            cell.imageView.layer.borderWidth = 0;
            cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
    SCRecordSessionSegment * segment = self.recordSegments[fromIndexPath.row];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    [self.recordSegments removeObject:segment];
    [self.recordSegments insertObject:segment atIndex:toIndexPath.row];
    
    //更新bar位置
    [self.videoEditAuxiliary updateProgressBar:self.progressBar :self.recordSegments];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentSelected == indexPath.row) {
        return;
    }
    self.currentSelected = indexPath.row;
    
    //显示当前片段
    [self showVideo:self.currentSelected];
    
    //更新片段
    [self.videoEditAuxiliary updateTrimmerView:self.trimmerView recordSegments:self.recordSegments index:self.currentSelected];
    
    //停止
//    [self stopTimer];
}

@end
