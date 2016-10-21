//
//  UICuteView.m
//  自定义粘性视图 设置两个点产生粘性拉伸 类似QQ粘性下拉刷新
//
//  Created by admin on 16/10/19.
//  Copyright © 2016年 admin. All rights reserved.
//
#import "UICuteView.h"

@interface UICuteView(){
    CGFloat r1;
    CGFloat r2;
    CGFloat x1;
    CGFloat y1;
    CGFloat x2;
    CGFloat y2;
    CGFloat centerDistance;
    CGFloat cosDigree;
    CGFloat sinDigree;
    
    CGPoint pointA; // A
    CGPoint pointB; // B
    CGPoint pointD; // D
    CGPoint pointC; // C
    CGPoint pointO; // O
    CGPoint pointP; // P
}

@property(nonatomic,retain)CAShapeLayer *drawLayer;
//@property(nonatomic,retain)CAShapeLayer *frontLayer;
//@property(nonatomic,retain)CAShapeLayer *backLayer;

@end

@implementation UICuteView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(CAShapeLayer *)drawLayer{
    if (!_drawLayer) {
        _drawLayer = [[CAShapeLayer alloc]init];
        [self.layer addSublayer:_drawLayer];
    }
    return _drawLayer;
}

//-(CAShapeLayer *)frontLayer{
//    if (!_frontLayer) {
//        _frontLayer = [[CAShapeLayer alloc]init];
//        [self.layer addSublayer:_frontLayer];
//    }
//    return _frontLayer;
//}
//
//-(CAShapeLayer *)backLayer{
//    if (!_backLayer) {
//        _backLayer = [[CAShapeLayer alloc]init];
//        [self.layer addSublayer:_backLayer];
//    }
//    return _backLayer;
//}

-(CGFloat)viscosity{
    if (!_viscosity) {
        _viscosity = 20;//默认20
    }
    return _viscosity;
}

-(void)setStartPoint:(CGPoint)startPoint{
    _startPoint = startPoint;
    [self setNeedsLayout];
}

-(void)setEndPoint:(CGPoint)endPoint{
    _endPoint = endPoint;
    [self setNeedsLayout];
}

-(void)setFillColor:(UIColor *)fillColor{
    _fillColor = fillColor;
    [self setNeedsLayout];
}


-(void)layoutSubviews{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self prepare];
    });
//    self.frontLayer.position = self.endPoint;//CGRectMake(self.endPoint.x, self.endPoint.y, 1, 1);
//    self.backLayer.position = self.startPoint;//CGRectMake(self.startPoint.x, self.startPoint.y, 1, 1);
    
    [self displayLinkAction];
    
    self.drawLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2., CGRectGetHeight(self.bounds) / 2.);
}


-(void)prepare{
    self.drawLayer.hidden = NO;
//    self.backLayer.hidden = YES;
//    self.frontLayer.hidden = YES;
}

- (void)displayLinkAction {
    x1 = self.startPoint.x;
    y1 = self.startPoint.y;
    x2 = self.endPoint.x;
    y2 = self.endPoint.y;
    
    centerDistance = sqrtf((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    if (centerDistance == 0) {
        cosDigree = 1;
        sinDigree = 0;
    } else {
        cosDigree = (y2 - y1) / centerDistance;
        sinDigree = (x2 - x1) / centerDistance;
    }
    
    r1 = self.frame.size.width / 2 - centerDistance / self.viscosity;
    r2 = self.frame.size.width / 2 - centerDistance / self.viscosity / 4;
    
    pointA = CGPointMake(x1 - r1 * cosDigree, y1 + r1 * sinDigree); // A
    pointB = CGPointMake(x1 + r1 * cosDigree, y1 - r1 * sinDigree); // B
    pointD = CGPointMake(x2 - r2 * cosDigree, y2 + r2 * sinDigree); // D
    pointC = CGPointMake(x2 + r2 * cosDigree, y2 - r2 * sinDigree); // C
    pointO = CGPointMake(pointA.x + (centerDistance / 2) * sinDigree,
                         pointA.y + (centerDistance / 2) * cosDigree);
    pointP = CGPointMake(pointB.x + (centerDistance / 2) * sinDigree,
                         pointB.y + (centerDistance / 2) * cosDigree);
    
    [self drawLayerPath];
}

- (void)drawLayerPath {
//    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2.;
    
//    self.frontLayer.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
//    self.frontLayer.cornerRadius = radius;
//    self.frontLayer.fillColor = self.fillColor.CGColor;
//    self.frontLayer.borderWidth = 1;
//    self.frontLayer.borderColor = strokeColor;
//    
////    backView.center = oldBackViewCenter;
//    self.backLayer.bounds = CGRectMake(0, 0, r1 * 2, r1 * 2);
//    self.backLayer.cornerRadius = r1;
//    self.backLayer.fillColor = self.fillColor.CGColor;
//    self.backLayer.lineWidth = 1;
//    self.backLayer.strokeColor = strokeColor;
    
    CGFloat digree = acos(cosDigree);
    
    UIBezierPath* cutePath = [UIBezierPath bezierPath];
    [cutePath moveToPoint:pointA];
    [cutePath addQuadCurveToPoint:pointD controlPoint:pointO];
    [cutePath addArcWithCenter:self.endPoint radius:r2 startAngle:digree + M_PI endAngle:digree + M_PI * 2 clockwise:false];
//    [cutePath addLineToPoint:pointD];
    [cutePath addLineToPoint:pointC];
    [cutePath addQuadCurveToPoint:pointB controlPoint:pointP];
    [cutePath addArcWithCenter:self.startPoint radius:r1 startAngle:digree endAngle:digree + M_PI clockwise:false];
//    [cutePath addLineToPoint:pointB];
    [cutePath moveToPoint:pointA];
    
//    if (self.backLayer.hidden == NO) {
    self.drawLayer.path = [cutePath CGPath];
    self.drawLayer.fillColor = self.fillColor.CGColor;
    self.drawLayer.lineWidth = self.lineWidth;
    if (self.lineWidth > 0) {
        self.drawLayer.strokeColor = self.strokeColor.CGColor;
    }
//        [self.containerView.layer insertSublayer:shapeLayer
//                                           below:self.frontView.layer];
//    }
}


@end
