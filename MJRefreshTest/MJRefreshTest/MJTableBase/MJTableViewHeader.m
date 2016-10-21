
//
//  MJTableViewHeader.m
//  MJRefreshTest
//
//  Created by admin on 16/10/17.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "MJTableViewHeader.h"

@interface MJTableViewHeader(){
    
}
//@property(nonatomic,assign)BOOL *selected;

@end

@implementation MJTableViewHeader

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self setNeedsLayout];
}

-(void)setItemIndex:(NSInteger)itemIndex{
    _itemIndex = itemIndex;
    [self setNeedsLayout];
}

-(void)setData:(NSObject *)data{
    _data = data;
    [self setNeedsLayout];
}


@end
