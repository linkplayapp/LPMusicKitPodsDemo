//
//  LPPlayViewController.h
//  muzoplayer
//
//  Created by lyr on 2020/7/2.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "BasicViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LPPlayViewController : BasicViewController

//dissmiss接口，封装自定义动画
- (void)dismissViewControllerAnimated:(BOOL)animation;

/**
 指定设备UUID
 */
@property (nonatomic, strong) NSString *deviceId;

/**
 指定音源
 因播放歌曲，音响可能存在延迟，会出现偏差。
 指定音源，等待音响回应
 */
@property (nonatomic, strong) NSString *source;


@end

NS_ASSUME_NONNULL_END
