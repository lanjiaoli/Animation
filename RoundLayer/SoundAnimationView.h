//
//  SoundAnimationView.h
//  RoundLayer
//
//  Created by L on 2017/8/14.
//  Copyright © 2017年 L. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SendVoiceDelegate <NSObject>
@optional
- (void)clickEventSelect:(BOOL)isLongPress; // isLongPress 判断是否是长按模式 YES是 NO否

- (void)didFinishWithSendVoice;//录音完成并发送

- (void)cancelSendVoice; //取消发送

- (void)moveTouchWithCancle:(BOOL)isCancle; // 判断手势是否移动到要取消的位置

- (void)countdownReminderWithTimer; //倒计时

- (void)SendVoiceWithClick; //自动录音模式下 点击发送 来更换Label提示
@end
@interface SoundAnimationView : UIView
@property (nonatomic, weak) id <SendVoiceDelegate>delegate;
@property (nonatomic, strong) UIViewController *viewController;
-(void)removeToSubView;

@end
