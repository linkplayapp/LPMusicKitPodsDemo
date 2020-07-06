//
//  NewTuneInMusicManager.h
//  iMuzo
//
//  Created by lyr on 2019/5/23.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresetSourceObj;

NS_ASSUME_NONNULL_BEGIN

@interface NewTuneInMusicManager : NSObject

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) LPAccount *account;
@property (nonatomic, strong) NSString *deviceId;

+ (NewTuneInMusicManager *)shared;

- (void)initLPMSTuneInSDK;

- (void)updateDeviceId:(NSString *)deviceId;

- (LPDevice *)getCurrentDevice;

- (NSString *)mediaSource;

- (NSString *)songId;

- (BOOL)isPlaying;

- (void)sendPlay;

- (void)sendPause;

- (void)showPlayViewController;

//检查歌曲是否正在播放
- (BOOL)isCurrentPlayingHeader:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index;

//是否含有正在播放歌曲
- (BOOL)isHaveCurrentPlayingHeader:(LPTuneInPlayHeader *)playHeader;

//开始播放
- (void)startPlayHeader:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index Block:(void(^)(int ret, NSString *message))block;

//是否可以预置
- (BOOL)isCanPresetWithModel:(LPTuneInPlayItem *)playItem;

//预置
- (void )presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index;

//计算含有描述的cell高度
- (NSMutableDictionary *)dealDescriptionCellHeight:(LPTuneInPlayItem *)playItem isOpenMore:(BOOL)openMore;

//定义标题
- (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor;

@end

NS_ASSUME_NONNULL_END
