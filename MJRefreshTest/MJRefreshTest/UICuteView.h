//
//  UICuteView.h
//  MJRefreshTest
//
//  Created by admin on 16/10/19.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICuteView : UIView

@property(nonatomic,assign) CGPoint startPoint;
@property(nonatomic,assign) CGPoint endPoint;
@property(nonatomic,retain) UIColor* fillColor;
@property(nonatomic,retain) UIColor* strokeColor;
@property(nonatomic,assign) CGFloat lineWidth;
//气泡粘性系数，越大可以拉得越长
// viscosity of the bubble,the bigger you set,the longer you drag
@property(nonatomic, assign) CGFloat viscosity;

@property(nonatomic,retain,readonly)UILabel* titleLabel;
@property(nonatomic, assign) CGFloat titlePadding;

@end
