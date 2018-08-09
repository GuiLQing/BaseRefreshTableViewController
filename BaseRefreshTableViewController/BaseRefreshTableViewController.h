//
//  BaseRefreshTableViewController.h
//  BaseRefreshTableViewController
//
//  Created by SNICE on 2018/8/7.
//  Copyright © 2018年 G. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchTableViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface BaseTableView : UITableView

@property (nonatomic,assign) id<TouchTableViewDelegate> touchDelegate;

@property (nonatomic, assign) BOOL isShowNoDataView;  //是否显示无图片提示
@property (nonatomic, strong) UIView *defaultNoDataView;
@property (nonatomic, strong) void (^didClickNoDataView)(void);

@end

@interface BaseRefreshTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TouchTableViewDelegate>

@property (nonatomic, strong) BaseTableView *tableView;
@property (nonatomic, assign) NSInteger pageNumber;         //翻页页码，默认从1开始
@property (nonatomic, strong) NSMutableArray *allObjectIds; //所以数据的唯一标识集合
@property (nonatomic, assign) NSInteger pageSize;           //每页请求个数，默认20

// !!!:子类继承之后，如需设置，在ViewDidLoad之前调用一下属性
@property (nonatomic, assign) BOOL isShowPulldownToRefresh; //是否显示下拉刷新
@property (nonatomic, assign) BOOL isShowPullupToLoad;      //是否显示上拉加载
@property (nonatomic, assign) BOOL isGroupedTableView;      //TableView是否分组
@property (nonatomic, assign) BOOL isCloseFirstRequest;     //是否关闭首次加载动作，默认开启

// !!!: required
- (void)queryDataSourceIsLoadMore:(BOOL)isLoadMore;                                 //请求数据方法，子类重写
- (void)parseResultWithJson:(id)json isLoadMore:(BOOL)isLoadMore;                   //解析数据方法，子类重写
// !!!: optional
- (void)dispatchAsyncForMainIsLoadMore:(BOOL)isLoadMore;                            //主线程更新UI之后的处理，子类重写
// !!!: callBack
- (void)successResultWithJson:(id)json isLoadMore:(BOOL)isLoadMore;                 //请求数据成功
- (void)failureResultIsLoadMore:(BOOL)isLoadMore;                                   //请求数据失败

/**
 在parseResultWithJson中数据处理完之后调用此方法

 @param dataSource 获取到的数据数组
 @param objectIdKey 每个字典或者model中的唯一标识字段，此字段用于数据实时变动时的上拉加载使用，用allObjectIds中的最后一个标识而不是用pageNumber传给后台，以便获取的数据分页的时候不会有重复显示（一般情况下用不上）
 @param isLoadMore 是否加载更多
 @param isShowNoDataView 当没有数据时是否显示无数据图
 */
- (void)dealWithDataSource:(NSArray *)dataSource objectIdKey:(NSString *)objectIdKey isLoadMore:(BOOL)isLoadMore isShowNoDataView:(BOOL)isShowNoDataView;

@end
