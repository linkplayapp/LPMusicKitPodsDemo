//
//  LPDefaulePlayView.h
//  muzoplayer
//
//  Created by lyr on 2020/7/3.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LPDefaulePlayView : UIView

/**
 父控制器
 */
@property (nonatomic, strong) LPPlayViewController *playViewcontroller;

/**
 设备的UUID
 */
@property (nonatomic, strong) NSString *deviceId;

/**
 刷新UI
 */
- (void)refreshUI;

/**
 刷新歌曲信息
 */
- (void)refresState;


///去除外面的手势
- (void)dealRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer swipeGestureRecognizer:(UISwipeGestureRecognizer *)swipeGestureRecognizer;


@end

NS_ASSUME_NONNULL_END
