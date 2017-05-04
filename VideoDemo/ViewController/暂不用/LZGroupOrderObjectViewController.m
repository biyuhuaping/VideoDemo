//
//  LZGroupOrderObjectViewController.m
//  laziz_Merchant
//
//  Created by xbnzd on 17/4/1.
//  Copyright © 2017年 XBN. All rights reserved.
//

#import "LZGroupOrderObjectViewController.h"
#import "LZGroupOrderCollectionViewCell.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "UIViewController+NavigationItemSetting.h"
#import "LZCreatNewGroupOrderObjectView.h"

#import "Masonry.h"
#import "LZUserInfoPresenter.h"
#import "LZGroupItemModel.h"
#import "MJExtension.h"
#import "extobjc.h"

@interface LZGroupOrderObjectViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) LZUserInfoPresenter * userInfoPresenter;
@property (nonatomic, strong) __block NSMutableArray * dataArray;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) LZCreatNewGroupOrderObjectView *addGroupOrderObjectView;
@end

@implementation LZGroupOrderObjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    [self configureNavBar];
    
    [self getListData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


#pragma mark - UI
- (void)configureUI
{
    self.umLogPageViewName = @"发布优惠,团购菜品的vc";
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LZLocalizedString(@"object_of_the_group_order_title", @"");
    self.userInfoPresenter = [[LZUserInfoPresenter alloc] init];
    self.dataArray = [NSMutableArray array];
    
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(20, 10, -50, 10));
    }];
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(0);
    }];
        
}

- (void)configureNavBar
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    UIImage *addImage = [UIImage imageNamed:@"managepic_nav_add"];
    [btn setImage:addImage forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(creatNewOrderObjectAction) forControlEvents:UIControlEventTouchUpInside];
    [self navigationItemSetting:@[btn] type:NAVIGATIONITEMSETTING_RIGHT];
}


#pragma mark - event

/**
 创建新的优惠菜品
 */
- (void)creatNewOrderObjectAction
{
    [self.addGroupOrderObjectView showView];
    @weakify(self);
    self.addGroupOrderObjectView.addNewGroupOrderObjectBlock = ^(NSString *name, NSString *price){
        @strongify(self);
        [self addNewGroupOrderObjectActionWithName:name price:price];
    };
}

- (void)addNewGroupOrderObjectActionWithName:(NSString *)name price:(NSString *)price
{
    [self startLoadingViewForView:self.view loadingViewUserInteractionEnabled:NO];
    @weakify(self);
    [self.userInfoPresenter addGroupOrderObjectWithName:name Price:price Success:^(id data) {
        @strongify(self);
        [self stopLoadingViewForView:self.view];
        [self getListData];
//        [self.collectionView reloadData];
        
    } Failure:^(NSString *fail) {
        @strongify(self);
        [self stopLoadingViewForView:self.view];
    }];
}

- (void)confirmBtnAction
{
    if (self.selectGroupOrderBlock) {
        self.selectGroupOrderBlock(self.currentSelectModel);
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)getListData {
    
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    [self startLoadingViewForView:self.view loadingViewUserInteractionEnabled:NO];
    @weakify(self);
    //获取团购商品列表
    [self.userInfoPresenter userGetGrouponListSuccess:^(id data) {
        @strongify(self);
        [self stopLoadingViewForView:self.view];
        NSMutableArray * tempArray = [data objectForKey:@"data"];
        for (int i = 0; i < tempArray.count; i++) {
            LZGroupItemModel * model = [LZGroupItemModel mj_objectWithKeyValues:tempArray[i]];
            if (model) {
                model.isSelect = NO;
                [self.dataArray addObject:model];
            }
        }
        
        [self.collectionView reloadData];
        
    } onFail:^(NSString *fail) {
        DLog(@"获取团购商品列表：%@", fail);
        @strongify(self);
        [self stopLoadingViewForView:self.view];
    }];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LZGroupItemModel *model = self.dataArray[indexPath.row];
    return [LZGroupOrderCollectionViewCell getCellSizeWithText:model.foodName];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LZGroupItemModel *model = self.dataArray[indexPath.row];
    
    LZGroupOrderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"groupOrderCell" forIndexPath:indexPath];
    [cell setModel:model];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    for (int i = 0; i < self.dataArray.count; i++) {
        LZGroupItemModel *model = self.dataArray[i];
        if (indexPath.row == i) {
            model.isSelect = YES;
            self.currentSelectModel = model;
        } else {
            model.isSelect = NO;
        }
    }
    
    [self.collectionView reloadData];
}


#pragma mark - 初始化
- (UICollectionView *)collectionView {
    
    if (_collectionView == nil) {
        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColorFromRGB(0xffffff, 1);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[LZGroupOrderCollectionViewCell class] forCellWithReuseIdentifier:@"groupOrderCell"];
        
    }
    
    return _collectionView;
}

- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.backgroundColor = UIColorFromRGB(0x33a928, 1);
        [_confirmButton setTitle:LZLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confirmButton;
}

- (LZCreatNewGroupOrderObjectView *)addGroupOrderObjectView
{
    if (_addGroupOrderObjectView) {
        return  _addGroupOrderObjectView;
    }
    
    _addGroupOrderObjectView = [[NSBundle mainBundle] loadNibNamed:@"LZCreatNewGroupOrderObjectView" owner:self options:nil].lastObject;
    _addGroupOrderObjectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    return _addGroupOrderObjectView;
}


@end
