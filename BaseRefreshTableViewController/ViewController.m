//
//  ViewController.m
//  BaseRefreshTableViewController
//
//  Created by SNICE on 2018/8/7.
//  Copyright © 2018年 G. All rights reserved.
//

#import "ViewController.h"
#import "PSGURLSessionManage.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    //下面这四个属性如需设置，都是放在[super viewDidLoad]之前设置，不然不生效
    self.isGroupedTableView = YES;
    self.isShowPullupToLoad = YES;
    self.isShowPulldownToRefresh = YES;
//    self.isCloseFirstRequest = YES;
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    self.tableView.estimatedRowHeight = 100.0f;
}

#pragma mark - tableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dic = self.dataSource[indexPath.row];
    cell.textLabel.text = dic[@"updatetime"];
    cell.detailTextLabel.text = dic[@"content"];
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

#pragma mark - tableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - requestData

//调用父类的方法，这个方法会在加载页面的时候默认被调用一次，如果需要首次不加载，需在[super viewDidLoad]之前设置self.isCloseFirstRequest = YES;
//在这个方法里面进行数据请求，如果是其他的数据请求，建议写个另外的方法，这个是对tableView数据源的数据请求，下拉刷新和上拉加载都会调用此方法
- (void)queryDataSourceIsLoadMore:(BOOL)isLoadMore {
    [super queryDataSourceIsLoadMore:isLoadMore];
//    NSString *urlString = @"http://120.79.136.48:8080/youhuo/demand/getDemandAtAppIndex";
//    NSDictionary *params = @{
//                             @"pageNum": @(1)
//                             };
//    [[PSGURLSessionManage sharedManage] postDataWithPath:urlString params:params header:nil isJsonSerializer:YES success:^(NSInteger code, NSString *msg, id json) {
//
//    } failure:^(NSError *error) {
//
//    }];
    
    NSString *urlString = @"http://v.juhe.cn/joke/content/list.php";
    NSDictionary *params = @{
                             @"sort": @"asc",
                             @"page": @(self.pageNumber),
                             @"pagesize": @(self.pageSize),
                             @"time" : @"1528439894",
                             @"key" : @"cdda9baaceabac9730ebe69db62228d7",
                             };
    [[PSGURLSessionManage sharedManage] getDataWithPath:urlString params:params header:nil success:^(NSInteger code, NSString *msg, id json) {
        NSLog(@"%@", json);
        //数据处理成功需要调用此方法，解析数据的处理操作放到parseResultWithJson中去解析
        [self successResultWithJson:json isLoadMore:isLoadMore];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        //数据请求失败需要调用此方法
        [self failureResultIsLoadMore:isLoadMore];
    }];
}

//这是父类中需要子类重写的方法，调用了queryDataSourceIsLoadMore之后拿到数据调用了[self successResultWithJson:json isLoadMore:isLoadMore]之后就会进入parseResultWithJson方法中，在这里对拿到的数据进行处理，这个方法完成之后会自动调用[self.tableView reloadData]，不需要手动再次调用
- (void)parseResultWithJson:(id)json isLoadMore:(BOOL)isLoadMore {
    if (!isLoadMore) {
        self.dataSource = [NSMutableArray array];
    }
    NSArray *datas = json[@"result"][@"data"];
    [self.dataSource addObjectsFromArray:datas];
    
    //处理完数据，调用此方法来处理是否显示上拉加载和无数据图片
    [self dealWithDataSource:datas objectIdKey:nil isLoadMore:isLoadMore isShowNoDataView:YES];
}

@end
