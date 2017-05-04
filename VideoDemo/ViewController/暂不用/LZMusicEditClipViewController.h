//
//  LZMusicEditClipViewController.h
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/28.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZBaseViewController.h"
#import "SCRecorder.h"

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaItem+LZAdd.h"

//音频剪切
@interface LZMusicEditClipViewController : LZBaseViewController
@property (nonatomic, strong) SCRecordSession * recordSession;
@property (nonatomic, strong) MPMediaItem * song;
@end
