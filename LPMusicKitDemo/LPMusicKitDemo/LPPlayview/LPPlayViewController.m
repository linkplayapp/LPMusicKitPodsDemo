//
//  LPPlayViewController.m
//  muzoplayer
//
//  Created by lyr on 2020/7/2.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "LPPlayViewController.h"
#import "LPBasicHeader.h"
#import "LPPlayviewDissmissAnimation.h"
#import "LPDefaulePlayView.h"

@interface LPPlayViewController ()<UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate>
{
    BOOL isDissmiss;
}

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, strong) LPPlayviewDissmissAnimation *presentAnimation;

//默认的playView
@property (nonatomic, strong) LPDefaulePlayView *playView;

@end

@implementation LPPlayViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.transitioningDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isDissmiss = NO;
    
    if (self.playView) {
        [self.playView refresState];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.presentAnimation = [[LPPlayviewDissmissAnimation alloc] init];
    isDissmiss = NO;
    
    LPDevice *currentBox = [[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
    NSLog(@"currentBox device:%@  uuid:%@", currentBox.deviceStatus.friendlyName,self.deviceId);
    NSString *trackSource = currentBox.mediaInfo.trackSource;
    
    if (self.source.length > 0) {
        trackSource = self.source;
    }
    

    self.playView = [[[NSBundle mainBundle] loadNibNamed:@"LPDefaulePlayView" owner:self options:nil] lastObject];
    self.playView.frame = self.view.frame;
    self.playView.deviceId = self.deviceId;
    self.playView.playViewcontroller = self;
    [self.view addSubview:self.playView];
    [self.playView refreshUI];
    
    [self addGestureRecognizerWithView:self.playView];
}

- (void)addGestureRecognizerWithView:(UIView *)contentView
{
    //下滑手势
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    recognizer.delegate = self;
    [contentView addGestureRecognizer:recognizer];

    //拖拽手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    panGestureRecognizer.delegate = self;
    [panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerAction:)];
    [contentView addGestureRecognizer:panGestureRecognizer];

    [recognizer requireGestureRecognizerToFail:panGestureRecognizer];
    
    //去除所有的滑动条的手势
    [self.playView dealRecognizer:panGestureRecognizer swipeGestureRecognizer:recognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"nihaofaof：%@", gestureRecognizer.class);
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
        CGFloat process = translation.y;
        NSLog(@"nihaofaof 当前手势速度：%f  水平方向：%f", process, translation.x);
    
        if (process > 420) {
            return NO;
        }
    }
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//
//    NSLog(@"nihaofaof view: %@ %@  other view %@ %@", gestureRecognizer.class, gestureRecognizer.view, otherGestureRecognizer.class, otherGestureRecognizer.view);
//
//    return YES;
//
//}

//dissmiss接口
- (void)dismissViewControllerAnimated:(BOOL)animation
{
    isDissmiss = YES;
    self.presentAnimation.time = 0.2;
    [self dismissViewControllerAnimated:animation completion:nil];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer
{
//    NSLog(@"nihaofaof  AAA");
    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self dismissViewControllerAnimated:YES];
    }
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan{
    if (isDissmiss) {
        return;
    }
//    NSLog(@" nihaofaof :%@ %@ 当前的位置：%f", pan.class, pan, [pan translationInView:self.view].y);
    //产生百分比
    CGFloat process = [pan translationInView:self.view].y / (SCREENHEIGHT);
    process = MIN(1.0,(MAX(0.0, process)));
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        [self dismissViewControllerAnimated:YES completion:nil];

    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self.interactiveTransition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (process > 0.5)
        {
            [self.interactiveTransition finishInteractiveTransition];
        }else{
            [self.interactiveTransition cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.presentAnimation;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}


@end
