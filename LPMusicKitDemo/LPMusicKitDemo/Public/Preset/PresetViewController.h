//
//  PresetViewController.h
//  iMuzo
//
//  Created by Ning on 16/1/4.
//  Copyright © 2016年 wiimu. All rights reserved.
//

#import "BasicViewController.h"

@interface PresetViewController :BasicViewController

//deviceId
@property (nonatomic, strong) NSString *deviceId;

//选择闹铃
@property (nonatomic, assign) BOOL isAddAlarmClock;

//添加预置
@property (nonatomic, assign) BOOL isAddPreset;

//PlayHeader
@property (nonatomic, strong) LPPlayHeader *header;
//PlayItem
@property (nonatomic, strong) LPPlayItem *item;
//Account
@property (nonatomic, strong) LPAccount *account;

@end
