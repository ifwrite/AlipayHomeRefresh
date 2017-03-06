//
//  ViewController.m
//  AlipayHomeRefresh
//
//  Created by Emir on 2017/3/6.
//  Copyright © 2017年 Emir. All rights reserved.
//

#import "ViewController.h"
#import <MJRefresh.h>
#import "UIView+Size.h"

#define kTopViewHeight 300

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

//scrollView容器，子view为topView 和 tableView
@property (strong, nonatomic) UIScrollView *containerScrollView;

@property (strong, nonatomic) UIView *topView;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ViewController

#pragma mark -
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    [self.view addSubview:self.containerScrollView];
    [self.containerScrollView addSubview:self.topView];
    [self.containerScrollView addSubview:self.tableView];
}

#pragma mark -
#pragma mark - lazy load
- (UIScrollView *)containerScrollView {
    if (!_containerScrollView) {
        _containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _containerScrollView.delegate = self;
        
        //可根据实际布置height实际大小
        _containerScrollView.contentSize = CGSizeMake(0, self.view.height * 2);
        
        //设置scrollView滚动指示器到tableView
        _containerScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kTopViewHeight, 0, 0, 0);
    }
    return _containerScrollView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kTopViewHeight)];
        _topView.backgroundColor = [UIColor purpleColor];
    }
    return _topView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopViewHeight, self.view.width, self.view.height * 2 - kTopViewHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_tableView.mj_header endRefreshing];
            });
        }];
        [_tableView.mj_header beginRefreshing];
    }
    return _tableView;
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = self.containerScrollView.contentOffset.y;

    //scrollView在原位置下拉时候，设置tableViewcontentOffset
    if (offsetY <= 0) {
        self.topView.y = offsetY;
        
        self.tableView.y = offsetY + kTopViewHeight;
        if (![self.tableView.mj_header isRefreshing]) {
            [self.tableView setContentOffset:CGPointMake(0, offsetY)];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGFloat y = self.containerScrollView.contentOffset.y;
    
    //scrollView下拉到相应位置执行刷新
    if (y < - 55) {
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"indexPath: %ld", indexPath.row];
    
    return cell;
}
@end
