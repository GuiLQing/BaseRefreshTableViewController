//
//  BaseRefreshTableViewController.m
//  BaseRefreshTableViewController
//
//  Created by SNICE on 2018/8/7.
//  Copyright © 2018年 G. All rights reserved.
//

#import "BaseRefreshTableViewController.h"
#import "MJRefresh.h"

#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif

#define ISIPHONEX                           ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.width == 1125 : NO)
//状态栏、导航栏高度
#define STATUS_NEAT_BANG_HEIGHT (ISIPHONEX ? 24 : 0)    //齐刘海高度
#define STATUS_BAR_HEIGHT (ISIPHONEX ? 44 : 20)
#define NAVIGATION_BAR_HEIGHT (44)
#define STATUS_AND_NAVIGATION_BAR_HEIGHT ((STATUS_BAR_HEIGHT) + (NAVIGATION_BAR_HEIGHT))

//底部栏高度
#define TABBAR_HEIGHT (ISIPHONEX ? 83 : 49)
// 底部安全区域远离高度
#define kBottomSafeHeight   (CGFloat)(ISIPHONEX ? (34) : (0))
//iPhone X底部home键高度
#define kBottomHomeHeight   (CGFloat)(ISIPHONEX ? (10) : (0))
//屏幕
#define SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT       ([UIScreen mainScreen].bounds.size.height)
#define TABLE_VIEW_HEIGHT (SCREEN_HEIGHT - STATUS_AND_NAVIGATION_BAR_HEIGHT - kBottomSafeHeight + STATUS_NEAT_BANG_HEIGHT)
#define TABLE_VIEW_HEIGHT_WITH_TABBAR (TABLE_VIEW_HEIGHT - TABBAR_HEIGHT + kBottomHomeHeight)

#define HexColor(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

static const CGFloat SNICEDuration = 0.5;
static const NSInteger DETAULT_START_PAGENUMBER = 1;    //默认第一页从1开始
static const NSInteger PAGE_COUNT = 20;                 //默认每页加载20个
static const NSInteger TABLEVIEW_NO_DATA_VIEW_TAG = 1528439894;

@implementation BaseTableView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.touchDelegate conformsToProtocol:@protocol(TouchTableViewDelegate)] &&
        [self.touchDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)])
    {
        [self.touchDelegate tableView:self touchesBegan:touches withEvent:event];
    }
}

- (void)reloadData {
    [super reloadData];
    [self showNoDataView];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertSections:sections withRowAnimation:animation];
    [self showNoDataView];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteSections:sections withRowAnimation:animation];
    [self showNoDataView];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super reloadSections:sections withRowAnimation:animation];
    [self showNoDataView];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showNoDataView];
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showNoDataView];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showNoDataView];
}

- (void)showNoDataView {
    NSInteger sectionCount = self.numberOfSections;
    NSInteger rowCount = 0;
    for (int i = 0; i < sectionCount; i++) {
        rowCount += [self.dataSource tableView:self numberOfRowsInSection:i];
    }
    if (rowCount == 0 && self.isShowNoDataView) {
        self.backgroundView = self.defaultNoDataView;
        [self.defaultNoDataView viewWithTag:TABLEVIEW_NO_DATA_VIEW_TAG].center = CGPointMake(self.defaultNoDataView.frame.size.width / 2, (self.defaultNoDataView.frame.size.height - self.tableHeaderView.frame.size.height) / 2 + self.tableHeaderView.frame.size.height);
    } else {
        self.backgroundView = [[UIView alloc] init];
    }
}

- (UIView *)defaultNoDataView {
    if (!_defaultNoDataView) {
        _defaultNoDataView = [[UIView alloc] initWithFrame:self.bounds];
        
        UIView *backView = [[UIView alloc] init];
        backView.tag = TABLEVIEW_NO_DATA_VIEW_TAG;
        [_defaultNoDataView addSubview:backView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadDataAction)];
        [backView addGestureRecognizer:tap];
        
        UIImage *image = [UIImage imageNamed:@"UITableViewPlaceholder.bundle/TableViewNoData"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        [backView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"暂无数据,点击刷新";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = HexColor(0x666666);
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        [backView addSubview:label];
        
        backView.frame = CGRectMake(0, 0, MAX(image.size.width, label.frame.size.width), image.size.height + 15.0f + label.frame.size.height);
        imageView.frame = CGRectMake((backView.frame.size.width - image.size.width) / 2.0, 0, image.size.width, image.size.height);
        label.frame = CGRectMake((backView.frame.size.width - label.frame.size.width) / 2.0, backView.frame.size.height - label.frame.size.height, label.frame.size.width, label.frame.size.height);
        backView.center = _defaultNoDataView.center;
    }
    return _defaultNoDataView;
}

- (void)loadDataAction {
    if (self.didClickNoDataView) self.didClickNoDataView();
}

@end

@interface BaseRefreshTableViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation BaseRefreshTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = HexColor(0xffffff);
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView = [[BaseTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLE_VIEW_HEIGHT) style:self.isGroupedTableView ? UITableViewStyleGrouped : UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.touchDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = HexColor(0xf5f7f9);
    self.tableView.scrollsToTop = YES;
    @weakify(self);
    self.tableView.didClickNoDataView = ^{
        @strongify(self);
        [self queryDataSourceIsLoadMore:NO];
    };
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UITabBarController *tabBarController = (UITabBarController *)keyWindow.rootViewController;
    if ([tabBarController isKindOfClass:[UITabBarController class]]) {
        for (UINavigationController *nvc in tabBarController.viewControllers) {
            //第一个视图控制器
            UIViewController *vc = nvc.viewControllers.firstObject;
            if ([vc isEqual:self]) {
                //如果当前页面在首页，首页有tabBar，所以tableView的高度要减少
                self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, TABLE_VIEW_HEIGHT_WITH_TABBAR);
                break;
            }
        }
    }
    
    //下拉刷新
    if (self.isShowPulldownToRefresh) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self queryDataSourceIsLoadMore:NO];
        }];
    }
    
    //上拉加载
    if (self.isShowPullupToLoad) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self);
            if (self.tableView.mj_header.refreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            [self queryDataSourceIsLoadMore:YES];
        }];
        // 禁止自动加载
        footer.automaticallyRefresh = NO;
        footer.hidden = YES;
        // 设置footer
        self.tableView.mj_footer = footer;
    }
    
    //菊花
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.tableView addSubview:self.activityIndicatorView];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    //首次加载，默认显示菊花转动
    [self startLoading];
    if (!self.isCloseFirstRequest) {
        [self initDefaultLoadDataSourse];
    } else {
        [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.5];
    }
    
    //默认每页请求个数20个
    self.pageSize = PAGE_COUNT;
}


/**
 首次默认加载
 */
- (void)initDefaultLoadDataSourse{
    //首次加载，默认加载是否更多为NO
    [self queryDataSourceIsLoadMore:NO];
}

/**
 请求数据完成
 
 @param isLoadMore isLoadMore description
 */
- (void)doneLoadingTableViewData:(BOOL)isLoadMore{
    [self stopLoading];
    if (!isLoadMore) {
        [self.tableView.mj_header endRefreshing];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - activityIndicatorView Animation

- (void)stopLoading
{
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)startLoading
{
    if (![self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView startAnimating];
    }
}

#pragma mark - request

- (void)queryDataSourceIsLoadMore:(BOOL)isLoadMore{
    self.tableView.backgroundView = [[UIView alloc] init];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLoading) object:nil];
    [self startLoading];
    if (!isLoadMore) {
        self.pageNumber = DETAULT_START_PAGENUMBER;
    } else {
        self.pageNumber ++;
    }
    // !!!:override---子类重写
}

- (void)parseResultWithJson:(id)json isLoadMore:(BOOL)isLoadMore{
    // !!!:override---子类重写
}

- (void)dispatchAsyncForMainIsLoadMore:(BOOL)isLoadMore
{
    // !!!:override---子类重写
}

#pragma mark - request callBack

/**
 请求数据成功回调
 
 @param json 数据
 @param isLoadMore 是否加载更多
 */
- (void)successResultWithJson:(id)json isLoadMore:(BOOL)isLoadMore{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SNICEDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData:isLoadMore];
        //解析数据
        [self parseResultWithJson:json isLoadMore:isLoadMore];
        [self.tableView reloadData];
        [self dispatchAsyncForMainIsLoadMore:isLoadMore];
    });
}

- (void)failureResultIsLoadMore:(BOOL)isLoadMore{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SNICEDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doneLoadingTableViewData:isLoadMore];
        [self dealWithDataSource:@[] objectIdKey:nil isLoadMore:isLoadMore isShowNoDataView:YES];
        [self.tableView reloadData];
    });
}

#pragma mark - tableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // !!!:override---子类重写
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // !!!:override---子类重写
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // !!!:override---子类重写
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    // !!!:override---子类重写
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    // !!!:override---子类重写
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    // !!!:override---子类重写
    return nil;
}

#pragma mark - data dealWith

- (void)dealWithDataSource:(NSArray *)dataSource objectIdKey:(NSString *)objectIdKey isLoadMore:(BOOL)isLoadMore isShowNoDataView:(BOOL)isShowNoDataView {
    if (!dataSource || dataSource.count < self.pageSize) {
        BOOL isShow = isShowNoDataView && dataSource.count == 0;
        self.tableView.isShowNoDataView = isShow;
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        self.tableView.isShowNoDataView = NO;
        [self.tableView.mj_footer resetNoMoreData];
        self.tableView.mj_footer.hidden = !self.isShowPullupToLoad;
        
        if (objectIdKey) {
            if (!isLoadMore) {
                self.allObjectIds = [NSMutableArray array];
            }
            for (NSDictionary *obj in dataSource) {
                [self.allObjectIds addObject:obj[objectIdKey]];
            }
        }
    }
}

@end
