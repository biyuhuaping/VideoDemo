//
//  LZVideoEditCollectionViewCell.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/29.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZVideoEditCollectionViewCell.h"
#import "Masonry.h"

@implementation LZVideoEditCollectionViewCell

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
@end
