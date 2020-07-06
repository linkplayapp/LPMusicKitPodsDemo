//
//  GlobalUI.h
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/3/11.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmSourceObj.h"

NS_ASSUME_NONNULL_BEGIN

@interface GlobalUI : NSObject

+ (instancetype)sharedInstance;

// alarm clock
@property (retain) AlarmSourceObj * alarmSourceObj;


@end

NS_ASSUME_NONNULL_END
