//
//  LZCreatePromotionViewController.m
//  laziz_Merchant
//
//  Created by ZhaoDongBo on 2016/12/17.
//  Copyright © 2016年 XBN. All rights reserved.
//

#import "LZCreatePromotionViewController.h"
#import "LZCreatePromotionTableView.h"
#import "LZSelectDateView.h"
#import "UIViewController+LZRemoveViewController.h"

#import "NSDate+TimeCategory.h"
#import "BlocksKit+UIKit.h"
#import "Masonry.h"

#import "LZUserModel.h"
#import "LZGroupItemModel.h"
#import "LZCouponPresenter.h"

#import "LZCouponManagerListDetailViewController.h"
#import "LZCouponListModel.h"

#import "LZNewPromotionVC.h"
#import "LZVideoDetailsVC.h"
#import "LZCreatePromotionViewController.h"

#import "LZUploadImagePresenter.h"

#import "SCAssetExportSession.h"
#import <AVFoundation/AVFoundation.h>
#import "LZAlertView.h"
#import "LZRemindView.h"

#import "LZGroupOrderObjectViewController.h"

#import "LZVideoTools.h"

typedef NS_ENUM(NSInteger, SaveOrSubmitTag) {
    kSaveTag,
    kSubmitTag
};

@interface LZCreatePromotionViewController () <SCAssetExportSessionDelegate>

@property (nonatomic, strong) LZCreatePromotionTableView    * tableView;
@property (nonatomic, strong) UIButton                      * saveButton;
@property (nonatomic, strong) UIButton                      * submitButton;

@property (nonatomic, strong) LZSelectDateView              * selectDateView;
@property (nonatomic, strong) LZSelectDateView              * selectTimeView;

@property (nonatomic, strong) LZCouponPresenter             * couponPresenter;
@property (nonatomic, strong) SCAssetExportSession          * exportSession;

@property (nonatomic, strong) LZUploadImagePresenter        * uploadImagePresenter;

@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, assign) BOOL isSubmit;

@end

@implementation LZCreatePromotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.recordSession) {
        self.umLogPageViewName = @"创建优惠页面";
        self.title = LZLocalizedString(@"create_promotion", nil);
        self.couponListModel = [[LZCouponListModel alloc] init];
        self.uploadImagePresenter = [[LZUploadImagePresenter alloc] init];
        [self uploadVideoImage];
    }
    else {
        self.umLogPageViewName = @"修改优惠页面";
        self.title = LZLocalizedString(@"edit_promotion", nil);
    }

    self.view.backgroundColor = UIColorFromRGB(0xffffff, 1);
    self.couponPresenter = [[LZCouponPresenter alloc] init];
    
    self.isSave = NO;
    self.isSubmit = NO;
    
    [self configViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configViews {

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.submitButton];
    
    WS(weakSelf);
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-45);
    }];
    [self.saveButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(weakSelf.submitButton.mas_leading);
        make.height.mas_equalTo(45);
    }];
    [self.submitButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH/2.0);
        make.height.mas_equalTo(45);
    }];
}

- (LZCreatePromotionTableView *)tableView {
    
    WS(weakSelf);
    if (_tableView == nil) {
        _tableView = [[LZCreatePromotionTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.couponListModel = self.couponListModel;
        
        if (!self.recordSession) {
            if (self.couponListModel.couponsName) {
                _tableView.isShowCoupon = YES;
            }
            
            if (self.couponListModel.grouponName) {
                _tableView.isShowGroup = YES;
            }
        }
        
        _tableView.didSelectRowBlock = ^(NSIndexPath * indexPath) {
            if ((indexPath.section != 1 && indexPath.row != 1) && (indexPath.section != 2 && indexPath.row != 3)) {
                [weakSelf.view endEditing:YES];
            }
            
            if (indexPath.section == 2) {
                if (indexPath.row == 1) {
                    
                    if ([LZAlertViewManager shareInstance].isShowAlert) {
                        return;
                    }
                    
                    LZGroupOrderObjectViewController *vc = [[LZGroupOrderObjectViewController alloc] init];
                    if (weakSelf.couponListModel.grouponFoods.length > 0) {
                        LZGroupItemModel *m = [[LZGroupItemModel alloc] init];
                        m.foodName = weakSelf.couponListModel.grouponFoods;
                        m.foodPrice = weakSelf.couponListModel.grouponBeforeCost;
                        m.isSelect = YES;
                    }
                    
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                    
                    vc.selectGroupOrderBlock = ^(LZGroupItemModel * model) {
                        weakSelf.couponListModel.grouponFoods = model.foodName;
                        weakSelf.couponListModel.grouponBeforeCost = model.foodPrice;
                        
                        weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                        [weakSelf.tableView reloadData];
                    };
                }
                if (indexPath.row == 5) { //Finish time
                    
                    if ([LZAlertViewManager shareInstance].isShowAlert) {
                        return;
                    }
                    
                    [weakSelf.selectDateView showDateView:nil];
                    weakSelf.selectDateView.selectValueBlock = ^(NSString * value) {
                        
                        //当前日期
                        NSString * currentDateString = [NSDate getCurrentDate];
                        
                        //团购到期时间
                        NSString * str = [NSString stringWithFormat:@"%@ %@", value, @"00:00:00"];
                        if ([NSDate compareDate:str withDate:currentDateString] == 1) {
                            
                            LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"mag_gorup_finish_date", nil)
                                                                             andImage:nil
                                                                    cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                    otherButtonTitles:nil,nil];
                            [alert show];
                        }
                        else {
                            NSString * strDate = [NSString stringWithFormat:@"%@ %@", value, @"23:59:59"];
                            double time = [NSDate cTimestampFromString:strDate format:@"yyyy-MM-dd HH:mm:ss"];
                            weakSelf.couponListModel.grouponEndTime = time * 1000;
                            DLog(@"%f, %f", time, time *1000);
                            
                            weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                            [weakSelf.tableView reloadData];
                        }
                    };
                }
                else if (indexPath.row == 6) { // Expiration date
                    
                    if ([LZAlertViewManager shareInstance].isShowAlert) {
                        return;
                    }
                    
                    [weakSelf.selectDateView showDateView:nil];
                    weakSelf.selectDateView.selectValueBlock = ^(NSString * value) {
                        
                        //finish date
                        if (!weakSelf.couponListModel.grouponEndTime) {
                            [LZRemindView initWithImage:[UIImage imageNamed:@"提示对勾"] andContent:LZLocalizedString(@"msg_select_finish_date", nil)];
                            return;
                        }
                        
                        //当前日期
                        NSString * currentDateString = [NSDate getCurrentDate];
                        
                        //使用截止时间
                        NSString * str = [NSString stringWithFormat:@"%@ %@", value, @"00:00:00"];
                        
                        //团购finish时间
                        NSString * strFinishDate = [NSDate dateStrFromCstampTime:weakSelf.couponListModel.grouponEndTime/1000 withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
                        if ([NSDate compareDate:str withDate:currentDateString] == 1) {
                            LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"mag_coupon_expiration_date", nil)
                                                                             andImage:nil
                                                                    cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                    otherButtonTitles:nil,nil];
                            [alert show];
                        }
                        else if ([NSDate compareDate:str withDate:strFinishDate] == 1) {
                            LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"msg_coupon_finish_expiration_date", nil)
                                                                             andImage:nil
                                                                    cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                    otherButtonTitles:nil,nil];
                            [alert show];
                        }
                        else {
                            NSString * strDate = [NSString stringWithFormat:@"%@ %@", value, @"23:59:59"];
                            double time = [NSDate cTimestampFromString:strDate format:@"yyyy-MM-dd HH:mm:ss"];
                            weakSelf.couponListModel.grouponDeadline = time * 1000;
                            
                            weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                            [weakSelf.tableView reloadData];
                        }
                    };
                }
            }
        };
        
        //文本编辑
        _tableView.textValueEditDidEndBlock = ^(NSString * strValue, NSInteger tag, NSIndexPath *indexPath) {
            
            switch (tag) {
                case 300: //标题
                {
                    weakSelf.couponListModel.promotionTitle = [strValue length] > 0 ? strValue : nil;
                }
                    break;
                case 301://食材
                {
                    weakSelf.couponListModel.promotionFood = [strValue length] > 0 ? strValue : nil;
                }
                    break;
                case 302: //标签
                {
                    weakSelf.couponListModel.tag = [strValue length] > 0 ? strValue : nil;
                }
                    break;
                case 303: //描述
                {
                    weakSelf.couponListModel.profile = [strValue length] > 0 ? strValue : nil;
                }
                    break;
                    
                //优惠劵
                case 100: //优惠券名称
                {
                    weakSelf.couponListModel.couponsName = [strValue length] > 0 ? strValue : nil;
                }
                    break;
                case 101: //优惠金额金额
                {
                    if ([strValue floatValue] < 0 || [strValue floatValue] > 10) {
                        
                        [weakSelf.view endEditing:YES];
                        
                        LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"mag_coupon_mamount", nil)
                                                                         andImage:nil
                                                                cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                otherButtonTitles:nil,nil];
                        [alert show];
                    }
                    else
                        weakSelf.couponListModel.couponsMoney = [strValue floatValue];
                }
                    break;
                case 102: //优惠券使用限制
                {
                    weakSelf.couponListModel.couponsUseConditions = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                case 103: //优惠劵数量
                {
                    if ([strValue floatValue] < 0 || [strValue floatValue] > 100) {
                        
                        [weakSelf.view endEditing:YES];
                        weakSelf.couponListModel.couponsTotalCount = -1;
                        LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"mag_coupon_issue", nil)
                                                                         andImage:nil
                                                                cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                otherButtonTitles:nil,nil];
                        [alert show];
                        
                    }
                    else
                        weakSelf.couponListModel.couponsTotalCount = [strValue intValue];
                }
                    break;
                case 105: //优惠例外时间
                {
                    weakSelf.couponListModel.couponsExceptTime = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                case 107: ///预约提醒
                {
                    weakSelf.couponListModel.couponsRemindAppoint = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                case 108: //规则提醒
                {
                    weakSelf.couponListModel.couponsRemindRule = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                    
                //团购设置
                case 200: //团购名称
                {
                    weakSelf.couponListModel.grouponName = [strValue length] > 0 ? strValue : nil;
                }
                    break;
                case 203: //团购价
                {
                    if ([strValue floatValue]  < 0 || [strValue floatValue]  > self.couponListModel.grouponBeforeCost) {
                        
                        [weakSelf.view endEditing:YES];
                        weakSelf.couponListModel.grouponAfterCost = -1;
                        LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"group_price_msg", nil)
                                                                         andImage:nil
                                                                cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                otherButtonTitles:nil,nil];
                        [alert show];
                    }
                    else
                        weakSelf.couponListModel.grouponAfterCost = [strValue floatValue];
                }
                    break;
                case 204: //成团人数
                {
                    if ([strValue floatValue] < 2 || [strValue floatValue] > 51) {
                        
                        [weakSelf.view endEditing:YES];
                        weakSelf.couponListModel.grouponCount = -1;
                        LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"msg_people_num", nil)
                                                                         andImage:nil
                                                                cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                otherButtonTitles:nil,nil];
                        [alert show];
                    }
                    else
                        weakSelf.couponListModel.grouponCount = [strValue intValue];
                }
                    break;
                case 207: //除外日期
                {
                    weakSelf.couponListModel.grouponExceptTime = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                case 209: //团购提醒
                {
                    weakSelf.couponListModel.grouponRemindAppoint = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                case 210: //团购规则
                {
                    weakSelf.couponListModel.grouponRemindRule = [strValue length] > 0 ? strValue : @"";
                }
                    break;
                default:
                    break;
            }

            weakSelf.tableView.couponListModel = weakSelf.couponListModel;
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView endUpdates];
        };
        
//        //优惠平台选择
//        _tableView.selectButtonActionBlock = ^(NSIndexPath * indexPath, NSInteger value) {
//            
//            if (indexPath.section == 1 && indexPath.row == 2) {
//                weakSelf.couponListModel.couponsOrigin = (int)value;
//            }
//            else if (indexPath.section == 2 && indexPath.row == 4) {
//                weakSelf.couponListModel.grouponOrigin = (int)value;
//            }
//            
//            weakSelf.tableView.couponListModel = weakSelf.couponListModel;
//            [weakSelf.tableView reloadData];
//        };
        
        //时间日期选择
        _tableView.tapGRActionBlock = ^(NSIndexPath * indexPath, id sender) {
            UIView * v = sender;
            [weakSelf.view endEditing:YES];
            
            if (indexPath.section == 1) {
                if (indexPath.row == 4) { // coupon valid from/to
                    
                    if ([LZAlertViewManager shareInstance].isShowAlert) {
                        return;
                    }
                    
                    [weakSelf.selectDateView showDateView:nil];
                    weakSelf.selectDateView.selectValueBlock = ^(NSString * value) {
                        if (v.tag == 1000) {
                            
                            //当前日期
                            NSString * currentDateString = [NSDate getCurrentDate];
                            
                            //优惠开始时间
                            NSString * str = [NSString stringWithFormat:@"%@ %@", value, @"00:00:00"];
                            
                            if ([NSDate compareDate:currentDateString withDate:str] == 1) {
                                
                                DLog(@"%@", str);
                                double time = [NSDate cTimestampFromString:str format:@"yyyy-MM-dd HH:mm:ss"];
                                weakSelf.couponListModel.couponsStartTime = time * 1000;
                                DLog(@"%f, %f", weakSelf.couponListModel.couponsStartTime, time);
                            }
                            else {
                                LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"mag_coupon_start_date", nil)
                                                                                 andImage:nil
                                                                        cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                        otherButtonTitles:nil, nil];
                                [alert show];
                            }
                            
                        } else {
                            if (!weakSelf.couponListModel.couponsStartTime) {
                                [LZRemindView initWithImage:[UIImage imageNamed:@"提示对勾"] andContent:LZLocalizedString(@"msg_select_start_date", nil)];
                                return;
                            }
                            
                            //当前日期
                            NSString * currentDateString = [NSDate getCurrentDate];
                            
                            //优惠结束时间
                            NSString * str = [NSString stringWithFormat:@"%@ %@", value, @"23:59:59"];
                            
                            //优惠开始时间
                            NSString * strStartDate = [NSDate dateStrFromCstampTime:weakSelf.couponListModel.couponsStartTime/1000 withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
                            if ([NSDate compareDate:str withDate:currentDateString] == 1) {
                                LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"mag_coupon_finish_date", nil)
                                                                                 andImage:nil
                                                                        cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                        otherButtonTitles:nil, nil];
                                [alert show];
                            }
                            else if ([NSDate compareDate:str withDate:strStartDate] == 1)  {
                                LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"msg_coupon_finish_start_date", nil)
                                                                                 andImage:nil
                                                                        cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                                        otherButtonTitles:nil, nil];
                                [alert show];
                            }
                            else {
                                DLog(@"%@", str);
                                double time = [NSDate cTimestampFromString:str format:@"yyyy-MM-dd HH:mm:ss"];
                                weakSelf.couponListModel.couponsEndTime = time * 1000;
                                DLog(@"%f, %f", weakSelf.couponListModel.couponsEndTime, time);
                            }
                        }
                        
                        weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                        [weakSelf.tableView reloadData];
                    };
                }
                else if (indexPath.row == 6){ // coupon everyday valid from/to
                    
                    if ([LZAlertViewManager shareInstance].isShowAlert) {
                        return;
                    }
                    
                    if (v.tag == 1000) {
                        [weakSelf.selectTimeView showTimeView:weakSelf.couponListModel.couponsStartDaytime andTimeType:SELECT_TIME_TYPE_Start];
                    } else {
                        [weakSelf.selectTimeView showTimeView:weakSelf.couponListModel.couponsEndDaytime andTimeType:SELECT_TIME_TYPE_End];
                    }
                    
                    weakSelf.selectTimeView.selectValueBlock = ^(NSString * value) {
                        if (v.tag == 1000) {
                            weakSelf.couponListModel.couponsStartDaytime = value;
                        } else {
                            weakSelf.couponListModel.couponsEndDaytime = value;
                        }
                        weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                        [weakSelf.tableView reloadData];
                    };
                }
            }
            else {
                if (indexPath.row == 8) { // group everday valid from/to
                    
                    if ([LZAlertViewManager shareInstance].isShowAlert) {
                        return;
                    }
                    
                    if (v.tag == 1000) {
                        [weakSelf.selectTimeView showTimeView:weakSelf.couponListModel.grouponStartDaytime andTimeType:SELECT_TIME_TYPE_Start];
                    } else {
                        [weakSelf.selectTimeView showTimeView:weakSelf.couponListModel.grouponEndDaytime andTimeType:SELECT_TIME_TYPE_End];
                    }
                    
                    weakSelf.selectTimeView.selectValueBlock = ^(NSString * value) {
                        if (v.tag == 1000) {
                            weakSelf.couponListModel.grouponStartDaytime = value;
                        } else {
                            weakSelf.couponListModel.grouponEndDaytime = value;
                        }
                        weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                        [weakSelf.tableView reloadData];
                    };
                }
            }
        };
    }
    
    return _tableView;
}

- (UIButton *)saveButton {

    WS(weakSelf);
    if (_saveButton == nil) {
        _saveButton = [[UIButton alloc] init];
        _saveButton.backgroundColor = UIColorFromRGB(0x333333, 1);
        [_saveButton setTitle:LZLocalizedString(@"save", @"") forState:UIControlStateNormal];
        [_saveButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
        [_saveButton bk_addEventHandler:^(id sender) {
            
            if ([weakSelf checkModel] == NO) {
                return;
            }
            
            if (!weakSelf.isSave) {
                weakSelf.isSave = YES;
                //保存
                weakSelf.couponListModel.state = 1;
                
                if (weakSelf.eventCode == kCouponList_edit) {
                    [weakSelf modifyCoupon];
                }
                else if (weakSelf.eventCode == kCouponList_copy) {
                    weakSelf.couponListModel.couponId = nil;
                    [weakSelf pushCoupon];
                }
                else {
                    DLog(@"save----------上传视频")
                    [weakSelf uploadVideo:kSaveTag];
                }
            }

        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _saveButton;
}

- (UIButton *)submitButton {
    
    WS(weakSelf);
    if (_submitButton == nil) {
        _submitButton = [[UIButton alloc] init];
        _submitButton.backgroundColor = UIColorFromRGB(0x33a928, 1);
        [_submitButton setTitle:LZLocalizedString(@"submit_min", @"") forState:UIControlStateNormal];
        [_submitButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
        [_submitButton bk_addEventHandler:^(id sender) {
            
            if ([weakSelf checkModel] == NO) {
                return;
            }

            if (!weakSelf.isSubmit) {
                weakSelf.isSubmit = YES;
                //提交
                weakSelf.couponListModel.state = 2;

                if (weakSelf.eventCode == kCouponList_edit) {
                    [weakSelf modifyCoupon];
                }
                else if (weakSelf.eventCode == kCouponList_copy) {
                    weakSelf.couponListModel.couponId = nil;
                    [weakSelf pushCoupon];
                }
                else {
                    DLog(@"submit----------上传视频")
                    [weakSelf uploadVideo:kSubmitTag];
                }
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _submitButton;
}

- (LZSelectDateView *)selectDateView {
    if (_selectDateView == nil) {
        _selectDateView = [[LZSelectDateView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) andSelectType:SELECT_TYPE_DATE];
    }
    return _selectDateView;
}

- (LZSelectDateView *)selectTimeView {
    if (_selectTimeView == nil) {
        _selectTimeView = [[LZSelectDateView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) andSelectType:SELECT_TYPE_TIME];
    }
    return _selectTimeView;
}


//上传视频
- (void)uploadVideo:(SaveOrSubmitTag)tag {
    
    [self startLoadingViewForView:self.view loadingViewUserInteractionEnabled:YES];
    
    NSString * temppath = NSTemporaryDirectory();
    temppath = [temppath stringByAppendingPathComponent:@"ExportVideo"];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:temppath isDirectory:NULL];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:temppath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    temppath = [temppath stringByAppendingPathComponent:@"ConponVideo.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temppath isDirectory:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:temppath error:NULL];
    }
    
    DLog(@"%@", temppath);
    
    WS(weakSelf);
    //    4.导出
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    [LZVideoTools compressVideo:self.recordSession.assetRepresentingSegments videoComposition:nil outputFilePath:temppath timeRange:range completion:^(NSString *savedPath) {
        if(savedPath) {
            DLog(@"导出视频路径：%@", savedPath);
            [self.uploadImagePresenter uploadVideoPath:savedPath andBusinessId:[LZUserModel Instance].sellerId andBusinessType:@"3" andBusinessNo:@"1" andonSuccess:^(id data) {
                [weakSelf stopLoadingViewForView:self.view];
                DLog(@"上传视频: %@", data);
                
                NSArray *resultArray = data[@"data"];
                if (resultArray.count>0) {
                    NSDictionary *dic = resultArray[0];
                    NSString *filePath = dic[@"filePath"];
                    weakSelf.couponListModel.videoUrl = filePath;
                    [weakSelf pushCoupon];
                }
            } onFail:^(NSString *fail) {
                if (tag ==kSaveTag) {
                    LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"save_fail", nil)
                                                                     andImage:nil
                                                            cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                            otherButtonTitles:LZLocalizedString(@"try_again", nil),nil];
                    [alert show];
                    alert.clickButtonIndexBlock = ^(NSInteger index) {
                        if (index == 1) {
                            [weakSelf uploadVideo:kSaveTag];
                        }
                    };
                }
                else if (tag == kSubmitTag) {
                    LZAlertView *alert = [[LZAlertView alloc] initWithContent:LZLocalizedString(@"submit_fail", nil)
                                                                     andImage:nil
                                                            cancelButtonTitle:LZLocalizedString(@"cancel", nil)
                                                            otherButtonTitles:LZLocalizedString(@"try_again", nil),nil];
                    [alert show];
                    alert.clickButtonIndexBlock = ^(NSInteger index) {
                        if (index == 1) {
                            [weakSelf uploadVideo:kSubmitTag];
                        }
                    };
                }
                
            }];
        }
        else {
            [weakSelf stopLoadingViewForView:self.view];
            DLog(@"导出视频路径出错：%@", savedPath);
        }
    }];
}

//上传视频图片
- (void)uploadVideoImage {
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime actualTime;
    CGImageRef image = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(0.0, 600) actualTime:&actualTime error:nil];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    WS(weakSelf)
    //上传视频图片
    [self.uploadImagePresenter uploadImage:img
                             andBusinessId:[LZUserModel Instance].sellerId
                           andBusinessType:@"9"
                             andBusinessNo:@"1"
                                andIsThumb:NO
                                   andSize:CGSizeZero
                              andonSuccess:^(id data) {
                                  DLog(@"上传视频图片: %@", data);
                                  
                                  NSArray *resultArray = data[@"data"];
                                  if (resultArray.count>0) {
                                      NSDictionary *dic = resultArray[0];
                                      NSString *filePath = dic[@"filePath"];
                                      weakSelf.couponListModel.videoPhoto = filePath;
                                      weakSelf.tableView.couponListModel = weakSelf.couponListModel;
                                      [weakSelf.tableView reloadData];
                                  }
                                  
                              } onFail:^(NSString *fail) {
                                  
                              }];
}

//校验字段
- (BOOL)checkModel{

    //当前日期
    NSString * currentDateString = [NSDate getCurrentDate];
    //优惠开始时间
    NSString * strStartDate = [NSDate dateStrFromCstampTime:self.couponListModel.couponsStartTime/1000 withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //优惠结束时间
    NSString * strEndDate = [NSDate dateStrFromCstampTime:self.couponListModel.couponsEndTime/1000 withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //团购结束时间
    NSString * strFinishDate = [NSDate dateStrFromCstampTime:self.couponListModel.grouponEndTime/1000 withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //团购到期时间
    NSString * strGroupEndDate = [NSDate dateStrFromCstampTime:self.couponListModel.grouponDeadline/1000 withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (!self.couponListModel.promotionTitle) {
        [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"please_enter_promotion_name", nil)];
        return NO;
    }
    else if (!self.couponListModel.promotionFood) {
        [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_ingredients_components", nil)];
        return NO;
    }
    else if (!self.couponListModel.tag) {
        [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_tags", nil)];
        return NO;
    }
    else if (!self.couponListModel.profile) {
        [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_description", nil)];
        return NO;
    }

    //coupon
    
    if (self.tableView.isShowCoupon) {
    
        if (!self.couponListModel.couponsName) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_coupon_name", nil)];
            return NO;
        }
        else if (self.couponListModel.couponsMoney <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_coupon_amount", nil)];
            return NO;
        }
        else if (self.couponListModel.couponsTotalCount <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_coupon_to_issue", nil)];
            return NO;
        }
        else if (self.couponListModel.couponsTotalCount < 0 || self.couponListModel.couponsTotalCount > 100) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"mag_coupon_issue", nil)];
            return NO;
        }
        else if (self.couponListModel.couponsStartTime <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_valid_from_to", nil)];
            return NO;
        }
        else if ([NSDate compareDate:strStartDate withDate:currentDateString] == 1) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"mag_coupon_start_date", nil)];
            return NO;
        }
        else if (self.couponListModel.couponsEndTime <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_valid_from_to", nil)];
            return NO;
        }
        else if ([NSDate compareDate:strEndDate withDate:currentDateString] == 1) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"mag_coupon_finish_date", nil)];
            return NO;
        }
        else if ([NSDate compareDate:strEndDate withDate:strStartDate] == 1)  {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_coupon_finish_start_date", nil)];
            return NO;
        }
        else if (!self.couponListModel.couponsStartDaytime) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_couopon_everyday_valid", nil)];
            return NO;
        }
        else if (!self.couponListModel.couponsEndDaytime) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_couopon_everyday_valid", nil)];
            return NO;
        }
    }
    
    //group
    
    if (self.tableView.isShowGroup) {
        
        if (!self.couponListModel.grouponName) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_order_name", nil)];
            return NO;
        }
        else if (!self.couponListModel.grouponFoods) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_order_select", nil)];
            return NO;
        }
        else if (!self.couponListModel.grouponAfterCost) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_price", nil)];
            return NO;
        }
        else if (self.couponListModel.grouponAfterCost < 0 || self.couponListModel.grouponAfterCost > self.couponListModel.grouponBeforeCost) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"group_price_msg", nil)];
            return NO;
        }
        else if (self.couponListModel.grouponCount <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_people_number", nil)];
            return NO;
        }
        else if (self.couponListModel.grouponCount < 1 || self.couponListModel.grouponCount > 51) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_people_num", nil)];
            return NO;
        }
        else if (self.couponListModel.grouponEndTime <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_finish_date", nil)];
            return NO;
        }
        else if ([NSDate compareDate:strFinishDate withDate:currentDateString] == 1) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"mag_gorup_finish_date", nil)];
            return NO;
        }
        else if (self.couponListModel.grouponDeadline <= 0) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_expiration_date", nil)];
            return NO;
        }
        else if ([NSDate compareDate:strGroupEndDate withDate:currentDateString] == 1) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"mag_coupon_expiration_date", nil)];
            return NO;
        }
        else if ([NSDate compareDate:strGroupEndDate withDate:strFinishDate] == 1) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_coupon_finish_expiration_date", nil)];
            return NO;
        }
        else if (!self.couponListModel.grouponStartDaytime) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_everyday_valid", nil)];
            return NO;
        }
        else if (!self.couponListModel.grouponEndDaytime) {
            [LZRemindView initWithImage:[UIImage imageNamed:@"错误提示"] andContent:LZLocalizedString(@"msg_enter_group_everyday_valid", nil)];
            return NO;
        }
    }
    
    self.couponListModel.isDelete = 1;
    
    return YES;
}

//创建完优惠，删除视频临时文件
- (void)clearVideoFile {
    NSString * temppath = NSTemporaryDirectory();
    NSString * exportTemppath = [temppath stringByAppendingPathComponent:@"ExportVideo"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportTemppath isDirectory:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportTemppath error:NULL];
    }
    NSString * recordTemppath = [temppath stringByAppendingPathComponent:@"ConponVideo.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:recordTemppath isDirectory:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:recordTemppath error:NULL];
    }
}

- (void)competionCoupon:(LZCouponListModel *)model {
    if (self.couponListModel.state == 1) {
        //点击save 按钮如果是编辑,copy 事件进入,则返回相应的操作状态
        if (self.eventCode == kCouponList_edit || self.eventCode == kCouponList_copy) {
            if (self.operationCouponStateSuccessBlock) {
                self.operationCouponStateSuccessBlock(kCouponList_saved,self.couponListModel);
            }
            //如果是从优惠详情进入,则返回时跳过优惠详情,直接进入列表
            if (self.isComeFromCouponDetailVC) {
                NSMutableArray *vcArrays = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                for (UIViewController *viewController in vcArrays) {
                    if ([viewController isKindOfClass:[LZCouponManagerListDetailViewController class]]){
                        [vcArrays removeObject:viewController];
                        break;
                    }
                }
                self.navigationController.viewControllers = vcArrays;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            LZCouponManagerListDetailViewController * vc = [[LZCouponManagerListDetailViewController alloc] init];
            vc.couponListModel = model;
            [self.navigationController pushViewController:vc animated:YES];
            
            [self lz_removeSelfFromNavigation];
            
            if(self.recordSession) {
                
                NSMutableArray *vcArrays = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                for (UIViewController *viewController in vcArrays) {
                    if ([viewController isKindOfClass:[LZNewPromotionVC class]]){
                        [vcArrays removeObject:viewController];
                        break;
                    }
                }
                for (UIViewController *viewController in vcArrays) {
                    if ([viewController isKindOfClass:[LZVideoDetailsVC class]]){
                        [vcArrays removeObject:viewController];
                        break;
                    }
                }
                for (UIViewController *viewController in vcArrays) {
                    if ([viewController isKindOfClass:[LZCreatePromotionViewController class]]){
                        [vcArrays removeObject:viewController];
                        break;
                    }
                }
                self.navigationController.viewControllers = vcArrays;
                
                [self clearVideoFile];
            }
        }
    }
    else {
        
        //点击submit按钮===如果是编辑,copy 事件进入,则返回相应的操作状态
        if (self.eventCode == kCouponList_edit || self.eventCode == kCouponList_copy) {
            
            if (self.operationCouponStateSuccessBlock) {
                self.operationCouponStateSuccessBlock(kCouponList_submit,self.couponListModel);
            }
            //如果是从优惠详情进入,则返回时跳过优惠详情,直接进入列表
            if (self.isComeFromCouponDetailVC) {
                NSMutableArray *vcArrays = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                for (UIViewController *viewController in vcArrays) {
                    if ([viewController isKindOfClass:[LZCouponManagerListDetailViewController class]]){
                        [vcArrays removeObject:viewController];
                        break;
                    }
                }
                self.navigationController.viewControllers = vcArrays;
            }

            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
        
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

//提交优惠 1.创建新优惠；2.拷贝优惠
- (void)pushCoupon {
    
    [self startLoadingViewForView:self.view loadingViewUserInteractionEnabled:YES];
    
    WS(weakSelf);
    [self.couponPresenter publishCouponWithLocalCouponModel:self.couponListModel ResultSuccess:^(LZCouponListModel *completeCouponModel) {
        
        [weakSelf stopLoadingViewForView:weakSelf.view];
        
        [weakSelf competionCoupon:completeCouponModel];
        if (weakSelf.isSave) {
            weakSelf.isSave = NO;
        }
        if (weakSelf.isSubmit) {
            weakSelf.isSubmit = NO;
        }
    } Failure:^(NSString *fail) {
        
        [weakSelf stopLoadingViewForView:weakSelf.view];
        
        DLog(@"%@", fail);
        if (weakSelf.isSave) {
            weakSelf.isSave = NO;
        }
        if (weakSelf.isSubmit) {
            weakSelf.isSubmit = NO;
        }
    }];
}

//修改优惠--优惠列表已保存的
- (void)modifyCoupon {
    
    [self startLoadingViewForView:self.view loadingViewUserInteractionEnabled:YES];
    
    WS(weakSelf);
    [self.couponPresenter modifyCouponWithCouponModel:self.couponListModel ResultSuccess:^(id data) {
        
        [weakSelf stopLoadingViewForView:weakSelf.view];
        
        [weakSelf competionCoupon:nil];
        if (weakSelf.isSave) {
            weakSelf.isSave = NO;
        }
        if (weakSelf.isSubmit) {
            weakSelf.isSubmit = NO;
        }
        
    } Failure:^(NSString *fail) {
        
        [weakSelf stopLoadingViewForView:weakSelf.view];
        
        DLog(@"%@", fail);
        if (weakSelf.isSave) {
            weakSelf.isSave = NO;
        }
        if (weakSelf.isSubmit) {
            weakSelf.isSubmit = NO;
        }

    }];
}

@end
