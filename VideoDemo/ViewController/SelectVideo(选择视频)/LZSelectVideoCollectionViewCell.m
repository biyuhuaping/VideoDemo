//
//  LZSelectVideoCollectionViewCell.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/9.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZSelectVideoCollectionViewCell.h"
#import "Masonry.h"

@implementation LZSelectVideoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor lightTextColor];
        [self configView];
        [self addAutoLayout];
    }
    return self;
}

- (void)configView {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.markView];
    [self.contentView addSubview:self.timeLabel];
}

- (void)addAutoLayout {
    
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
    }];
    
    [self.markView makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
    }];
    
    [self.timeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5);
        make.trailing.mas_equalTo(-5);
        make.height.mas_equalTo(12);
    }];
}

- (UIImageView *)imageView {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
    }
    
    return _imageView;
}

- (UIView *)markView {
    
    if (_markView == nil) {
        _markView = [[UIView alloc] init];
        _markView.backgroundColor = UIColorFromRGB(0x000000, 0.3);
        _markView.hidden = YES;
    }
    
    return _markView;
}

- (UILabel *)timeLabel {

    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = UIColorFromRGB(0x000000, 0.5);
        _timeLabel.text = @"0'15";
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.layer.cornerRadius = 6;
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = UIColorFromRGB(0xffffff, 1);
    }
    
    return _timeLabel;
}
@end
