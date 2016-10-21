//
//  MJTableViewCell.h
//  MJRefreshTest
//
//  Created by admin on 16/10/14.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJTableBaseView.h"
@class CellVo;

@interface MJTableViewCell : UITableViewCell

@property(nonatomic,assign) BOOL isFirst;
@property(nonatomic,assign) BOOL isLast;
@property(nonatomic,assign) BOOL needRefresh;
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) NSIndexPath *indexPath;
@property(nonatomic,retain) CellVo *cellVo;
@property(nonatomic,retain) NSObject *data;

-(void)showSubviews;

@end
