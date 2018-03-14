//
//  DiyRotateRefreshHeader.m
//  MJRefreshTest
//
//  Created by admin on 2017/12/14.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "DiyRotateRefreshHeader.h"

@interface DiyRotateRefreshHeader()

@property(nonatomic,retain)UILabel* rotateView;

@end

@implementation DiyRotateRefreshHeader

-(UILabel *)rotateView{
    if (!_rotateView) {
        _rotateView = [[UILabel alloc]init];
        UIFont *iconfont = [UIFont fontWithName:@"iconfont" size: 20];
        _rotateView.font = iconfont;
        _rotateView.text = @"\U0000e652";// \U0000e66d
        [_rotateView sizeToFit];
        [self addSubview:_rotateView];
    }
    return _rotateView;
}

-(void)placeSubviews{
    [super placeSubviews];
    
//    CGFloat radius = 30;
//    self.cuteView.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2 - radius / 2, CGRectGetHeight(self.bounds) / 2 - radius / 2, radius, radius);
    
//    self.automaticallyChangeAlpha = NO;
    
    CGFloat arrowCenterX = self.mj_w * 0.5;
    CGFloat arrowCenterY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 圈圈
    self.rotateView.center = arrowCenter;
}


-(void)setState:(MJRefreshState)state{
    
    MJRefreshCheckState
    
    if (state == MJRefreshStateRefreshing) {
//        [UIView animateWithDuration:0.5 animations:^{
//            self.cuteView.alpha = 0;
//        }];
//        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
//        [self.loadingView startAnimating];
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 0.3;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.fillMode = kCAFillModeForwards;
        [self.rotateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
    }if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            
            [self.rotateView.layer removeAllAnimations];
            
            CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
            rotationAnimation.duration = 0.2;
//            rotationAnimation.cumulative = YES;
//            rotationAnimation.repeatCount = HUGE_VALF;
            rotationAnimation.fillMode = kCAFillModeForwards;
            [self.rotateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            
//            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
//                self.loadingView.alpha = 0.0;
//            } completion:^(BOOL finished) {
//                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
//                if (self.state != MJRefreshStateIdle) return;
//                
//                self.loadingView.alpha = 1.0;
//                [self.loadingView stopAnimating];
//            }];
        } else {
//            [self.loadingView stopAnimating];
//            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
//            }];
        }
    }
}


//-(void)setPullingPercent:(CGFloat)pullingPercent{
//    [super setPullingPercent:pullingPercent];
//////    if (pullingPercent == 0) {
//////        self.cuteView.alpha = 1;
//////    }
////    self.rotateView.transform = CGAffineTransformMakeRotation(pullingPercent * 360 *M_PI / 180.0);
////    
////    NSLog(@"pullingPercent:%f",pullingPercent);
//}

//-(void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
////    self.scrollView.contentOffset.y + CGRectGetHeight(self.bounds));
//    
//    self.rotateView.transform = CGAffineTransformMakeRotation(self.scrollView.contentOffset.y * 36 *M_PI / 180.0);
//    
//    [super scrollViewContentOffsetDidChange:change];
//}


@end
