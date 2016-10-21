//
//  MJTableViewController.h
//  MJRefreshTest
//
//  Created by admin on 16/10/17.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJTableBaseView.h"

@interface MJTableViewController : UIViewController<MJTableBaseViewDelegate>

@property(nonatomic,retain)MJTableBaseView* tableView;
@property(nonatomic,assign)BOOL contentOffsetRest;
@property(nonatomic,assign)BOOL autoRefreshHeader;

-(CGRect)getTableViewFrame;

-(BOOL)getShowHeader;
-(BOOL)getShowFooter;
-(BOOL)getUseCellIdentifer;
-(MJRefreshHeader*)getHeader;

@end
