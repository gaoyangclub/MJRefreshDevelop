//
//  ViewController.m
//  MJRefreshTest
//
//  Created by admin on 16/10/12.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "UICuteView.h"
#import "DiyCuteRefreshHeader.h"
#import "DiyRotateRefreshHeader.h"

@interface TestTableViewCell : MJTableViewCell

@end
@implementation TestTableViewCell

-(void)showSubviews{
//    self.backgroundColor = [UIColor magentaColor];
    
    self.textLabel.text = (NSString*)self.data;
}

@end

@interface ViewController ()//<UITableViewDataSource,UITableViewDelegate>

//@property(nonatomic,retain) UITableView* tableView;
//@property(nonatomic,retain) NSMutableArray* dataSource;

@end


@implementation ViewController

//-(NSMutableArray *)dataSource{
//    if (!_dataSource) {
//        _dataSource = [NSMutableArray array];
//    }
//    return _dataSource;
//}

//-(BOOL)getShowFooter{
//    return NO;
//}

-(MJRefreshHeader *)getHeader{
    return [[DiyCuteRefreshHeader alloc]init];
//    return [[DiyRotateRefreshHeader alloc]init];
}

- (void)viewDidLoad {
    self.title = @"标题栏";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    self.tableView.cellGap = 5;
    
//    [self initTableView];
    
    [self initCuteView];
}

-(void)initCuteView{
//    UICuteView* cuteView = [[UICuteView alloc]init];
//    [self.view addSubview:cuteView];
//    cuteView.frame = CGRectMake(100, 100, 30, 30);
//    CGPoint center = cuteView.center;
//    center.x = self.view.center.x;
//    cuteView.center = center;
//    cuteView.startPoint = CGPointMake(0, 0);
//    cuteView.endPoint = CGPointMake(30, 300);
//    cuteView.viscosity = 50;
//    
//    cuteView.fillColor = [UIColor grayColor];
}

-(void)headerRefresh:(HeaderRefreshHandler)handler{
    int64_t delay = 1.0 * NSEC_PER_SEC;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{//
        [self.tableView clearSource];
        
        NSMutableArray<CellVo*>* sourceData = [NSMutableArray<CellVo*> array];
        int count = (arc4random() % 18) + 30; //生成3-10范围的随机数
        for (NSUInteger i = 0; i < count; i++) {
            //            [self.sourceData addObject:[NSString stringWithFormat:@"数据: %lu",i]];
            
            [sourceData addObject:
             [CellVo initWithParams:50 cellClass:[TestTableViewCell class] cellData:[NSString stringWithFormat:@"数据: %lu",i]]];
        }
        [self.tableView addSource:[SourceVo initWithParams:sourceData headerHeight:0 headerClass:NULL headerData:NULL]];
        
        handler(sourceData.count > 0);
    });
}

-(void)footerLoadMore:(FooterLoadMoreHandler)handler{
    int64_t delay = 1.0 * NSEC_PER_SEC;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{//
        int count = (arc4random() % 3); //生成0-2范围的随机数
        if (count <= 0) {
            handler(NO);
            return;
        }
        SourceVo* svo = self.tableView.getLastSource;
        NSMutableArray<CellVo*>* sourceData = svo.data;
        NSUInteger startIndex = [svo getRealDataCount];
        for (NSUInteger i = 0; i < count; i++) {
            [sourceData addObject:
             [CellVo initWithParams:50 cellClass:[TestTableViewCell class] cellData:[NSString stringWithFormat:@"数据: %lu",startIndex + i]]];
        }
        handler(YES);
    });
}

//-(void)initTableView{
//    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame];//全屏
//    [self.view addSubview:self.tableView];
//    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    
//    // 下拉刷新
//    int64_t delay = 2.0 * NSEC_PER_SEC;
//    
//    MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
//            [self refreshDataSource];
//            [self.tableView reloadData];
//            // 结束刷新
//            [self.tableView.mj_header endRefreshing];
//            [self.tableView.mj_footer resetNoMoreData];
//        });
//    }];
//    
//    header.lastUpdatedTimeLabel.hidden = YES;//隐藏时间
//    self.tableView.mj_header = header;
//    // 设置自动切换透明度(在导航栏下面自动隐藏)
//    self.tableView.mj_header.automaticallyChangeAlpha = YES;
//    
//    MJRefreshAutoNormalFooter* footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
//            if ([self loadDataSource]) {
//                [self.tableView reloadData];
//                [self.tableView.mj_footer endRefreshing];
//            }else{
//                [self.tableView.mj_footer endRefreshingWithNoMoreData];
//            }
//        });
//    }];
//    footer.stateLabel.userInteractionEnabled = NO;//
//    
//    [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
////    [footer setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
////    [footer setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
//    
//    // 上拉刷新
//    self.tableView.mj_footer = footer;
//    
//    [header beginRefreshing];
//}
//
//-(void)refreshDataSource{
//    [self.dataSource removeAllObjects];//先全部移除
//    
//    int count = (arc4random() % 8) + 3; //生成3-10范围的随机数
//    
//    for (NSUInteger i = 0; i < count; i++) {
//        [self.dataSource addObject:[NSString stringWithFormat:@"数据: %lu",i]];
//    }
//}
//
//-(BOOL)loadDataSource{
//    int count = (arc4random() % 3); //生成0-2范围的随机数
//    if (count <= 0) {
//        return NO;
//    }
//    NSUInteger startIndex = self.dataSource.count;
//    for (NSUInteger i = 0; i < count; i++) {
//        [self.dataSource addObject:[NSString stringWithFormat:@"数据: %lu",startIndex + i]];
//    }
//    return YES;
//}
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.dataSource.count;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [[UITableViewCell alloc] init];
//    cell.textLabel.text = self.dataSource[indexPath.row];
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50;
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end


