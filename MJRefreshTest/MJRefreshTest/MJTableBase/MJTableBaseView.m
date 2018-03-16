//
//  MJTableBaseView.m
//  MJRefreshTest
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MJTableBaseView.h"
#import "MJRefreshAutoFooterGY.h"

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

-(instancetype)initWithFrameAndParams:(CGRect)frame showHeader:(BOOL)showHeader showFooter:(BOOL)showFooter useCellIdentifer:(BOOL)useCellIdentifer topEdgeDiverge:(BOOL)topEdgeDiverge{//
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

-(instancetype)initWithFrameAndParams:(CGRect)frame style:(UITableViewStyle)style showHeader:(BOOL)showHeader showFooter:(BOOL)showFooter useCellIdentifer:(BOOL)useCellIdentifer topEdgeDiverge:(BOOL)topEdgeDiverge{//
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

-(NSMutableArray<SourceVo *> *)dataSourceArray{
    return self.dataArray;
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
    _selectedIndexPath = nil;
    [self.dataArray removeAllObjects];
}

-(void)addSource:(SourceVo*)sourceVo {
    [self.dataArray addObject:sourceVo];
}

-(void)insertSource:(SourceVo *)sourceVo atIndex:(NSInteger)index{
    [self.dataArray insertObject:sourceVo atIndex:index];
}

-(void)removeSourceAt:(NSInteger)index{
    [self.dataArray removeObjectAtIndex:index];
}

-(SourceVo*)getSourceByIndex:(NSInteger)index{
    if (index < self.dataArray.count) {
        return self.dataArray[index];
    }
    return nil;
}

-(CellVo *)getCellVoByIndexPath:(NSIndexPath *)indexPath{
    SourceVo* source = [self getSourceByIndex:indexPath.section];
    if (source && source.data && indexPath.row < source.data.count) {
        return source.data[indexPath.row];
    }
    return nil;
}

-(NSUInteger)getSourceCount{
    return self.dataArray.count;
}

-(NSUInteger)getTotalCellCount{
    NSInteger cellCount = 0;
    for (SourceVo* svo in self.dataArray) {
        for (CellVo* cvo in svo.data) {
            cellCount ++;
        }
    }
    return cellCount;
}

-(void)setRefreshDelegate:(id<MJTableBaseViewDelegate>)refreshDelegate{
    _refreshDelegate = refreshDelegate;
    
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
//    dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
    
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;//默认自动回弹键盘
    
        self.delegate = self;
        self.dataSource = self;
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone; //去掉Cell自带线条
        self.backgroundColor = [UIColor clearColor];
        
        
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
            MJRefreshAutoNormalFooter* footer = [MJRefreshAutoFooterGY footerWithRefreshingBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.refreshDelegate && [strongSelf.refreshDelegate respondsToSelector:@selector(footerLoadMore:)]){
                    [strongSelf.refreshDelegate footerLoadMore:^(BOOL hasData){
//                        [strongSelf footerLoaded:hasData];
                        if (hasData) {
                            [strongSelf checkGaps];
                            strongSelf.refreshAll = NO;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf reloadData];
                                if (strongSelf.refreshDelegate && [strongSelf.refreshDelegate respondsToSelector:@selector(didLoadMoreComplete)]){
                                    [strongSelf.refreshDelegate didLoadMoreComplete];
                                }
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
        
//    });

}

//-(void)footerLoaded:(BOOL)hasData{
//    
//}

-(void)setHeader:(MJRefreshHeader *)header{
    if (self.showHeader) {
        __weak __typeof(self) weakSelf = self;
        header.refreshingBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //            DiyCuteRefreshHeader* header = [DiyCuteRefreshHeader headerWithRefreshingBlock:^{
            if (strongSelf.refreshDelegate && [strongSelf.refreshDelegate respondsToSelector:@selector(headerRefresh:)]) {
                [strongSelf.refreshDelegate headerRefresh:^(BOOL hasData){
//                    [strongSelf headerRefreshed:hasData];
                    strongSelf->_hasFirstRefreshed = YES;
                    [strongSelf reloadMJData];
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
        header.endRefreshingCompletionBlock = ^(){
            [self moveSelectedIndexPathToCenter];
        };
        self.mj_header = header;
    }
}

//-(void)headerRefreshed:(BOOL)hasData{
//    
//}

-(void)moveSelectedIndexPathToCenter{
    if(self.mj_header.isIdle){//不在刷新状态下可以使用
        if (self.clickCellMoveToCenter && self->_selectedIndexPath) {
            //                MJTableViewCell* cell = [self cellForRowAtIndexPath:_selectedIndexPath];
            //                DDLog(@"selectedIndexPath.row:%ld",(long)_selectedIndexPath.row);
            [self moveCellToCenter:self->_selectedIndexPath];
        }
    }
}

-(void)reloadMJData{
    self.refreshAll = YES;
    [self checkGaps];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(didRefreshComplete)]){
            [self.refreshDelegate didRefreshComplete];
        }
        if (self.selectedIndexPath) {
            [self dispatchSelectRow:self.selectedIndexPath];
        }
    });
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
    SourceVo* source = [self getSourceByIndex:section];
    return source ? source.headerHeight : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SourceVo* source = [self getSourceByIndex:section];
    return source && source.data ? source.data.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if(section >= self.dataArray.count){
        NSLog(@"产生无效UITableViewCell 可能是一个刷新列表正在进行中 另一个刷新就来了引起的");
        return [[UITableViewCell alloc] init];
    }
    SourceVo* source = [self getSourceByIndex:section];
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
        if([cell showSelectionStyle]){
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = [UIColor clearColor];//无色
    }
    if (isCreate || cell.cellVo != cellVo) {
        cell.needRefresh = YES; //需要刷新
    }else{
        cell.needRefresh = NO; //不需要刷新
    }
//    if(!self.refreshAll && !isCreate)){//上啦加载且非创建阶段
//        cell.needRefresh = NO; //不需要刷新
//        return cell; //直接返回无需设置
//    }else{
//        cell.needRefresh = YES; //需要刷新
//    }
    NSObject* data = cellVo.cellData;
    cell.isSingle = source.data.count <= 1;
    cell.isFirst = cellVo.cellTag == CELL_TAG_FIRST;
    if(source.data != NULL){
        cell.isLast = cellVo.cellTag == CELL_TAG_LAST;//row == source.data!.count - 1//索引在最后
    }
    cell.indexPath = indexPath;
    cell.tableView = tableView;
    cell.data = data;
    cell.cellVo = cellVo;
    
    cell.selected = [indexPath isEqual:self.selectedIndexPath];
    return cell;
}

//防止子类交互影响屏蔽父类
-(BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CellVo* cellVo = [self getCellVoByIndexPath:indexPath];
    if (cellVo) {
        return cellVo.cellHeight;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SourceVo* source = [self getSourceByIndex:section];
    Class headerClass = source.headerClass;
    MJTableViewSection* sectionView;
    if (headerClass != NULL) {
        sectionView = [[headerClass alloc]init];
        sectionView.itemCount = [self getSourceCount];
        sectionView.itemIndex = section;
        sectionView.isFirst = section == 0;
        sectionView.isLast = section == self.dataArray.count - 1;
        sectionView.data = source.headerData;
    }
//    var headerView = nsSectionDic[section]
//    if headerView == nil{
//        if(headerClass != nil){
//            headerView = headerClass!.init()
//            nsSectionDic.updateValue(headerView!, forKey: section)
//        }
//    }
    return sectionView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.clickCellMoveToCenter) {
        [self moveCellToCenter:indexPath];
    }
    //    if (cell) {
////        tableView
//        cell.needRefresh = NO; //不需要刷新
//    }
//    CellVo* cellVo = [self getCellVoByIndexPath:indexPath];
//    cellVo.isSelect = YES;
    if(self.clickCellHighlight){
        [self changeSelectIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated: false];//反选
    [self dispatchSelectRow:indexPath];
}

-(void)moveCellToCenter:(NSIndexPath *)indexPath{
    CGRect rectInTableView = [self rectForRowAtIndexPath:indexPath];
    CGRect btnToSelf = [self convertRect:rectInTableView toView:self.superview];
//    CGRect btnToSelf = [self convertRect:clickCell.frame toView:self.superview];
    CGFloat moveY = btnToSelf.origin.y - CGRectGetHeight(self.bounds) / 2. + btnToSelf.size.height / 2. - self.contentInset.top;
    CGPoint contentOffset = self.contentOffset;
    //    self.bottomAreaView.contentSize.width
    CGFloat maxOffsetY = self.contentSize.height - CGRectGetHeight(self.bounds) - self.contentInset.top;
    maxOffsetY = maxOffsetY > 0 ? maxOffsetY : 0;
    CGFloat moveOffsetY = contentOffset.y + moveY;
    if (moveOffsetY < 0) {
        moveOffsetY = 0;
    }else if(moveOffsetY > maxOffsetY){
        moveOffsetY = maxOffsetY;
    }
    [self setContentOffset:CGPointMake(contentOffset.x,moveOffsetY) animated:YES];
}

-(void)dispatchSelectRow:(NSIndexPath *)indexPath{
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(didSelectRow:didSelectRowAtIndexPath:)]) {
        [self.refreshDelegate didSelectRow:self didSelectRowAtIndexPath:indexPath];
    }
}

-(void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath{
    [self changeSelectIndexPath:selectedIndexPath];
}

-(void)changeSelectIndexPath:(NSIndexPath *)selectedIndexPath{
    if (self->_selectedIndexPath) {
        MJTableViewCell* prevCell = [self cellForRowAtIndexPath:self->_selectedIndexPath];
        if (prevCell) {
            prevCell.selected = NO;
        }
    }
    self->_selectedIndexPath = selectedIndexPath;
    MJTableViewCell* cell = [self cellForRowAtIndexPath:selectedIndexPath];
    if (cell) {
        cell.selected = YES;
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(didEndScrollingAnimation)]) {
        [self.refreshDelegate didEndScrollingAnimation];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(didScrollToRow:)]) {
        NSIndexPath *path =  [self indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
//        NSLog(@"这是第%li栏目",(long)path.section);
        [self.refreshDelegate didScrollToRow:path];
    }
}

-(void)checkGaps {
    //遍历整个数据链 判断头尾标记和gap是否存在
    for (NSInteger i = 0; i < self.dataArray.count; i ++) {
        SourceVo* svo = [self getSourceByIndex:i];
        if (svo && svo.data != nil && svo.data.count > 0) {
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
            SourceVo* svo = [self getSourceByIndex:i];
            //            var preCellVo:CellVo? = nil
            if(svo && svo.data != nil && svo.data.count > 0){
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
        return self.dataArray.lastObject;
    }
    return NULL;
}

-(SourceVo*)getFirstSource {
    if (self.dataArray.count > 0) {
        return self.dataArray.firstObject;
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
