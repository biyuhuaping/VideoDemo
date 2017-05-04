//
//  LZSelectVideoViewController.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/9.
//  Copyright © 2016年 XBN. All rights reserved.
//  选择视频页面

#import "LZSelectVideoViewController.h"
#import "LZTrimCropViewController.h"
#import "LZSelectVideoCollectionViewCell.h"

#import "Masonry.h"
//#import "UINavigationBar+BackgroundColor.h"
#import "ProgressBar.h"

#import "SCRecordSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SCRecordSessionSegment+LZAdd.h"
#import "LZVideoEditAuxiliary.h"

@interface LZSelectVideoViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

//views
@property (nonatomic, strong) ProgressBar       * progressBar;
@property (nonatomic, strong) SCVideoPlayerView * videoPlayerView;
@property (nonatomic, strong) UICollectionView  * collectionView;
@property (nonatomic, strong) UIButton          * nextButton;

@property (nonatomic, assign) NSInteger currentSelectIdx;
@property (nonatomic, strong) LZVideoEditAuxiliary *videoEditAuxiliary;

@end

@implementation LZSelectVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoEditAuxiliary = [[LZVideoEditAuxiliary alloc]init];

    self.title = LZLocalizedString(@"select_video", nil);
    self.view.backgroundColor = UIColorFromRGB(0x000000, 1);
    
    [self configView];
    [self initProgressBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];[self showVideo:self.currentSelectIdx];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoPlayerView.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
- (void)configView {
    
    WS(weakSelf);
    
    [self.view addSubview:self.videoPlayerView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.nextButton];

    [self.videoPlayerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(weakSelf.collectionView.mas_top).with.offset(-17.5);
    }];
    
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.nextButton.mas_top).with.offset(-30);
        make.height.mas_equalTo(100);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
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

//播放视频
- (void)showVideo:(NSInteger)idx {
    if (idx < self.videoListSegmentArrays.count) {
        SCRecordSessionSegment *segment = self.videoListSegmentArrays[idx];
        NSAssert(segment != nil, @"segment must be non-nil");
        [self.videoPlayerView.player setItemByAsset:segment.asset];
        [self.videoPlayerView.player setLoopEnabled:YES];
        [self.videoPlayerView.player play];
    }
    
    for (int i = 0; i < self.videoListSegmentArrays.count; i++) {
        SCRecordSessionSegment * segment = self.videoListSegmentArrays[i];
        NSAssert(segment != nil, @"segment must be non-nil");
        if (self.currentSelectIdx == i) {
            //设置选中
            segment.isSelect = [[NSNumber alloc] initWithBool:YES];
        }
        else {
            segment.isSelect = [[NSNumber alloc] initWithBool:NO];
        }
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Event
- (void)nextButtonAction:(UIButton *)sender {
    CGFloat duration = [self.videoEditAuxiliary getAllVideoTimesRecordSegments:self.recordSession.segments];
    if (duration >= 15) {//如果已录制的视频 >=15秒，就止步于此，不能进入视频剪裁页。
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:LZLocalizedString(@"edit_message", nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        return;
    }
    else if (self.currentSelectIdx >= 0) {
        LZTrimCropViewController * vc = [[LZTrimCropViewController alloc] init];
        vc.recordSession = self.recordSession;
        vc.selectSegment = self.videoListSegmentArrays[self.currentSelectIdx];
        [self.navigationController pushViewController:vc animated:YES];
        
        NSMutableArray *vcArrays = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
        [vcArrays removeObject:self];
        self.navigationController.viewControllers = vcArrays;
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"选择视频" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoListSegmentArrays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"SelectVideoCollectionCell";
    LZSelectVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    SCRecordSessionSegment * segment = self.videoListSegmentArrays[indexPath.row];
    NSAssert(segment.url != nil, @"segment must be non-nil");
    if (segment) {
        cell.imageView.image = segment.thumbnail;
        cell.timeLabel.text = [NSString stringWithFormat:@" %.2f ", CMTimeGetSeconds(segment.duration)];
        if ([segment.isSelect boolValue] == YES) {
            cell.imageView.layer.borderWidth = 2;
            cell.imageView.layer.borderColor = UIColorFromRGB(0xffffff, 1).CGColor;
        } else {
            cell.imageView.layer.borderWidth = 0;
            cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelectIdx = indexPath.row;
    [self showVideo:self.currentSelectIdx];
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

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize                 = CGSizeMake(100, 100);
        layout.minimumInteritemSpacing  = 10;
        layout.minimumLineSpacing       = 10;
        layout.sectionInset             = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection          = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.delegate    = self;
        self.collectionView.dataSource  = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[LZSelectVideoCollectionViewCell class] forCellWithReuseIdentifier:@"SelectVideoCollectionCell"];
    }
    
    return _collectionView;
}

- (UIButton *)nextButton {
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton setImage:[UIImage imageNamed:@"lz_musiclist_nextimage"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

@end
