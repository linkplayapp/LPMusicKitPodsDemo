//
//  GlobalUI.m
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/3/11.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import "GlobalUI.h"

@implementation GlobalUI

+ (instancetype)sharedInstance{
    static GlobalUI *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[GlobalUI alloc] init];
    });
    return singleton;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.alarmSourceObj = [[AlarmSourceObj alloc] init];
    }
    return self;
}
    
@end
