//
//  CustomVolSlider.h
//  wAudioShare
//
//  Created by 赵帅 on 14-7-1.
//  Copyright (c) 2014年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPVolumeSlider;

typedef enum
{
    volicon_stereo,
    volicon_left,
    volicon_right,
    volicon_mute
    
}LPVolumeSliderIcon;


@protocol LPVolumeSliderDelegate <NSObject>

@required
- (void)volumeSlider:(LPVolumeSlider *)slider volumeDidChange:(CGFloat)volume;

@optional
- (void)volumeSliderVolumeWillChange:(LPVolumeSlider *)slider;
- (void)volumeSlider:(LPVolumeSlider *)slider volumeIsChanging:(CGFloat)volume;
- (void)volumeSlider:(LPVolumeSlider *)slider localVolumeIsChanging:(CGFloat)volume;

@end

@protocol LPSliderDatasource <NSObject>

- (LPVolumeSliderIcon)volumeSliderCurrentChannel;

@end

@interface LPVolumeSlider : UIView

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, retain) UIImageView *sliderBar;
@property (nonatomic, retain) UIImageView *sliderBackground;

@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, weak) id<LPVolumeSliderDelegate> delegate;
@property (nonatomic, weak) id<LPSliderDatasource> datasource;


@end
