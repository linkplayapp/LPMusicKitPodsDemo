//
//  LPPlayviewDissmissAnimation.m
//  muzoplayer
//
//  Created by lyr on 2020/7/2.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "LPPlayviewDissmissAnimation.h"

@implementation LPPlayviewDissmissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.time > 0 ? self.time : 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    UIView* transView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    transView = fromView;
    [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    transView.frame = CGRectMake(0, 0, width, height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //y从height
        transView.frame = CGRectMake(0, height, width, height);
    
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}



@end
