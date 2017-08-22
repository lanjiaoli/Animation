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
#define kMaxLensileNumber 110
#define kMinLensileNumber -30
#define kTimeDownCount 50
#define kFullTimeCount 60

#define kTimeLabel_Y  18
#define kTalkReminder @"按住说话"
#define kClickSendStr @"点击发送"
#define kHitShowString @"等录音完成,才能切换模式."
@interface SoundAnimationView()
{
    BOOL isSelect;
    NSInteger secondNum;
    UIView *btnView;
    BOOL isSendVoice;
    BOOL isLongPress;
    BOOL isLongPressImage;
    BOOL isReminderHub; //长按自动发送后 是否提示
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
@property (nonatomic, strong) UIButton *cancelBtn;

@end
@implementation SoundAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        secondNum = 0;
        isLongPress = NO;
        isReminderHub = YES;
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupUI{
    
    [self addSubview:self.timeLabel];
    [self setLeftImageAndRightImage];
    self.cancelBtn.hidden = YES;
    [self addSubview:self.cancelBtn];
    [self.layer addSublayer:self.shapeLayer];
    [self addSubview:self.BGImageView];
    [self addSubview:self.clickBtn];
    [self addSubview:self.longPressBtn];
    [self.BGImageView addSubview:self.sendLabel];
    [self.longPressBtn setEnabled:NO];
    isSelect = YES;
    [self setSwitchBtn];
    
}
- (void)setLeftImageAndRightImage{
    UIImageView *leftImageView = [[UIImageView alloc]initWithFrame:kRectMake((screenWidth-radiusNum*2)/2-40, kTimeLabel_Y, 40, 15)];
    leftImageView.image = [UIImage imageNamed:@"左侧波纹"];
    [self addSubview:leftImageView];
    
    UIImageView *rightImageView = [[UIImageView alloc]initWithFrame:kRectMake((screenWidth-radiusNum*2)/2+80, kTimeLabel_Y, 40, 15)];
    rightImageView.image = [UIImage imageNamed:@"右侧波纹"];
    [self addSubview:rightImageView];
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
    
    UILabel *pointLabel= [[UILabel alloc]init];
    pointLabel.text = @"·";
    pointLabel.textAlignment = NSTextAlignmentCenter;
    pointLabel.font = [UIFont systemFontOfSize:13];
    pointLabel.frame =kRectMake(screenWidth/2-25 + 50, 5, 16, 10);
    [btnView addSubview:pointLabel];
}
#pragma mark - NSTimer Target
- (void)timerTarget:(NSTimer *)time
{
    secondNum++;
    _timeLabel.text = [NSString stringWithFormat:@"%ld秒 : 60秒",(long)secondNum];
    if (isLongPress) {
        if(secondNum == kFullTimeCount){
            self.reminderLabel.backgroundColor = [UIColor whiteColor];
            self.reminderLabel.text =kTalkReminder;
            [self.delegate didFinishWithSendVoice];
            secondNum = 0;
            [self stopAnimation];
            isReminderHub = NO;
        }
    }else{
        if (secondNum == kTimeDownCount) {
            //倒计时显示
            [self.delegate countdownReminderWithTimer];
        }else if(secondNum == kFullTimeCount){
            [self.delegate didFinishWithSendVoice];
            secondNum = 0;
            [self stopAnimation];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self publicMethodWithStart];
            });
            
        }
    }
    
}

#pragma mark - Animation Method
//Start Animation
- (void)startAnimation{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerTarget:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    _shapeLayer.fillColor = kColorRGBA(68, 138, 255, 1).CGColor;
    [self.shapeLayer addAnimation:self.animaGroup forKey:@"scaleGroup"];
}
//Stop Animation
- (void)stopAnimation{
    [_timer invalidate];
    _timer = nil;
    if (_shapeLayer) {
        _shapeLayer.fillColor = kColorRGBA(255, 255, 255, 1).CGColor;
        
        [self.shapeLayer removeAllAnimations];
    }
    _timeLabel.text = [NSString stringWithFormat:@"%ld秒 : 60秒",(long)secondNum];
    
}
#pragma mark - public Method
- (void)publicMethodWithStart{
    [self startAnimation];
    _BGImageView.image = [UIImage imageNamed:@"bg"];
    self.stopImageView.image = [UIImage imageNamed:@"暂停"];
    [self.delegate clickEventSelect:NO];
    
    
}
#pragma mark - Button Method
//click 点击方法
- (void)btnSelect:(UIButton *)btn
{
    
    if (isSelect) {
        [self publicMethodWithStart];
        isSelect = NO;
        isSendVoice  = NO;
        self.cancelBtn.hidden = NO;
    }else{
        
        if (secondNum > 0) {
            [self stopAnimation];
            self.stopImageView.image = nil;
            self.sendLabel.text = kClickSendStr;
            if (isSendVoice) {
                [self clickSendVoice];
            }else{
                if ([self.delegate respondsToSelector:@selector(SendVoiceWithClick)]) {
                    [self.delegate SendVoiceWithClick];
                }
            }
            isSendVoice  = YES;
        }else{
//            [self.viewController showHint:@"说话时间太短"];
        }
        
        
    }
}

- (void)clickSendVoice{
    secondNum = 0;
    [self.delegate didFinishWithSendVoice];
    isSelect = YES;
    self.sendLabel.text = @"";
    self.BGImageView.image = [UIImage imageNamed:@"开始"];
    _timeLabel.text = [NSString stringWithFormat:@"%ld秒 : 60秒",(long)secondNum];
    self.cancelBtn.hidden = YES;
    
}
//长按点击方法
- (void)longPressBtnSelect:(UIButton *)btn event:(UIEvent *)event{
    UITouchPhase phase = event.allTouches.anyObject.phase;
    isLongPress = YES;
    if (phase == UITouchPhaseBegan) {
        [self startVoice];
        
    }else if(phase == UITouchPhaseMoved){
        CGPoint point =  [event.allTouches.anyObject locationInView:_longPressBtn];
        if (point.y < kMinLensileNumber || point.y >= kMaxLensileNumber|| point.x >= kMaxLensileNumber ||point.x < kMinLensileNumber) {
            [self.delegate moveTouchWithCancle:NO];
        }else{
            [self.delegate moveTouchWithCancle:YES];
        }
    }else if (phase == UITouchPhaseEnded){
        CGPoint point =  [event.allTouches.anyObject locationInView:_longPressBtn];
        if (point.y < kMinLensileNumber || point.y >= kMaxLensileNumber|| point.x >= kMaxLensileNumber ||point.x < kMinLensileNumber) {
            [self canleSend];
        }else{
            self.reminderLabel.backgroundColor = [UIColor whiteColor];
            self.reminderLabel.text =kTalkReminder;
            if (secondNum >0) {
                [self.delegate didFinishWithSendVoice];
            }else{
                if (isReminderHub) {
//                    [self.viewController showHint:@"说话时间太短"];
                    [self.delegate cancelSendVoice];
                    
                }else{
                    NSLog(@"取消了");
                    isReminderHub = YES;
                }
                
            }
            secondNum = 0;
            [self stopAnimation];
        }
        
    }
    
}
- (void)startVoice{
    [self.delegate clickEventSelect:YES];
    [self startAnimation];
    self.reminderLabel.backgroundColor = [UIColor clearColor];
    self.reminderLabel.text = @"";
}
- (void)canleSend{
    secondNum = 0;
    [self stopAnimation];
    [self.delegate cancelSendVoice];
    self.reminderLabel.backgroundColor = [UIColor whiteColor];
    self.reminderLabel.text = kTalkReminder;
}
- (void)buttonEventTouchUpInside:(UIButton *)btn{
    [self.delegate didFinishWithSendVoice];
    [self stopAnimation];
    self.reminderLabel.backgroundColor = [UIColor whiteColor];
    self.reminderLabel.text = kTalkReminder;
}
- (void)btnActionWithCancle:(UIButton *)btn{
    
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"取消当条语音录制" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *commentAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
        [self removeToSubView];
        [self.delegate cancelSendVoice];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    
    [alerController addAction:commentAction];
    [alerController addAction:cancelAction];
    [self.viewController presentViewController:alerController animated:YES completion:nil];
    
    
}

- (void)switchBtnSelector:(UIButton *)btn
{
    
    if (!isSelect) {
        
//        [self.viewController showHint:kHitShowString];
        
    }else{
        [self stopAnimation];
        self.cancelBtn.hidden = YES;
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
            isLongPressImage = YES;
            [self.longPressBtn setEnabled:YES];
            [self.clickBtn setEnabled:NO];
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = kRectMake(-66, self.shapeLayer.frame.origin.y+ 12 + radiusNum*2, screenWidth, 20);
            }];
            _BGImageView.image = [UIImage imageNamed:@"bg"];
            self.stopImageView.image = [UIImage imageNamed:@"麦克风"];
            [self addSubview:self.reminderLabel];
        }else{
            isLongPressImage = NO;
            isLongPress = NO;
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
        _shapeLayer.frame = CGRectMake((screenWidth-radiusNum*2)/2, 40, radiusNum*2, radiusNum*2);
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
        _animaGroup.removedOnCompletion = NO;
        _animaGroup.autoreverses = YES;
    }
    return _animaGroup;
    
}
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel= [[UILabel alloc]init];
        _timeLabel.text = @"0秒 : 60秒";
        _timeLabel.textColor = kLabelNormalTextColor;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.frame = CGRectMake(0, kTimeLabel_Y, screenWidth, 15);
        
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
        [button addTarget:self action:@selector(longPressBtnSelect:event:) forControlEvents:UIControlEventAllTouchEvents];
        _longPressBtn = button;
    }
    return _longPressBtn;
}
- (UILabel *)reminderLabel
{
    if (_reminderLabel == nil) {
        _reminderLabel = [[UILabel alloc]init];
        _reminderLabel.textColor = kLabelNormalTextColor;
        _reminderLabel.frame =kRectMake(0, kTimeLabel_Y, screenWidth, 15);
        _reminderLabel.text = kTalkReminder;
        _reminderLabel.textAlignment = NSTextAlignmentCenter;
        _reminderLabel.font = [UIFont systemFontOfSize:13];
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
-(UIButton *)cancelBtn{
    if (_cancelBtn==nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = kRectMake(screenWidth - 58, _timeLabel.frame.origin.y, 40, 15);
        [button addTarget:self action:@selector(btnActionWithCancle:) forControlEvents:UIControlEventTouchUpInside];
        UILabel* label = [[UILabel alloc]init];
//        label.textColor = kColorRGBA(248, 95, 72);
        label.frame =kRectMake(0, 0, button.frame.size.width, button.frame.size.height);
        label.text = @"取消";
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:12];
        [button addSubview:label];
        _cancelBtn = button;
    }
    return _cancelBtn;
}
#pragma mark - RemoveToSubView
-(void)removeToSubView
{
    
    [self stopAnimation];
    secondNum = 0;
    isSelect = YES;
    self.sendLabel.text = @"";
    if (isLongPressImage) {
        self.BGImageView.image = [UIImage imageNamed:@"bg"];
        self.stopImageView.image = [UIImage imageNamed:@"麦克风"];
        
        
    }else{
        self.BGImageView.image = [UIImage imageNamed:@"开始"];
        self.stopImageView.image = nil;
        
    }
    self.cancelBtn.hidden = YES;
    _timeLabel.text = [NSString stringWithFormat:@"%ld秒 : 60秒",(long)secondNum];
}

@end
