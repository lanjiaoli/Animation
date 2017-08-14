//
//  SoundAnimationView.m
//  RoundLayer
//
//  Created by L on 2017/8/14.
//  Copyright © 2017年 L. All rights reserved.
//

#import "SoundAnimationView.h"
@interface SoundAnimationView()
{
    BOOL isSelect;
}
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAAnimationGroup* animaGroup;
@end
@implementation SoundAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}
#pragma mark - LazyLoading
- (CAShapeLayer *)shapeLayer
{
    if (_shapeLayer==nil) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = CGRectMake(100, 100, 100, 100);
        _shapeLayer.fillColor = [UIColor blueColor].CGColor;
        _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        //通过贝塞尔曲线绘制圆
        CGFloat startAngle = 0.0;
        CGFloat endAngle = M_PI *2;

        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(50, 50) radius:50 startAngle:startAngle endAngle:endAngle clockwise:YES];
        _shapeLayer.path = bezierPath.CGPath;

    }
    return _shapeLayer;
}
- (CAAnimationGroup *)animaGroup{
    if (_animaGroup == nil) {
        CABasicAnimation * _opacityAnima = [CABasicAnimation animationWithKeyPath:@"opacity"];
        _opacityAnima.fromValue = @(0.7);
        _opacityAnima.toValue = @(0.3);
        
        CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        expandAnimation.fromValue = [NSNumber numberWithFloat:1]; // 开始时的倍率
        expandAnimation.toValue = [NSNumber numberWithFloat:1.5]; // 结束时的倍率
        
        
        _animaGroup = [CAAnimationGroup animation];
        _animaGroup.animations = @[ expandAnimation,_opacityAnima];
        _animaGroup.duration = 3;
        _animaGroup.repeatCount = HUGE;
        _animaGroup.autoreverses = YES;
    }
    return _animaGroup;
   
}
#pragma mark - setupUI
- (void)setupUI{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100,100, 100, 100);
    [button setTitle:@"暂停" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor]];
    button.layer.cornerRadius = 50;
    [button addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    isSelect = YES;
}


#pragma mark - Public Method
//Start Animation
- (void)startAnimation{
    [self.layer addSublayer:self.shapeLayer];
    [self.shapeLayer addAnimation:self.animaGroup forKey:@"scaleGroup"];
}
//Stop Animation
- (void)stopAnimation{
    if (_shapeLayer) {
        [self.shapeLayer removeAllAnimations];
        [self.shapeLayer removeFromSuperlayer];

    }
}

#pragma mark - Button Method
- (void)btnSelect:(UIButton *)btn
{
    
    if (isSelect) {
        [self startAnimation];
        isSelect = NO;

    }else{
        [self stopAnimation];
        isSelect = YES;

    }
}
@end
