//  category: playview
//
//  CustomVolSlider.m
//  wAudioShare
//
//  Created by 赵帅 on 14-7-1.
//  Copyright (c) 2014年 wiimu. All rights reserved.
//

#import "TuneInVolumeSlider.h"
#import "AmazonMusicConfig.h"

@interface TuneInVolumeSlider()
<UIGestureRecognizerDelegate>
{
    UIImageView * firstPartBack;

    NSDate * lastChangingDate;
    float lastChangingVolume;
}

@end


@implementation TuneInVolumeSlider

- (void)awakeFromNib
{
    [super awakeFromNib];
     
    self.sliderBackground = [[UIImageView alloc] init];
    self.sliderBackground.backgroundColor = HWCOLORA(255, 255, 255, 0.2);
    [self addSubview:self.sliderBackground];
     
    //音量条背景
    firstPartBack = [[UIImageView alloc] init];
    firstPartBack.backgroundColor = HWCOLORA(255, 255, 255, 0.4);
    [self addSubview:firstPartBack];
    
    //
    self.sliderBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    self.sliderBar.backgroundColor = HWCOLORA(255, 255, 255, 1);
    self.sliderBar.layer.masksToBounds = YES;
    self.sliderBar.layer.cornerRadius = 7;
    [self addSubview:self.sliderBar];

     UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
     panGestureRecognizer.delegate = self;
     [self addGestureRecognizer:panGestureRecognizer];
     
     UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
     tapGestureRecognizer.delegate = self;
     [self addGestureRecognizer:tapGestureRecognizer];
     
     _enabled = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    int height = frame.size.height;
    int width = frame.size.width;
    
    [self.sliderBackground setFrame:CGRectMake(0, (height - 2)/2.0, width, 2)];
    if (self.sliderBar.center.x < self.sliderBackground.frame.origin.x) {
        self.sliderBar.center = CGPointMake(self.sliderBackground.frame.origin.x, self.sliderBar.center.y);
    }
    
    self.sliderBar.center = CGPointMake(self.sliderBar.center.x, self.sliderBackground.center.y);
    //调整双色背景
    firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);
}

- (CGFloat)volume
{
    CGFloat volume = (self.sliderBar.center.x-self.sliderBackground.frame.origin.x) / self.sliderBackground.frame.size.width;
    return volume*100;
}

- (void)setVolume:(CGFloat)volume
{
    self.sliderBar.center = CGPointMake(volume * self.sliderBackground.frame.size.width/100 + self.sliderBackground.frame.origin.x, self.sliderBackground.center.y);
    
    firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        return YES;
    }
    if(_enabled)
    {
        return YES;
    }
    
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        lastChangingDate = [NSDate date];
        lastChangingVolume = self.volume;
        
        if ([self.delegate respondsToSelector:@selector(volumeSliderVolumeWillChange:)]) {
            [self.delegate volumeSliderVolumeWillChange:self];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint transition = [recognizer translationInView:self.sliderBar];
        [recognizer setTranslation:CGPointZero inView:self.sliderBar];
        CGFloat newOffset = self.sliderBar.center.x + transition.x;
        newOffset = MIN(self.sliderBackground.frame.origin.x + self.sliderBackground.frame.size.width, newOffset);
        newOffset = MAX(self.sliderBackground.frame.origin.x, newOffset);
        self.sliderBar.center = CGPointMake(newOffset, self.sliderBar.center.y);
        
        firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);
    
        if ([[NSDate date] timeIntervalSinceDate:lastChangingDate] > 0.15)
        {
            lastChangingDate = [NSDate date];
            
            if (fabs(lastChangingVolume - self.volume) > 2)
            {
                lastChangingVolume = self.volume;
                
                NSLog(@"[lastChangingVolume] = %f",self.volume);
                
                if ([self.delegate respondsToSelector:@selector(volumeSlider:volumeIsChanging:)]) {
                    [self.delegate volumeSlider:self volumeIsChanging:self.volume];
                }
            }
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if ([self.delegate respondsToSelector:@selector(volumeSlider:volumeDidChange:)]) {
            [self.delegate volumeSlider:self volumeDidChange:self.volume];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(volumeSlider:volumeDidChange:)]) {
            [self.delegate volumeSlider:self volumeDidChange:self.volume];
        }
    }
}

-(void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(volumeSliderVolumeWillChange:)]) {
        [self.delegate volumeSliderVolumeWillChange:self];
    }
    
    CGPoint location = [recognizer locationInView:self];
    CGFloat newOffset = location.x;
    newOffset = MIN(self.sliderBackground.frame.origin.x + self.sliderBackground.frame.size.width, newOffset);
    newOffset = MAX(self.sliderBackground.frame.origin.x, newOffset);
    self.sliderBar.center = CGPointMake(newOffset, self.sliderBar.center.y);
    
    firstPartBack.frame = CGRectMake(self.sliderBackground.frame.origin.x, self.sliderBackground.frame.origin.y, self.sliderBar.center.x-self.sliderBackground.frame.origin.x, self.sliderBackground.frame.size.height);

    if ([self.delegate respondsToSelector:@selector(volumeSlider:volumeDidChange:)]) {
        [self.delegate volumeSlider:self volumeDidChange:self.volume];
    }
}

@end
