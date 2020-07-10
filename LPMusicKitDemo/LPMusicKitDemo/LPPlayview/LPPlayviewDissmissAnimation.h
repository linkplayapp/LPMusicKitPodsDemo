//
//  LPPlayviewDissmissAnimation.h
//  muzoplayer
//
//  Created by lyr on 2020/7/2.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPPlayviewDissmissAnimation : NSObject <UIViewControllerAnimatedTransitioning>

//设置动画的时间
@property (nonatomic, assign) NSTimeInterval time;

@end

NS_ASSUME_NONNULL_END
