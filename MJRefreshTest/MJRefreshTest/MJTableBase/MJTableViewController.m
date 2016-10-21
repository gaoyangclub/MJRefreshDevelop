
//
//  MJTableViewController.m
//  MJRefreshTest
//
//  Created by admin on 16/10/17.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MJTableViewController.h"

@interface MJTableViewController ()//<UITableViewDataSource,UITableViewDelegate>

@end

@implementation MJTableViewController

-(void)loadView{
    [super loadView];
    self.autoRefreshHeader = YES;
    self.contentOffsetRest = YES;
    
//    self.automaticallyAdjustsScrollViewInsets = NO;//YES表示自动测量导航栏高度占用的Insets偏移
//    self.navigationController.navigationBar.translucent = NO;//    Bar的高斯模糊效果，默认为YES
//    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initTableView];
}

-(void)initTableView{
    if (!self.tableView) {
        self.tableView = [[MJTableBaseView alloc]initWithFrameAndParams:self.view.frame showHeader:[self getShowHeader] showFooter:[self getShowFooter] useCellIdentifer:[self getUseCellIdentifer] topEdgeDiverge:self.navigationController != NULL &&
                          !self.navigationController.navigationBar.translucent];
        
        [self.view addSubview:self.tableView];
        self.tableView.refreshDelegate = self;
        MJRefreshHeader* header = [self getHeader];
        if (header) {
            self.tableView.header = header;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.contentOffsetRest){
        CGPoint contentOffset = self.tableView.contentOffset;
        contentOffset.y = 0;//滚轮位置恢复
        self.tableView.contentOffset = contentOffset;
    }
}

//-(void)headerRefresh:(HeaderRefreshHandler)handler{
//    
//}
//
//-(BOOL)footerLoadMore:(FooterLoadMoreHandler)handler{
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.frame = [self getTableViewFrame];
    if (self.autoRefreshHeader) {
        [self.tableView headerBeginRefresh];
    }
}

-(CGRect)getTableViewFrame {
    return self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)getShowHeader {
    return YES;
}

-(BOOL)getShowFooter {
    return YES;
}

-(BOOL)getUseCellIdentifer {
    return YES;
}

-(MJRefreshHeader*)getHeader {
    return NULL;
}

@end
