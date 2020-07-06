//
//  AmazonMusicBoxManager.h
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LPMusicKit/LPMusicKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AmazonMusicBoxManager : NSObject

///当前账号信息
@property (nonatomic, strong) LPAmazonMusicAccount *account;

///当前的设备ID
@property (nonatomic, strong) NSString *deviceId;

///过滤音乐是否打开(设置页面)
@property (nonatomic, assign) BOOL isExplicit;

///用来记录歌曲的评级
@property (nonatomic, strong) NSDictionary *stationThumb;

+ (instancetype)shared;

/**
 初始化SDK
 */
- (void)initAmazonMuiscSDK;

/**
 更新当前设备ID
 */
- (void)updateDeviceId:(NSString *)deviceId;

/**
 当前设备
 */
- (LPDevice *)getCurrentDevice;
/**
 当前播放歌曲的id
 */
- (NSString *)songId;
/**
 当前播放的音源
 */
- (NSString *)mediaSource;
/**
 当前播放的Queue
 */
- (NSString *)currentQueue;
/**
 当前播放歌曲的标题
 */
- (NSString *)mediaTitle;
/**
 是否正在播放
 */
- (BOOL)isPlaying;
/**
 暂停播放
 */
- (void)sendPause;
/**
 开始播放
 */
- (void)sendPlay;
/**
 停止播放
 */
- (void)sendStop;
/**
 设置Explicit
 */
- (void)sendExplicitStateToBox:(int)retts block:(void(^)(int ret))block;
/**
 清空Explict
 */
- (void)clearExplicit;
/**
 当前歌曲是否正在播放
 */
- (BOOL)trackIsPlaying:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem;
/**
 开始播放
 */
- (void)startPlayHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem Block:(void(^)(int ret, NSString *message))block;
/**
 在指定设备播放
 */
- (void)playOtherDevice:(NSString *)uuid playHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem Block:(void(^)(int ret, NSString *message))block;
/**
 当前是否显示more
 */
- (BOOL)isShowMoreWithPlayItem:(LPAmazonMusicPlayItem *)playItem playHeader:(LPAmazonMusicPlayHeader *)playHeader;

/**
 音响退出登录
 */
- (void)boxLogOut:(void(^)(int ret, NSError *Result))block;
/**
 展示播放界面
 */
- (void)showPlayViewController;
/**
 获取评级状态
 */
- (void)getThumbStateWithUrl:(NSString *)url deviceId:(NSString *)deviceId  block:(void(^)(int ret, int statu))block;
/**
 发起评级
 */
- (void)thumpDownOrUpState:(int)state position:(int)position deviceId:(NSString *)deviceId Url:(NSString *)url Block:(void(^)(int ret, NSString *message))block;

/**
 添加到更多
 */
- (void)openMoreViewWithPlayHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem headerType:(LPHeaderType)headerType;


@end

NS_ASSUME_NONNULL_END
