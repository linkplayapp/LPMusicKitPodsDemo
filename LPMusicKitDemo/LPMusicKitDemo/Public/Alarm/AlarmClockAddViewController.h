//
//  AlarmClockAddViewController.h
//  iMuzo
//
//  Created by Ning on 15/4/9.
//  Copyright (c) 2015年 wiimu. All rights reserved.
//

#import "BasicViewController.h"

@interface AlarmClockAddViewController : BasicViewController

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) LPAlarmList *alarmList;
@property (nonatomic, assign) BOOL isFromEdit;//编辑闹钟
@property (nonatomic,copy) NSString *navigationTitle;


@end
