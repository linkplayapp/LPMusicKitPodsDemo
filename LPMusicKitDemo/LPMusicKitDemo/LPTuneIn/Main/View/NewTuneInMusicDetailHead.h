//
//  NewTuneInMusicDetailHead.h
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NewTuneInMusicDetailHeadDelegate <NSObject>

- (void)userInfoMoreOpen:(BOOL)infoOpen DetailMoreOpen:(BOOL)detailOpen;

- (void)playButtonActionIsCurrentPlay:(BOOL)currentPlay;
- (void)favoriteButtonAction:(BOOL)favorite GuideId:(NSString *)guideId;

@end


@interface NewTuneInMusicDetailHead : UIView

@property (nonatomic, weak) id<NewTuneInMusicDetailHeadDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, assign) BOOL infoMoreOpen;
@property (nonatomic, assign) BOOL detailMoreOpen;
@property (nonatomic, assign) BOOL currentPlay;
@property (nonatomic, assign) BOOL playState;

@property (nonatomic, strong) NSString *localPlayState;
@property (nonatomic, strong) LPTuneInPlayItem *playItem;

@end

NS_ASSUME_NONNULL_END
