//
//  CustomVolSlider.h
//  wAudioShare
//
//  Created by 赵帅 on 14-7-1.
//  Copyright (c) 2014年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TuneInVolumeSlider;

typedef enum
{
    volicon_stereo,
    volicon_left,
    volicon_right,
    volicon_mute
    
}TuneInVolumeSliderIcon;


@protocol TuneInVolumeSliderDelegate <NSObject>

@required
- (void)volumeSlider:(TuneInVolumeSlider *)slider volumeDidChange:(CGFloat)volume;

@optional
- (void)volumeSliderVolumeWillChange:(TuneInVolumeSlider *)slider;
- (void)volumeSlider:(TuneInVolumeSlider *)slider volumeIsChanging:(CGFloat)volume;
- (void)volumeSlider:(TuneInVolumeSlider *)slider localVolumeIsChanging:(CGFloat)volume;

@end

@protocol TuneInVolumeSliderDatasource <NSObject>

- (TuneInVolumeSliderIcon)volumeSliderCurrentChannel;

@end

@interface TuneInVolumeSlider : UIView

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, retain) UIImageView *sliderBar;
@property (nonatomic, retain) UIImageView *sliderBackground;

@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, weak) id<TuneInVolumeSliderDelegate> delegate;
@property (nonatomic, weak) id<TuneInVolumeSliderDatasource> datasource;


@end
