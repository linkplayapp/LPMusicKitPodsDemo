//  category: playview
//
//  FDProgressSlider.m
//  FreeDream
//
//  Created by Seewo on 13-9-10.
//  Copyright (c) 2013年 Seewo. All rights reserved.
//

#import "LPProgressSlider.h"
#import "LPBasicHeader.h"

@interface LPProgressSlider()
<UIGestureRecognizerDelegate>
{
    UIImageView * firstPartBack;
    int leftTimeLabelWidth;
    int rightTiemLabelWidth;
}

@end

@implementation LPProgressSlider

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //左边时间
    self.leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.leftTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.leftTimeLabel setTextAlignment:NSTextAlignmentLeft];
    [self.leftTimeLabel setFont:[UIFont systemFontOfSize:12]];
    [self.leftTimeLabel setText:@"00:00"];
    [self.leftTimeLabel setTextColor:HWCOLORA(255, 255, 255, 0.6)];
    [self addSubview:self.leftTimeLabel];

    //右边时间
    self.rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.rightTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.rightTimeLabel setTextAlignment:NSTextAlignmentRight];
    [self.rightTimeLabel setFont:[UIFont systemFontOfSize:12]];
    [self.rightTimeLabel setText:@"00:00"];
    [self.rightTimeLabel setTextColor:HWCOLORA(255, 255, 255, 0.6)];
    [self addSubview:self.rightTimeLabel];

    //slider
    self.sliderBackground = [[UIImageView alloc] init];
    self.sliderBackground.backgroundColor = HWCOLORA(255, 255, 255, 0.2);
    [self addSubview:self.sliderBackground];

    firstPartBack = [[UIImageView alloc] init];
    firstPartBack.backgroundColor = HWCOLORA(255, 255, 255, 0.4);
    [self addSubview:firstPartBack];

    self.sliderBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 4, 4)];
    self.sliderBar.backgroundColor = HWCOLORA(216, 216, 216, 1);
    self.sliderBar.layer.masksToBounds = YES;
    self.sliderBar.layer.cornerRadius = 2;
    [self addSubview:self.sliderBar];
    
    [self setExclusiveTouch:YES];

    self.currentTime = 0;
    self.totalTime = 0;

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)dealloc
{
    [self.sliderUpdateTimer invalidate];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    leftTimeLabelWidth = rightTiemLabelWidth = frame.size.width/2.0;
     self.sliderBackground.frame = CGRectMake(0, 6, frame.size.width, 2);
    
     //set frame
     [self.leftTimeLabel setFrame:CGRectMake(0, 7 + 6, leftTimeLabelWidth, 17)];
     [self.rightTimeLabel setFrame:CGRectMake(leftTimeLabelWidth, 7 + 6, rightTiemLabelWidth, 17)];

     self.sliderBar.center = CGPointMake(self.sliderBar.center.x, self.sliderBackground.center.y);
     if (self.sliderBar.center.x < self.sliderBackground.frame.origin.x) {
         self.sliderBar.center = CGPointMake(self.sliderBackground.frame.origin.x, self.sliderBackground.center.y);
     }
     
     //调整双色背景
     firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);
}

- (CGFloat)progress
{
    CGFloat progress = (self.sliderBar.center.x-self.sliderBackground.frame.origin.x) / self.sliderBackground.frame.size.width;
    return progress;
}

- (void)setProgress:(CGFloat)progress
{
    self.sliderBar.center = CGPointMake(progress * self.sliderBackground.frame.size.width + self.sliderBackground.frame.origin.x, self.sliderBackground.center.y) ;
}

- (NSString *)timeStringFromFloat:(CGFloat)time
{
    //wiimu
    //修改时间计算方式
    int min = (int)(time/60);
//    min = min%60;
    int sec = (int)time%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (int)calculateLabelWidth:(NSString *)string font:(UIFont *)font{
    NSDictionary *dic = @{NSFontAttributeName:font};
    int maxWidth = (int)50*WSCALE;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(maxWidth, 12) options:
                   NSStringDrawingTruncatesLastVisibleLine attributes:dic context:nil];
    return (int)rect.size.width + 2.0;
}

- (void)setTotalTime:(NSTimeInterval)totalTime
{
    _totalTime = totalTime;
    [self.rightTimeLabel setText:[self timeStringFromFloat:totalTime]];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = round(currentTime);
//    NSLog(@"ProgressSlider_currentTime = %f",_currentTime);
    if (_currentTime < 0)
    {
//        NSLog(@"ProgressSlider_currentTime为负值强制为0---%f",_currentTime);
        _currentTime = 0;
    }
    NSString *leftString = [self timeStringFromFloat:round(_currentTime)];
    [self.leftTimeLabel setText:leftString];
    
    if (fabs(self.totalTime-0) < FLT_EPSILON) {
        self.sliderBar.center = CGPointMake(self.sliderBackground.frame.origin.x, self.sliderBackground.center.y);
    }
    else {
        float centerX = (self.currentTime/self.totalTime)*self.sliderBackground.frame.size.width;
        if (centerX < 0)
        {
            centerX = 0;
        }
        self.sliderBar.center = CGPointMake(centerX+self.sliderBackground.frame.origin.x, self.sliderBackground.center.y);
    }
    firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);
    if(currentTime == 0) currentTime = -1;
}

- (void)play
{
    if (!self.sliderUpdateTimer || ![self.sliderUpdateTimer isValid]) {
        self.sliderUpdateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(runSlider) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.sliderUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stop
{
    [self.sliderUpdateTimer invalidate];
}

- (void)runSlider
{
    if (![_delegate currentPlayPauseState])
    {
        [self.sliderUpdateTimer invalidate];
    }

    if(_sliderLock == YES)
        return;
   
    //LiveRadio需要计时显示播放时长
    if ([_delegate respondsToSelector:@selector(currentPlayLiveRadioIsTiming)] && [_delegate currentPlayLiveRadioIsTiming]) {
        
        [self setProgress:0];
        self.currentTime += 1.0;
        [self.leftTimeLabel setText:[self timeStringFromFloat:round(self.currentTime)]];
        return;
    }
    
    if(self.totalTime == 0)
        return;
    
    if(self.totalTime <= self.currentTime)
    {
        [self setProgress:1];
        return;
    }
    
    self.currentTime += 1.0;
    CGFloat newProgress;
    if (fabs(self.totalTime-0) < FLT_EPSILON) {
        newProgress = 0;
    }
    else {
        newProgress = self.currentTime / self.totalTime;
        if (self.currentTime/self.totalTime < 0) {
            newProgress = 0;
        }
    }
    
    if (self.currentTime > self.totalTime) {
        newProgress = 1.0;
    }
    [self setProgress:newProgress];
    [self.leftTimeLabel setText:[self timeStringFromFloat:round(self.currentTime)]];
}

-(void)SlaveMaskNotify:(NSNotification *)notify
{
    int mask = [notify.object intValue];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(mask == 1)
        {
            self.currentTime = self.totalTime = 0;
            [self stop];
        }
        else
        {
            [self play];
        }
    });
}

- (void)setSliderBarWidth:(int)width
{
    if (width == 10) {
        
        if (self.sliderBar.frame.size.width == 10) {
            return;
        }
        
        self.sliderBar.frame = CGRectMake(0, 2, 10, 10);
        self.sliderBar.layer.masksToBounds = YES;
        self.sliderBar.layer.cornerRadius = 5;
        
    }else{
        
        if (self.sliderBar.frame.size.width == 4) {
            return;
        }
        
         self.sliderBar.frame = CGRectMake(0, 5, 4, 4);
         self.sliderBar.layer.masksToBounds = YES;
         self.sliderBar.layer.cornerRadius = 2;
    }
    
    self.sliderBar.center = CGPointMake(self.sliderBar.center.x, self.sliderBackground.center.y);
    if (self.sliderBar.center.x < self.sliderBackground.frame.origin.x) {
        self.sliderBar.center = CGPointMake(self.sliderBackground.frame.origin.x, self.sliderBackground.center.y);
    }
}

-(void)longPressAction:(UILongPressGestureRecognizer*)sender{

    if (sender.state == UIGestureRecognizerStateBegan) {
            
        [self setSliderBarWidth:10];
        
        NSLog(@"+++++++++++ began");
        
        
    }else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled){
        
        NSLog(@"+++++++++++ end");
        
        [self setSliderBarWidth:4];
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _sliderLock = NO;
        
        CGPoint touchPoint = [recognizer translationInView:self.sliderBar];
        [recognizer setTranslation:CGPointZero inView:self.sliderBar];
        touchPoint = [recognizer locationInView:self.sliderBar];
        
        CGFloat width = self.sliderBar.frame.size.width;
        CGFloat height = self.sliderBar.frame.size.height;
        
        if (touchPoint.x>-100&&touchPoint.x<width+100&&touchPoint.y>-20&&touchPoint.y<height+20) {
            _sliderLock = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(progressSliderProgressWillChange:)]) {
            [self.delegate progressSliderProgressWillChange:self];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (_sliderLock) {
            
            CGPoint transition = [recognizer translationInView:self.sliderBar];
            [recognizer setTranslation:CGPointZero inView:self.sliderBar];
            CGFloat newOffset = self.sliderBar.center.x + transition.x;
            newOffset = MIN(self.sliderBackground.frame.origin.x + self.sliderBackground.frame.size.width, newOffset);
            newOffset = MAX(self.sliderBackground.frame.origin.x, newOffset);
            self.sliderBar.center = CGPointMake(newOffset, self.sliderBar.center.y);
            
            firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        _sliderLock = NO;
        
        self.currentTime = self.progress * self.totalTime;
        
        if ([self.delegate respondsToSelector:@selector(progressSlider:progressDidChange:)]) {
            [self.delegate progressSlider:self progressDidChange:self.progress];
        }
    }
    else
    {
        _sliderLock = NO;
            
        self.currentTime = self.progress * self.totalTime;
        
        if ([self.delegate respondsToSelector:@selector(progressSlider:progressDidChange:)]) {
            [self.delegate progressSlider:self progressDidChange:self.progress];
        }
    }
}

@end
