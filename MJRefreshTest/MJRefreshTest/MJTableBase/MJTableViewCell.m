//
//  MJTableViewCell.m
//  MJRefreshTest
//
//  Created by admin on 16/10/14.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MJTableViewCell.h"

@implementation MJTableViewCell

//- (void)awakeFromNib {
//    // Initialization code
//}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.needRefresh = YES;
    }
    return self;
}

-(void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    [self setNeedsLayout];
}

-(void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    [self setNeedsLayout];
}

-(void)setCellVo:(CellVo *)cellVo{
    _cellVo = cellVo;
    [self setNeedsLayout];
}

-(void)setData:(NSObject *)data{
    _data = data;
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.needRefresh) {
        [self showSubviews];
    }
}

-(void)showSubviews {
	
}

@end
