//
//  MJTableBaseView.h
//  MJRefreshTest
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "MJTableViewCell.h"
#import "MJTableViewSection.h"

#import "MJRefreshComponent+GY.h"


@class CellVo;
@class SourceVo;

typedef void(^HeaderRefreshHandler)(BOOL hasData);
typedef void(^FooterLoadMoreHandler)(BOOL hasData);

@protocol MJTableBaseViewDelegate<NSObject>

@optional
-(void)headerRefresh:(HeaderRefreshHandler)handler;
@optional
-(void)footerLoadMore:(FooterLoadMoreHandler)handler;
@optional
-(void)didSelectRow:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
-(void)didScrollToRow:(NSIndexPath *)indexPath;
@optional
-(void)didEndScrollingAnimation;

@optional
-(void)didRefreshComplete;
@optional
-(void)didLoadMoreComplete;

@end


@interface MJTableBaseView : UITableView

-(instancetype)init __attribute__((unavailable("Disabled. Use -initWithFrameAndParams instead")));
+(instancetype)new __attribute__((unavailable("Disabled. Use -initWithFrameAndParams instead")));
-(instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Disabled. Use -initWithFrameAndParams instead")));
-(instancetype)initWithCoder:(NSCoder *)aDecoder __attribute__((unavailable("Disabled. Use -initWithFrameAndParams instead")));
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style __attribute__((unavailable("Disabled. Use -initWithFrameAndParams instead")));

-(instancetype)initWithFrameAndParams:(CGRect)frame showHeader:(BOOL)showHeader showFooter:(BOOL)showFooter useCellIdentifer:(BOOL)useCellIdentifer topEdgeDiverge:(BOOL)topEdgeDiverge;
-(instancetype)initWithFrameAndParams:(CGRect)frame style:(UITableViewStyle)style showHeader:(BOOL)showHeader showFooter:(BOOL)showFooter useCellIdentifer:(BOOL)useCellIdentifer topEdgeDiverge:(BOOL)topEdgeDiverge;

@property(nonatomic,retain,readonly)NSMutableArray<SourceVo*>* dataSourceArray;

@property (nonatomic, weak) id<MJTableBaseViewDelegate> refreshDelegate;
@property (nonatomic,assign) BOOL refreshAll;

@property(nonatomic,retain) MJRefreshHeader* header;

@property(nonatomic,retain) NSIndexPath* selectedIndexPath;

//@property (nonatomic,assign) BOOL pureTable;

/**
 *  点中cell高亮
 */
@property (nonatomic,assign) BOOL clickCellHighlight;
/**
 *  点中cell自动居中
 */
@property (nonatomic,assign) BOOL clickCellMoveToCenter;
/**
 *  每一节间隔
 */
@property (nonatomic,assign) CGFloat sectionGap;
/**
 *  每个条目间隔
 */
@property (nonatomic,assign) CGFloat cellGap;
/**
 *  首次下拉
 */
@property (nonatomic,assign,readonly) BOOL hasFirstRefreshed;
/**
 *  代码下拉刷新
 */
-(void)headerBeginRefresh;
/**
 *  检查数据间隔
 */
-(void)checkGaps;
/**
 *  清除所有数据
 */
-(void)clearSource;
/**
 *  添加一节内容
 *  @param sourceVo
 */
-(void)addSource:(SourceVo*)sourceVo;
/**
 *  在某个索引插入一节内容
 *  @param sourceVo
 */
-(void)insertSource:(SourceVo*)sourceVo atIndex:(NSInteger)index;
/**
 *  删除一节内容
 *  @param sourceVo
 */
-(void)removeSourceAt:(NSInteger)index;
/**
 *  重新刷新全部界面 类似源生的reloadData
 */
-(void)reloadMJData;
/**
 *  将选中的数据项平滑居中移动
 */
-(void)moveSelectedIndexPathToCenter;

-(SourceVo*)getLastSource;
-(SourceVo*)getFirstSource;

-(SourceVo*)getSourceByIndex:(NSInteger)index;
-(CellVo*)getCellVoByIndexPath:(NSIndexPath*)indexPath;
-(NSUInteger)getSourceCount;
-(NSUInteger)getTotalCellCount;

@end

@interface SourceVo : NSObject

+ (instancetype)initWithParams:(NSMutableArray*)data headerHeight:(CGFloat)headerHeight headerClass:(Class)headerClass headerData:(NSObject*)headerData;
+ (instancetype)initWithParams:(NSMutableArray*)data headerHeight:(CGFloat)headerHeight headerClass:(Class)headerClass headerData:(NSObject*)headerData isUnique:(BOOL)isUnique;

@property (nonatomic,retain)NSMutableArray<CellVo*>* data;//数据源
@property (nonatomic,assign)CGFloat headerHeight;
@property (nonatomic,retain)Class headerClass;
@property (nonatomic,retain)id headerData;//section标题数据
@property (nonatomic,assign)BOOL isUnique;

-(NSInteger)getRealDataCount;

@end

@interface CellVo : NSObject

+ (instancetype)initWithParams:(CGFloat)cellHeight cellClass:(Class)cellClass cellData:(id)cellData;
+ (instancetype)initWithParams:(CGFloat)cellHeight cellClass:(Class)cellClass cellData:(id)cellData cellTag:(NSInteger)cellTag isUnique:(BOOL)isUnique;

#define CELL_TAG_NORMAL 0 //中间的
#define CELL_TAG_FIRST 1 //第一个
#define CELL_TAG_LAST 2 //小组最后一个
#define CELL_TAG_SECTION_GAP 10 //section的gap
#define CELL_TAG_CELL_GAP 11 //cell的gap

@property (nonatomic,assign)CGFloat cellHeight;
@property (nonatomic,retain)Class cellClass;
@property (nonatomic,retain)id cellData;
@property (nonatomic,assign)NSInteger cellTag;
@property (nonatomic,assign)BOOL isUnique;
@property (nonatomic,assign)BOOL isSelect;

-(BOOL)isRealCell;

@end
