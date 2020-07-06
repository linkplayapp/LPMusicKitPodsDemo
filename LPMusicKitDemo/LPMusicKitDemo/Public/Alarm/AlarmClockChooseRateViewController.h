//
//  AlarmClockChooseRateViewController.h
//  iMuzo
//
//  Created by Ning on 15/4/9.
//  Copyright (c) 2015年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmClockAddViewController.h"

@protocol AlarmClockChooseRateViewController <NSObject>

@optional
- (void)chooseResultRate:(NSDictionary *)dayDictionary isOnlyOnce:(BOOL)isOnce;
@end

@interface AlarmClockChooseRateViewController : BasicViewController

@property (nonatomic,weak) id<AlarmClockChooseRateViewController>delegate;
@property (nonatomic,assign) BOOL isOnced;
@property (nonatomic,retain) NSArray *rateDaysSpecial;


@end
