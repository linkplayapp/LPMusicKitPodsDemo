//
//  FDProgressSlider.h
//  FreeDream
//
//  Created by Seewo on 13-9-10.
//  Copyright (c) 2013年 Seewo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPProgressSlider;

@protocol LPProgressSliderDelegate <NSObject>

@required
- (void)progressSlider:(LPProgressSlider *)slider progressDidChange:(CGFloat)progress;

@optional
- (void)progressSliderProgressWillChange:(LPProgressSlider *)slider;

- (BOOL)currentPlayPauseState;

//LiveRadio是否需要计时显示播放时长
- (BOOL)currentPlayLiveRadioIsTiming;

@end


@interface LPProgressSlider : UIView {
    BOOL _sliderLock;
}

@property (nonatomic, weak) id<LPProgressSliderDelegate> delegate;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, retain) UILabel *leftTimeLabel;
@property (nonatomic, retain) UILabel *rightTimeLabel;
@property (nonatomic, retain) UIImageView *sliderBar;
@property (nonatomic, retain) UIImageView *sliderBackground;
@property (nonatomic, retain) NSTimer *sliderUpdateTimer;

- (void)play;
- (void)stop;


@end
