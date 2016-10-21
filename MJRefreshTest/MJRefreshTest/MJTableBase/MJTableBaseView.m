//
//  MJTableBaseView.m
//  MJRefreshTest
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MJTableBaseView.h"
#import "DiyCuteRefreshHeader.h"

@interface MJTableBaseView()<UITableViewDelegate,UITableViewDataSource>{//
    
}
@property(nonatomic,retain)NSMutableArray<SourceVo*>* dataArray;

@property (nonatomic,assign) BOOL useCellIdentifer;
@property (nonatomic,assign) BOOL showHeader;
@property (nonatomic,assign) BOOL showFooter;
/**
 *  是否设置顶部偏离 满足ViewController在自动测量导航栏高度占用的Insets偏移的补位
 */
@property (nonatomic,assign) BOOL topEdgeDiverge;

@end

@implementation MJTableBaseView

-(instancetype)initWithFrameAndParams:(CGRect)frame showHeader:(BOOL)showHeader showFooter:(BOOL)showFooter useCellIdentifer:(BOOL)useCellIdentifer topEdgeDiverge:(BOOL)topEdgeDiverge{
    self = [super initWithFrame:frame];
    if (self) {
        self.useCellIdentifer = useCellIdentifer;
        self.showHeader = showHeader;
        self.showFooter = showFooter;
        self.topEdgeDiverge = topEdgeDiverge;
        [self prepare];
    }
    return self;
}

-(instancetype)initWithFrameAndParams:(CGRect)frame style:(UITableViewStyle)style showHeader:(BOOL)showHeader showFooter:(BOOL)showFooter useCellIdentifer:(BOOL)useCellIdentifer topEdgeDiverge:(BOOL)topEdgeDiverge{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.useCellIdentifer = useCellIdentifer;
        self.showHeader = showHeader;
        self.showFooter = showFooter;
        self.topEdgeDiverge = topEdgeDiverge;
        [self prepare];
    }
    return self;
}

//alloc会调用allocWithZone:
+(id)allocWithZone:(NSZone *)zone
{
    MJTableBaseView* instance;
    @synchronized (self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            instance.refreshAll = YES;
//            instance.useCellIdentifer = YES;
//            instance.showHeader = YES;
//            instance.showFooter = YES;
            return instance;
        }
    }
    return nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

-(NSMutableArray<SourceVo*> *)dataArray{
    if(!_dataArray){
        _dataArray = [[NSMutableArray<SourceVo*> alloc]init];
    }
    return _dataArray;
}

/** 重新刷新界面 */
-(void)headerBeginRefresh {
    if (!self.mj_header.isRefreshing) {
        [self clearSource];
        [self reloadData];
        [self.mj_header beginRefreshing];
    }
}

-(void)clearSource {
    [self.dataArray removeAllObjects];
}

-(void)addSource:(SourceVo*)sourceVo {
    [self.dataArray addObject:sourceVo];
}

//-(void)setTopEdgeDiverge:(BOOL)topEdgeDiverge{
////    if (topEdgeDiverge) {
//////        self.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
////        self.mj_insetB = 64;
////    }else{
//////        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
////    }
//}

-(void)prepare{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.delegate = self;
        self.dataSource = self;
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉Cell自带线条
        self.backgroundColor = [UIColor clearColor];
        
//        if(self.pureTable){ //纯净无刷新功能列表
//            self.showHeader = NO;
//            self.showFooter = NO;
//            [self reloadData];
//        }
        if (self.topEdgeDiverge) {
            self.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
        }
        
        if (self.showHeader) {
            MJRefreshNormalHeader* header = [[MJRefreshNormalHeader alloc]init]; //[MJRefreshNormalHeader headerWithRefreshingBlock:
            header.lastUpdatedTimeLabel.hidden = YES;//隐藏时间
            header.automaticallyChangeAlpha = YES;
//            header.ignoredScrollViewContentInsetTop = 50;
//            self.mj_header = header;
            // 设置自动切换透明度(在导航栏下面自动隐藏)
            self.header = header;
        }
        
        if (self.showFooter) {
            __weak __typeof(self) weakSelf = self;
            MJRefreshAutoNormalFooter* footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.refreshDelegate && [strongSelf.refreshDelegate respondsToSelector:@selector(footerLoadMore:)]){
                    [strongSelf.refreshDelegate footerLoadMore:^(BOOL hasData){
                        if (hasData) {
                            [strongSelf checkGaps];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf reloadData];
                            });
                            [strongSelf.mj_footer endRefreshing];
                        }else{
                            [strongSelf.mj_footer endRefreshingWithNoMoreData];
                        }
                    }];
                }
            }];
            footer.stateLabel.userInteractionEnabled = NO;//无法点击交互
            [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
            
//            footer.ignoredScrollViewContentInsetBottom = 64;
//            UIEdgeInsets insets = footer.scrollViewOriginalInset;
//            insets.bottom = insets.top = 0;
//            footer.scrollViewOriginalInset = insets;
            self.mj_footer = footer;// 上拉刷新
        }
        
    });

}

-(void)setHeader:(MJRefreshHeader *)header{
    if (self.showHeader) {
        __weak __typeof(self) weakSelf = self;
        header.refreshingBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //            DiyCuteRefreshHeader* header = [DiyCuteRefreshHeader headerWithRefreshingBlock:^{
            if (strongSelf.refreshDelegate && [strongSelf.refreshDelegate respondsToSelector:@selector(headerRefresh:)]) {
                [strongSelf.refreshDelegate headerRefresh:^(BOOL hasData){
                    _hasFirstRefreshed = YES;
                    
                    [strongSelf checkGaps];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf reloadData];
                    });
                    [strongSelf.mj_header endRefreshing];// 结束刷新
                    if (hasData) {
                        if (strongSelf.mj_footer) {
                            [strongSelf.mj_footer resetNoMoreData];
                        }
                    }else{
                        if (strongSelf.mj_footer) {
                            [strongSelf.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                }];
            }
        };
        self.mj_header = header;
    }
}

-(MJRefreshHeader *)header{
    return self.mj_header;
}

//-(void)layoutSubviews{
//
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    SourceVo* source = self.dataArray[section];
    return source.headerHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SourceVo* source = self.dataArray[section];
    return source.data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if(section >= self.dataArray.count){
        NSLog(@"产生无效UITableViewCell 可能是一个刷新列表正在进行中 另一个刷新就来了引起的");
        return [[UITableViewCell alloc] init];
    }
    SourceVo*  source = self.dataArray[section];
    CellVo* cellVo = source.data[row];//获取的数据给cell显示
    Class cellClass = cellVo.cellClass;
//    if(autoCellClass != nil){
//        cellClass = autoCellClass!
//    }
    
    MJTableViewCell* cell;
    BOOL isCreate = NO;
    if(self.useCellIdentifer) {
        NSString* cellIdentifer;
        NSString* classString = NSStringFromClass(cellClass);
        if(cellVo.isUnique){//唯一
            cellIdentifer = [classString stringByAppendingString:[NSString stringWithFormat:@"_%lu_%lu",section,row]];
        }else{
            cellIdentifer = classString;
        }
        //        println("className:" + className)
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        if(cell == NULL){
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
            isCreate = YES;
        }
    }else{
        cell = [[cellClass alloc] init];
        isCreate = YES;
    }
    
    if(isCreate){ //创建阶段设置
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;//UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];//无色
    }
    if(!self.refreshAll && !isCreate){//上啦刷新且非创建阶段
        cell.needRefresh = NO; //不需要刷新
        return cell; //直接返回无需设置
    }else{
        cell.needRefresh = YES; //需要刷新
    }
    NSObject* data = cellVo.cellData;
    cell.isFirst = cellVo.cellTag == CELL_TAG_FIRST;
    if(source.data != NULL){
        cell.isLast = cellVo.cellTag == CELL_TAG_LAST;//row == source.data!.count - 1//索引在最后
    }
    cell.indexPath = indexPath;
    cell.tableView = tableView;
    cell.data = data;
    cell.cellVo = cellVo;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SourceVo* source = self.dataArray[indexPath.section];
    CellVo* cellVo = source.data[indexPath.row];
    return cellVo.cellHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SourceVo* source = self.dataArray[section];
    Class headerClass = source.headerClass;
    MJTableViewHeader* headerView;
    if (headerClass != NULL) {
        headerView = [[headerClass alloc]init];
        headerView.itemIndex = section;
        headerView.data = source.headerData;
    }
//    var headerView = nsSectionDic[section]
//    if headerView == nil{
//        if(headerClass != nil){
//            headerView = headerClass!.init()
//            nsSectionDic.updateValue(headerView!, forKey: section)
//        }
//    }
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell) {
//        tableView
//    }
    [tableView deselectRowAtIndexPath:indexPath animated: false];//反选
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(didSelectRow:didSelectRowAtIndexPath:)]) {
        [self.refreshDelegate didSelectRow:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(void)checkGaps {
    //遍历整个数据链 判断头尾标记和gap是否存在
    for (NSInteger i = 0; i < self.dataArray.count; i ++) {
        SourceVo* svo = self.dataArray[i];
        if (svo.data != nil && svo.data.count > 0) {
            BOOL hasFirst = NO;
            BOOL hasLast = NO;
            for (NSInteger j = svo.data.count - 1; j >= 0; j --) {
                CellVo* cvo = svo.data[j];
                if (cvo.cellTag == CELL_TAG_FIRST) {
                    hasFirst = YES;
                }else if(cvo.cellTag == CELL_TAG_LAST){
                    hasLast = YES;
                }else if(cvo.cellTag == CELL_TAG_SECTION_GAP){
                    //                        if sectionGap <= 0{//已经不需要
                    [svo.data removeObjectAtIndex:j]; //先全部清除
                    //                            continue
                    //                        }
                }else if(cvo.cellTag == CELL_TAG_CELL_GAP){
                    //                        if cellGap <= 0{//已经不需要
                    [svo.data removeObjectAtIndex:j];//先全部清除
                    //                            continue
                    //                        }
                }
            }
            if(!hasFirst){//不存在
                ((CellVo*)svo.data[0]).cellTag = CELL_TAG_FIRST;//标记第一个就是
            }
            if(!hasLast){
                ((CellVo*)svo.data[svo.data.count - 1]).cellTag = CELL_TAG_LAST;//标记最后一个就是
            }
        }
    }
    
    if(self.sectionGap > 0 || self.cellGap > 0){
        for (NSInteger i = 0; i < self.dataArray.count; i ++) {
            SourceVo* svo = self.dataArray[i];
            //            var preCellVo:CellVo? = nil
            if(svo.data != nil && svo.data.count > 0){
                for (NSInteger j = svo.data.count - 1; j >= 0; j --) {
                    if(self.sectionGap > 0 && j == svo.data.count - 1 && i != self.dataArray.count - 1){//非最后一节 且最后一个实体存到最后
                        [svo.data addObject:[self getSectionGapCellVo]];
                    }else if(self.cellGap > 0 && j != svo.data.count - 1){//不是最后一个直接插入
                        [svo.data insertObject:[self getCellGapCellVo] atIndex:j + 1];
                    }
                }
            }
        }
    }
}

-(CellVo*)getSectionGapCellVo{
    return [CellVo initWithParams:self.sectionGap cellClass:[MJTableViewCell class] cellData:nil cellTag:CELL_TAG_SECTION_GAP isUnique:false];
}

-(CellVo*)getCellGapCellVo{
    return [CellVo initWithParams:self.cellGap cellClass:[MJTableViewCell class] cellData:nil cellTag:CELL_TAG_CELL_GAP isUnique:false];
}

-(SourceVo*)getLastSource {
    if (self.dataArray.count > 0) {
        return self.dataArray[self.dataArray.count - 1];
    }
    return NULL;
}

-(SourceVo*)getFirstSource {
    if (self.dataArray.count > 0) {
        return self.dataArray[0];
    }
    return NULL;
}

@end

@implementation SourceVo

+ (instancetype)initWithParams:(NSMutableArray*)data headerHeight:(CGFloat)headerHeight headerClass:(Class)headerClass headerData:(NSObject*)headerData{
    return [SourceVo initWithParams:data headerHeight:headerHeight headerClass:headerClass headerData:headerData isUnique:false];
}

+ (instancetype)initWithParams:(NSMutableArray*)data headerHeight:(CGFloat)headerHeight headerClass:(Class)headerClass headerData:(NSObject*)headerData isUnique:(BOOL)isUnique{
    SourceVo *instance;
    @synchronized (self)    {
        if (instance == nil)
        {
            instance = [[self alloc] init];
            instance.data = data;
            instance.headerHeight = headerHeight;
            instance.headerClass = headerClass;
            instance.headerData = headerData;
            instance.isUnique = isUnique;
        }
    }
    return instance;
}

-(NSInteger)getRealDataCount {
    if (!self.data || self.data.count == 0) {
        return 0;
    }
    NSInteger count = 0;
    for (CellVo* cvo in self.data) {
        if ([cvo isRealCell]) {
            count++;
        }
    }
    return count;
}

@end


@implementation CellVo

+ (instancetype)initWithParams:(CGFloat)cellHeight cellClass:(Class)cellClass cellData:(NSObject*)cellData{
    return [CellVo initWithParams:cellHeight cellClass:cellClass cellData:cellData cellTag:CELL_TAG_NORMAL isUnique:false];
}

+ (instancetype)initWithParams:(CGFloat)cellHeight cellClass:(Class)cellClass cellData:(NSObject*)cellData cellTag:(NSInteger)cellTag isUnique:(BOOL)isUnique
{
    CellVo *instance;
    @synchronized (self)    {
        if (instance == nil)
        {
            instance = [[self alloc] init];
            instance.cellHeight = cellHeight;
            instance.cellClass = cellClass;
            instance.cellData = cellData;
            instance.cellTag = cellTag;
            instance.isUnique = isUnique;
        }
    }
    return instance;
}

-(BOOL)isRealCell{
    return self.cellTag == CELL_TAG_NORMAL || self.cellTag == CELL_TAG_FIRST || self.cellTag == CELL_TAG_LAST;
}

@end
