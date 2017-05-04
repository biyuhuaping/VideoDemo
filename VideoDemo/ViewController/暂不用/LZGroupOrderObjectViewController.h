//
//  LZGroupOrderObjectViewController.h
//  laziz_Merchant
//
//  Created by xbnzd on 17/4/1.
//  Copyright © 2017年 XBN. All rights reserved.
//

#import "LZBaseViewController.h"
@class  LZGroupItemModel;

@interface LZGroupOrderObjectViewController : LZBaseViewController
@property (nonatomic, copy) void(^selectGroupOrderBlock)(LZGroupItemModel * model);
@property (nonatomic, strong) LZGroupItemModel * currentSelectModel;
@end
