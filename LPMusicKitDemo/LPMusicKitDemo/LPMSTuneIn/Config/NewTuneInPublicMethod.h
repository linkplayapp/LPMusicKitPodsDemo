//
//  NewTuneInPublicMethod.h
//  iMuzo
//
//  Created by lyr on 2019/4/24.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LPMSTuneIn/LPMSTuneIn.h>
#import "NewTuneInConfig.h"
#import <SDWebImage/SDWebImage.h>
#import "UIButton+LZCategory.h"

#import "NewTuneInNavigationBar.h"
#import "NewTuneInMenuView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewTuneInPublicMethod : NSObject

+ (NewTuneInPublicMethod *)shared;

- (void)startLocationCheck;

#pragma mark ------ Binding
- (void)bindingDeviceWithDeviceId:(NSString *)deviceId block:(void(^)(int ret))block;

- (void)updateCurrentBoxInfo;

- (void)updateCurrentBoxInfoWithUserInfo:(NSDictionary *)dict;

#pragma mark ------ Favorite

//缓存
- (void)addFavoriteWithId:(NSString *)Id;
- (void)removeFavoriteWithId:(NSString *)Id;
- (void)updateFavoriteWithDictionary:(NSMutableDictionary *)dictionary;
- (NSString *)selectFavoriteWithId:(NSString *)Id;

- (void)addToFavoritesWithTrackId:(NSString *)trackId block:(void(^)(int ret, NSString *message))block;
- (void)removeFromFavoritesWithTrackId:(NSString *)trackId block:(void(^)(int ret, NSString *message))block;
- (BOOL)checkFavoriteWithId:(NSString *)trackId;

#pragma mark ------ 通用
// 统一处理失败的返回结果
+ (NSString *)failureResultError:(NSError *)error;

+ (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor;

//正在播放
+ (BOOL)isCurrentPlayingPlayItem:(LPTuneInPlayItem *)playItem;

// 是否支持最爱
+ (BOOL)canFavoriteWithPlayItem:(LPTuneInPlayItem *)playItem;

//播放
+ (void)startPlayMusicWithPlayItem:(LPTuneInPlayItem *)playItem header:(LPTuneInPlayHeader *)header;

//计算含有描述的cell高度
+ (NSMutableDictionary *)dealDescriptionHeightWithPlayItem:(LPTuneInPlayItem *)playItem isOpenMore:(BOOL)openMore;

//加载图片
+ (UIImage *)imageNamed:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
