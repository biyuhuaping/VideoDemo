//
//  LZCreatePromotionViewController.h
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/17.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZBaseViewController.h"
#import "SCRecorder.h"

@class LZCouponListModel;

@interface LZCreatePromotionViewController : LZBaseViewController

@property (nonatomic, strong) SCRecordSession * recordSession;


/**
 标记从哪个事件进入本页面.目前只有优惠列表中的 edit 和 copy 按钮事件进入
 */
@property (nonatomic, assign) CouponListEventCode eventCode;
@property (nonatomic, strong) __block LZCouponListModel * couponListModel;

/**
 标记是否是从优惠详情中进入的本页面. 如果不是,则可能是从优惠列表中点击edit或者copy 进入, 或者是正常发布优惠进入
 */
@property (nonatomic, assign) BOOL isComeFromCouponDetailVC;
/**
 在本类中点击相应按钮后,回调想想的点击事件,点击编辑,进入编辑页面,点击save 或者 submit 后,返回相应的操作事件
 */
@property (nonatomic, copy) void(^operationCouponStateSuccessBlock)(CouponListEventCode eventCode, LZCouponListModel *returnModel);

@end
