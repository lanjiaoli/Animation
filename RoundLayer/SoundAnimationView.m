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
#define kLabelNormalTextColor kColorRGBA(68, 133, 255, 1)

@interface SoundAnimationView()
{
    BOOL isSelect;
    NSInteger secondNum;
    UIView *btnView;
    BOOL isSendVoice;
}
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAAnimationGroup* animaGroup;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *BGImageView; //背景图片
@property (nonatomic, strong) UIImageView *stopImageView; //背景图片
@property (nonatomic, strong) UILabel *reminderLabel;
@property (nonatomic, strong) UIButton *clickBtn;
@property (nonatomic, strong) UIButton *longPressBtn;
@property (nonatomic, strong) UILabel *sendLabel;
@end
@implementation SoundAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        secondNum = 0;
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupUI{
    
    [self addSubview:self.timeLabel];
    [self.layer addSublayer:self.shapeLayer];
    [self addSubview:self.BGImageView];
    [self addSubview:self.clickBtn];
    [self addSubview:self.longPressBtn];
    [self.BGImageView addSubview:self.sendLabel];
    [self.longPressBtn setEnabled:NO];
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
    
    if (secondNum == 10) {
        NSLog(@"你到时间了");
    }
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
    secondNum = 0;
    _timeLabel.text = [NSString stringWithFormat:@"%lds:60s",(long)secondNum];
    
}

#pragma mark - Button Method
//click 点击方法
- (void)btnSelect:(UIButton *)btn
{
    
    if (isSelect) {
        [self startAnimation];
        isSelect = NO;
        _BGImageView.image = [UIImage imageNamed:@"bg"];
        self.stopImageView.image = [UIImage imageNamed:@"暂停"];
        isSendVoice  = NO;
        
    }else{
        [self stopAnimation];
        self.stopImageView.image = nil;
        self.sendLabel.text = @"点击发送";
        if (isSendVoice) {
            [self clickSendVoice];
            
        }
        isSendVoice  = YES;
        
    }
}
- (void)clickSendVoice{
    
    [self.delegate didFinishWithSendVoice];
    isSelect = YES;
    self.sendLabel.text = @"";
    self.BGImageView.image = [UIImage imageNamed:@"开始"];
    NSLog(@"我发送了");
}
//长按点击方法
- (void)longPressBtnSelect:(UIButton *)btn{
    
    NSLog(@"长按区域");
    [self startAnimation];
    self.reminderLabel.backgroundColor = [UIColor clearColor];
    self.reminderLabel.text = @"";
}
- (void)buttonEventTouchUpInside:(UIButton *)btn{
    NSLog(@"按完了");
    [self.delegate didFinishWithSendVoice];
    [self stopAnimation];
    self.reminderLabel.backgroundColor = [UIColor whiteColor];
    self.reminderLabel.text = @"按住说话";
}
- (void)buttonEventTouchUpOutside:(UIButton *)btn{
    NSLog(@"不按了 取消");
    [self stopAnimation];
    [self.delegate cancelSendVoice];
    self.reminderLabel.backgroundColor = [UIColor whiteColor];
    self.reminderLabel.text = @"按住说话";
}

- (void)switchBtnSelector:(UIButton *)btn
{
    if (!isSelect) {
        NSLog(@"再录音状态 不能点击切换");
    }else{
        [self stopAnimation];
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
            [self.longPressBtn setEnabled:YES];
            [self.clickBtn setEnabled:NO];
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = kRectMake(-66, self.shapeLayer.frame.origin.y+ 12 + radiusNum*2, screenWidth, 20);
            }];
            _BGImageView.image = [UIImage imageNamed:@"bg"];
            self.stopImageView.image = [UIImage imageNamed:@"麦克风"];
            [self addSubview:self.reminderLabel];
        }else{
            [self.longPressBtn setEnabled:NO];
            [self.clickBtn setEnabled:YES];
            _BGImageView.image = [UIImage imageNamed:@"开始"];
            self.stopImageView.image = nil;
            
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = kRectMake(0, self.shapeLayer.frame.origin.y+ 12 + radiusNum*2, screenWidth, 20);
            }];
            [self.reminderLabel removeFromSuperview];
        }
        
    }
}
#pragma mark - Lazy Loading
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
        _timeLabel.textColor = kLabelNormalTextColor;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.frame = CGRectMake(0, 68, screenWidth, 20);
        
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
-(UIButton *)clickBtn
{
    if (_clickBtn == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.shapeLayer.frame;
        [button addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
        _clickBtn = button;
    }
    return _clickBtn;
}
-(UIButton *)longPressBtn
{
    if (_longPressBtn == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.shapeLayer.frame;
        [button addTarget:self action:@selector(longPressBtnSelect:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonEventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonEventTouchUpOutside:) forControlEvents:UIControlEventTouchDragExit];
        _longPressBtn = button;
    }
    return _longPressBtn;
}
- (UILabel *)reminderLabel
{
    if (_reminderLabel == nil) {
        _reminderLabel = [[UILabel alloc]init];
        _reminderLabel.textColor = kLabelNormalTextColor;
        _reminderLabel.frame =kRectMake(0, _timeLabel.frame.origin.y, screenWidth, 20);
        _reminderLabel.text = @"按住说话";
        _reminderLabel.textAlignment = NSTextAlignmentCenter;
        _reminderLabel.font = [UIFont systemFontOfSize:12];
        _reminderLabel.backgroundColor = [UIColor whiteColor];
    }
    return _reminderLabel;
}
- (UILabel *)sendLabel
{
    if (_sendLabel == nil) {
        _sendLabel = [[UILabel alloc]init];
        _sendLabel.textColor = [UIColor whiteColor];
        _sendLabel.frame =kRectMake(0, radiusNum -10,radiusNum*2,20);
        _sendLabel.textAlignment = NSTextAlignmentCenter;
        _sendLabel.font = [UIFont systemFontOfSize:12];
        
    }
    return _sendLabel;
}





@end
