//
//  LZGridView.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/11/25.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZGridView.h"
#import "Masonry.h"

#define padding 0.5
#define line51 UIColorFromRGB(0x515151, 1)
#define linea3 UIColorFromRGB(0xa3a3a3, 1)

@implementation LZGridView
- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    [self configView];
    
    [self addAutoLayout];
}

- (void)configView {

    [self addSubview:self.line1];
    [self addSubview:self.line2];
    [self addSubview:self.line3];
    [self addSubview:self.line4];
    
    [self addSubview:self.line11];
    [self addSubview:self.line22];
    [self addSubview:self.line33];
    [self addSubview:self.line44];
}

- (void)addAutoLayout {
    
    WS(weakSelf);
    

    [self.line2 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-SCREEN_WIDTH/3.0-padding);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(padding);
    }];
    [self.line22 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-SCREEN_WIDTH/3.0+padding);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(padding);
    }];
    
    [self.line1 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.line2.mas_top).with.offset(-SCREEN_WIDTH/3.0-padding);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(padding);
    }];
    [self.line11 makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.line2.mas_top).with.offset(-SCREEN_WIDTH/3.0+padding);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(padding);
    }];
    
    [self.line3 makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(SCREEN_WIDTH/3.0-padding);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(padding);
    }];
    [self.line33 makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(SCREEN_WIDTH/3.0+padding);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(padding);
    }];
    [self.line4 makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.trailing.mas_equalTo(-SCREEN_WIDTH/3.0-padding);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(padding);
    }];
    [self.line44 makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.trailing.mas_equalTo(-SCREEN_WIDTH/3.0+padding);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(padding);
    }];
}

- (UIView *)line1 {
    if (_line1 == nil) {
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = line51;
    }
    return _line1;
}

- (UIView *)line11 {
    if (_line11 == nil) {
        _line11 = [[UIView alloc] init];
        _line11.backgroundColor = linea3;
    }
    return _line11;
}

- (UIView *)line2 {
    if (_line2 == nil) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = line51;
    }
    return _line2;
}

- (UIView *)line22 {
    if (_line22 == nil) {
        _line22 = [[UIView alloc] init];
        _line22.backgroundColor = linea3;
    }
    return _line22;
}

- (UIView *)line3 {
    if (_line3 == nil) {
        _line3 = [[UIView alloc] init];
        _line3.backgroundColor = line51;
    }
    return _line3;
}

- (UIView *)line33 {
    if (_line33 == nil) {
        _line33 = [[UIView alloc] init];
        _line33.backgroundColor = linea3;
    }
    return _line33;
}

- (UIView *)line4 {
    if (_line4 == nil) {
        _line4 = [[UIView alloc] init];
        _line4.backgroundColor = line51;
    }
    
    return _line4;
}

- (UIView *)line44 {
    if (_line44 == nil) {
        _line44 = [[UIView alloc] init];
        _line44.backgroundColor = linea3;
    }
    return _line44;
}

@end
