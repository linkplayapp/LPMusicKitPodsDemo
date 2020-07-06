//
//  AlarmClockMusicViewController.h
//  iMuzo
//
//  Created by Ning on 15/4/10.
//  Copyright (c) 2015年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmSourceObj.h"

@interface AlarmClockMusicViewController : BasicViewController

@property (nonatomic,weak) id<AlarmSourceSelectDelegate>delegate;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic,strong) NSString *context;

@end
