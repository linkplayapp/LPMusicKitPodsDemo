//
//  DeviceKVOObject.h
//  muzoplayer
//
//  Created by 许一宁 on 2019/8/6.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LPMusicKit/LPMusicKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceKVOObject : NSObject

@property (nonatomic,strong) LPDevice * boxInfo;

- (DeviceKVOObject *)initWithLPDevice:(LPDevice *)boxInfo;

@end

NS_ASSUME_NONNULL_END
