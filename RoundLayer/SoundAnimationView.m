//
//  SoundAnimationView.m
//  RoundLayer
//
//  Created by L on 2017/8/14.
//  Copyright © 2017年 L. All rights reserved.
//

#import "SoundAnimationView.h"
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define radiusNum 40
#define kColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kRectMake(x,y,w,h) CGRectMake(x, y, w, h)
#define kNormalBtnTitleColor kColorRGBA(62, 62, 62, 1)
#define kSelectBtnTitleColor kColorRGBA(248, 95, 72, 1)
@interface SoundAnimationView()
{
    BOOL isSelect;
    NSInteger secondNum;
    UIView *btnView ;
}
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAAnimationGroup* animaGroup;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *BGImageView; //背景图片
@property (nonatomic, strong) UIImageView *stopImageView; //背景图片

@end
@implementation SoundAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        secondNum = 00;
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupUI{
    
    [self addSubview:self.timeLabel];
    [self.layer addSublayer:self.shapeLayer];
    [self addSubview:self.BGImageView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.shapeLayer.frame;
    [button addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

    isSelect = YES;
    [self setSwitchBtn];

}
- (void)setSwitchBtn{
    
    btnView =[[UIView alloc]init];
    btnView.frame = kRectMake(0, self.shapeLayer.frame.origin.y+ 12 + radiusNum*2, screenWidth, 20);
    [self addSubview:btnView];
    
    NSArray *titleArray = @[@"自动录音",@"长按录音"];
    for (int i = 0; i<titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = kRectMake(screenWidth/2-25 + 66*i, 0, 50, 20);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        if (i == 0) {
            button.selected = YES;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitleColor:kNormalBtnTitleColor forState:UIControlStateNormal];
        [button setTitleColor:kSelectBtnTitleColor forState:UIControlStateSelected];
        button.tag = i+10;
        [button addTarget:self action:@selector(switchBtnSelector:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:button];
    }
}
#pragma mark - NSTimer Target
- (void)timerTarget:(NSTimer *)time
{
    secondNum++;
    _timeLabel.text = [NSString stringWithFormat:@"%lds:60s",(long)secondNum];
}

#pragma mark - Animation Method
//Start Animation
- (void)startAnimation{
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerTarget:) userInfo:nil repeats:YES];
    _shapeLayer.fillColor = kColorRGBA(68, 138, 255, 1).CGColor;
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    [self.shapeLayer addAnimation:self.animaGroup forKey:@"scaleGroup"];
}
//Stop Animation
- (void)stopAnimation{
    [_timer invalidate];
    if (_shapeLayer) {
        _shapeLayer.fillColor = kColorRGBA(255, 255, 255, 1).CGColor;

        [self.shapeLayer removeAllAnimations];
    }
}

#pragma mark - Button Method
- (void)btnSelect:(UIButton *)btn
{
    
    if (isSelect) {
        [self startAnimation];
        isSelect = NO;
        _BGImageView.image = [UIImage imageNamed:@"bg"];
        self.stopImageView.image = [UIImage imageNamed:@"暂停"];
    }else{
        [self stopAnimation];
        isSelect = YES;
        secondNum = 0;
        _timeLabel.text = [NSString stringWithFormat:@"%lds:60s",(long)secondNum];


    }
}
- (void)switchBtnSelector:(UIButton *)btn
{
    NSInteger tags = btn.tag-10;
    for (int i = 0; i <2; i++) {
        UIButton *selectBtn = [self viewWithTag:10+i];
        if (tags == i) {
            selectBtn.selected = YES;
        }else{
            selectBtn.selected = NO;
        }
    }
    if (tags == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            btnView.frame = kRectMake(-66, self.shapeLayer.frame.origin.y+ 12 + radiusNum*2, screenWidth, 20);
        }];
        _BGImageView.image = [UIImage imageNamed:@"bg"];
        self.stopImageView.image = [UIImage imageNamed:@"麦克风"];


    }else{
        _BGImageView.image = [UIImage imageNamed:@"开始"];
        self.stopImageView.image = nil;

        [UIView animateWithDuration:0.5 animations:^{
            btnView.frame = kRectMake(0, self.shapeLayer.frame.origin.y+ 12 + radiusNum*2, screenWidth, 20);
        }];
    }
}
#pragma mark - LazyLoading
- (CAShapeLayer *)shapeLayer
{
    if (_shapeLayer==nil) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = CGRectMake((screenWidth-radiusNum*2)/2, 100, radiusNum*2, radiusNum*2);
        _shapeLayer.fillColor = kColorRGBA(255, 255, 255, 1).CGColor;
        _shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        //通过贝塞尔曲线绘制圆
        CGFloat startAngle = 0.0;
        CGFloat endAngle = M_PI *2;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radiusNum, radiusNum) radius:radiusNum startAngle:startAngle endAngle:endAngle clockwise:YES];
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
        _animaGroup.duration = 2;
        _animaGroup.repeatCount = HUGE;
        _animaGroup.autoreverses = YES;
    }
    return _animaGroup;
    
}
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel= [[UILabel alloc]init];
        _timeLabel.text = @"0s:60s";
        _timeLabel.textColor = [UIColor blueColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.frame = CGRectMake(0, 70, screenWidth, 20);
        
    }
    return _timeLabel;
}

- (UIImageView *)BGImageView
{
    if (_BGImageView == nil) {
        _BGImageView = [[UIImageView alloc]init];
        _BGImageView.frame = self.shapeLayer.frame;
        _BGImageView.image = [UIImage imageNamed:@"开始"];
        self.stopImageView.frame = kRectMake(20, 20, 40, 40);
        [_BGImageView addSubview:self.stopImageView];
    }
    return _BGImageView;
}
- (UIImageView *)stopImageView
{
    if (_stopImageView == nil) {
        _stopImageView = [[UIImageView alloc]init];
        
    }
    return _stopImageView;
}
@end
