//
//  DiyCuteRefreshHeader.m
//  MJRefreshTest
//
//  Created by admin on 16/10/20.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "DiyCuteRefreshHeader.h"
#import "UICuteView.h"

@interface DiyCuteRefreshHeader()

@property(nonatomic,retain) UICuteView* cuteView;
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation DiyCuteRefreshHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(UICuteView *)cuteView{
    if (!_cuteView) {
        _cuteView = [[UICuteView alloc]init];
        _cuteView.viscosity = 16;
        [self addSubview:_cuteView];
        _cuteView.fillColor = [UIColor grayColor];
//        [UIColor colorWithRed:51/255. green:144/255. blue:250/255. alpha:1];
        _cuteView.lineWidth = 2;
        _cuteView.strokeColor = [UIColor darkGrayColor];
        
        _cuteView.startPoint = CGPointMake(0, 0);
        _cuteView.endPoint = CGPointMake(0, 0);
//        _cuteView.backgroundColor = [UIColor blackColor];
        
        UIFont *iconfont = [UIFont fontWithName:@"iconfont" size: 20];
        _cuteView.titleLabel.font = iconfont;
        UILabel* titleLabel = _cuteView.titleLabel;
        titleLabel.text = @"\U0000e652";// \U0000e66d
        
        _cuteView.titlePadding = 5;
    }
    return _cuteView;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidesWhenStopped = YES;
//        loadingView.color = [UIColor blueColor];//改变UIActivityIndicatorView颜色
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

-(void)placeSubviews{
    [super placeSubviews];
    
    CGFloat radius = 30;
    self.cuteView.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2 - radius / 2, CGRectGetHeight(self.bounds) / 2 - radius / 2, radius, radius);
    
    self.automaticallyChangeAlpha = NO;
    
    CGFloat arrowCenterX = self.mj_w * 0.5;
    CGFloat arrowCenterY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }
}

//-(void)prepare{
//    [super prepare];
//    
//    
//}

-(void)scrollViewContentOffsetDidChange:(NSDictionary *)change{

//    NSLog(@"contentOffset:%f",self.scrollView.contentOffset.y);
    
    if (_scrollViewOriginalInset.top + self.scrollView.mj_offsetY < 0) {
        if (_scrollViewOriginalInset.top + self.scrollView.mj_offsetY < -CGRectGetHeight(self.bounds)) {
            self.cuteView.endPoint = CGPointMake(0, _scrollViewOriginalInset.top + self.scrollView.mj_offsetY + CGRectGetHeight(self.bounds));
        }else{
            self.cuteView.endPoint = CGPointMake(0, 0);
        }
    }
    
//    [super scrollViewContentOffsetDidChange:change];
    
    // 在刷新的refreshing状态
    if (self.state == MJRefreshStateRefreshing) {
        if (self.window == nil) return;
        
        // sectionheader停留解决
        CGFloat insetT = - self.scrollView.mj_offsetY > _scrollViewOriginalInset.top ? - self.scrollView.mj_offsetY : _scrollViewOriginalInset.top;
        insetT = insetT > self.mj_h + _scrollViewOriginalInset.top ? self.mj_h + _scrollViewOriginalInset.top : insetT;
        self.scrollView.mj_insetT = insetT;
        
        self.insetTDelta = _scrollViewOriginalInset.top - insetT;
        return;
    }
    
    // 跳转到下一个控制器时，contentInset可能会变
    _scrollViewOriginalInset = self.scrollView.contentInset;
    
    // 当前的contentOffset
    CGFloat offsetY = self.scrollView.mj_offsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top - self.frame.size.height;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    // >= -> >
    if (offsetY > happenOffsetY) return;
    
    // 普通 和 即将刷新 的临界点
    CGFloat normal2pullingOffsetY = happenOffsetY - self.mj_h;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.mj_h;
    
    if (self.scrollView.isDragging) { // 如果正在拖拽
        self.pullingPercent = pullingPercent;
        if (self.state == MJRefreshStateIdle && offsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && offsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = MJRefreshStateIdle;
        }
    } else if (self.state == MJRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
    
//
//    CGPoint oldP = [[change objectForKey:@"old"]CGPointValue];
//    CGPoint newP = [[change objectForKey:@"new"]CGPointValue];
//
////    CGPoint arrowCenter = self.stateLabel.center;
//    CGPoint endPoint = self.cuteView.endPoint;
//    endPoint.y += newP.y - oldP.y;
//    self.cuteView.endPoint = endPoint;
    
}

-(void)setState:(MJRefreshState)state{
    
    MJRefreshCheckState
    
    if (state == MJRefreshStateRefreshing) {
        [UIView animateWithDuration:0.5 animations:^{
            self.cuteView.alpha = 0;
        }];
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
    }if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
            }];
        } else {
            [self.loadingView stopAnimating];
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            }];
        }
    }
}

-(void)setPullingPercent:(CGFloat)pullingPercent{
    [super setPullingPercent:pullingPercent];
    if (pullingPercent == 0) {
        self.cuteView.alpha = 1;
    }
}

@end
