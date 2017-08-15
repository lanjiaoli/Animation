//
//  SoundAnimationView.h
//  RoundLayer
//
//  Created by L on 2017/8/14.
//  Copyright © 2017年 L. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol sendVoiceDelegate <NSObject>

- (void)didFinishWithSendVoice;//录音完成并发送

- (void)cancelSendVoice; //取消发送
@end
@interface SoundAnimationView : UIView
@property (nonatomic, weak) id <sendVoiceDelegate>delegate;
@end
