//
//  AlarmSourceObj.h
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/3/11.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LPMDPKit/LPPlayMusicList.h>

/**
 用于选择闹钟铃声
 */
NS_ASSUME_NONNULL_BEGIN

@protocol AlarmSourceSelectDelegate <NSObject>

//闹钟铃声来自于音源
- (void)alarmSourceLPPlayMusicList:(LPPlayMusicList *)playMusicList;

//闹钟铃声来自于预置
- (void)alarmPresetIndex:(int)index presetName:(NSString *)presetName;

@end

@interface AlarmSourceObj : NSObject

//是否在选择闹铃
@property (assign) BOOL isEditingAlarmSource;

//选择闹铃完成之后需要回到的控制器
@property (weak) UIViewController<AlarmSourceSelectDelegate> * alarmRootViewController;

@end

NS_ASSUME_NONNULL_END
