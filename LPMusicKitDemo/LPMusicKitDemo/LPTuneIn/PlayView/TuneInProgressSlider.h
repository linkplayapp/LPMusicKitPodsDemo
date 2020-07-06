//
//  FDProgressSlider.h
//  FreeDream
//
//  Created by Seewo on 13-9-10.
//  Copyright (c) 2013年 Seewo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TuneInProgressSlider;

@protocol TuneInProgressSliderDelegate <NSObject>

@required
- (void)progressSlider:(TuneInProgressSlider *)slider progressDidChange:(CGFloat)progress;

@optional
- (void)progressSliderProgressWillChange:(TuneInProgressSlider *)slider;

- (BOOL)currentPlayPauseState;

//LiveRadio是否需要计时显示播放时长
- (BOOL)currentPlayLiveRadioIsTiming;

@end


@interface TuneInProgressSlider : UIView {
    BOOL _sliderLock;
}

@property (nonatomic, weak) id<TuneInProgressSliderDelegate> delegate;

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
