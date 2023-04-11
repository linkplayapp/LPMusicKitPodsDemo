//
//  NewTuneInPublicMethod.m
//  iMuzo
//
//  Created by lyr on 2019/4/24.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInPublicMethod.h"
#import <LPMusicKit/LPMusicKit.h>

#import "NewTuneInMainController.h"

#import <LPMSTuneIn/LPMSTuneIn.h>

@interface NewTuneInPublicMethod ()

@property (nonatomic, strong) NSMutableDictionary *favoriteDictionary;

@end

@implementation NewTuneInPublicMethod

+ (NewTuneInPublicMethod *)shared
{
    static NewTuneInPublicMethod *method = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        method = [[[self class] alloc] init];
    });
    return method;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self notifactionEvent];
    }
    return self;
}

- (void)notifactionEvent
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LPMSTuneInAccountChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTuneInTokenChanged:) name:LPMSTuneInAccountChangeNotification object:nil];
}

- (void)newTuneInTokenChanged:(NSNotification *)notification
{
    LPTuneInRequestType type = [notification.object intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (type == LP_TUNEIN_LOGOUT) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOCALSTRING(@"newtuneIn_Prompt") message:LOCALSTRING(@"newtuneIn_TuneIn_account_has_logout") delegate:self cancelButtonTitle:LOCALSTRING(@"newtuneIn_OK") otherButtonTitles:nil, nil];
            [alert show];
        }else if (type == LP_TUNEIN_ACCOUNT_CHANGE){
            
        }else if (type == LP_TUNEIN_PLAY_FAIL){
         
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOCALSTRING(@"newtuneIn_Prompt") message:LOCALSTRING(@"newtuneIn_Now_can__t_play_please_choose_others") delegate:self cancelButtonTitle:LOCALSTRING(@"newtuneIn_OK") otherButtonTitles:nil, nil];
            [alert show];
            
            CURBOX.deviceInfo.playStatus = LP_PLAYER_STATE_PAUSED_PLAYBACK;
            [CURBOX.getPlayer stop:nil];
        }
    });
}

- (void)startLocationCheck
{
    [[LPMSTuneInManager sharedInstance] tuneInStartLocation];
}

- (void)bindingDeviceWithDeviceId:(NSString *)deviceId block:(void(^)(int ret))block
{
    [[LPMSTuneInManager sharedInstance] bindingTuneInWithDevice:deviceId isNewCodeBase:NO block:^(LPTuneInRequestType result) {
        if (result == LP_TUNEIN_REQUEST_FAIL) {
            if (block) {
                block(1);
            }
        }else{
            if (block) {
                block(0);
            }
        }
    }];
}

- (void)updateCurrentBoxInfo
{
    NSString *uuid = CURBOX.deviceInfo.soundBoxIdentity;
    NSString *deviced = [LPMSTuneInManager sharedInstance].deviceId;
    
    //表示相同设备
    if ([uuid isEqualToString:deviced]) {
        return;
    }
    
    [self bindingDeviceWithDeviceId:uuid block:nil];
}

- (void)updateCurrentBoxInfoWithUserInfo:(NSDictionary *)dict
{
    [[LPMSTuneInManager sharedInstance] updateDeviceWithId:CURBOX.deviceInfo.soundBoxIdentity userInfo:dict];
}


#pragma mark ------ Favorite
- (void)addFavoriteWithId:(NSString *)Id
{
    if (Id == nil) {
        return;
    }
    [self.favoriteDictionary setObject:@"1" forKey:Id];
}

- (void)removeFavoriteWithId:(NSString *)Id
{
    if (Id == nil) {
        return;
    }
    [self.favoriteDictionary setObject:@"0" forKey:Id];
}

- (void)updateFavoriteWithDictionary:(NSMutableDictionary *)dictionary
{
    if (dictionary == nil) {
        return;
    }
    
    [self.favoriteDictionary removeAllObjects];
    [self.favoriteDictionary setDictionary:dictionary];
}

- (NSString *)selectFavoriteWithId:(NSString *)Id
{
    if (Id == nil) {
        return @"2";
    }
    
    NSString *state = [self.favoriteDictionary objectForKey:Id];
    if (state == nil) {
        return @"2";
    }else{
        return state;
    }
}

- (NSMutableDictionary *)favoriteDictionary
{
    if (!_favoriteDictionary) {
        _favoriteDictionary = [[NSMutableDictionary alloc] init];
    }
    return _favoriteDictionary;
}

- (void)addToFavoritesWithTrackId:(NSString *)trackId block:(void(^)(int ret, NSString *message))block
{
    LPTuneInRequest *request = [[LPTuneInRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [request lpTuneInAddFavoritesWithTrackId:trackId success:^(NSArray * _Nonnull list) {
        
        [weakSelf addFavoriteWithId:trackId];
        if (block) {
            block(0, LOCALSTRING(@"newtuneIn_Favorites_Success"));
        }
    } failure:^(NSError * _Nonnull error) {
       
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        if (block) {
            block(1, message);
        }
    }];
}

- (void)removeFromFavoritesWithTrackId:(NSString *)trackId block:(void(^)(int ret, NSString *message))block
{
    LPTuneInRequest *request = [[LPTuneInRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [request lpTuneInDeleteFavoritesWithTrackId:trackId success:^(NSArray * _Nonnull list) {
        
        [weakSelf removeFavoriteWithId:trackId];
        if (block) {
            block(0, LOCALSTRING(@"newtuneIn_Removed_Favorite_Successfully"));
        }
    } failure:^(NSError * _Nonnull error) {
       
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        if (block) {
            block(1, message);
        }
    }];
}

- (BOOL)checkFavoriteWithId:(NSString *)trackId
{
    NSString *remoteId = CURBOX.mediaInfo.songId;
    BOOL isFollowing = NO;
    if ([remoteId isEqualToString:trackId])
    {
        isFollowing = CURBOX.mediaInfo.isFollowing;
    }
    
    NSString *state = [[NewTuneInPublicMethod shared] selectFavoriteWithId:trackId];
    if (![state isEqualToString:@"2"]) {
        isFollowing = [state isEqualToString:@"1"] ? YES : NO;
    }
    
    return isFollowing;
}

#pragma mark ------ 通用
//加载图片
+ (UIImage *)imageNamed:(NSString *)string
{
  return [UIImage imageNamed:[NSString stringWithFormat:@"LPTuneIn.bundle/%@", string]
    inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

// 统一处理失败的返回结果
+ (NSString *)failureResultError:(NSError *)error
{
    if (error == nil)
    {
        return LOCALSTRING(@"newtuneIn_Fail");
    }
    
    NSInteger codes = error.code;
    if(codes == -1001)
    {
        return LOCALSTRING(@"newtuneIn_Time_out");
    }
    else if (codes == -1011)
    {
        return LOCALSTRING(@"newtuneIn_No_results");
    }
    else if (codes == 409)
    {
        NSString *errorMessage = error.userInfo[@"NSLocalizedDescription"];
        if (errorMessage.length > 0)
        {
            return errorMessage;
        }
    }
    return LOCALSTRING(@"newtuneIn_Fail");
}

+ (BOOL)isCurrentPlayingPlayItem:(LPTuneInPlayItem *)playItem
{
    if (CURBOX.deviceInfo.playStatus == LP_PLAYER_STATE_NO_MEDIA_PRESENT) {
        return NO;
    }
    NSString *songId = CURBOX.mediaInfo.songId;

    if (songId.length ==0 || [songId isEqualToString:@"0"]) {
        
        if ([CURBOX.mediaInfo.title isEqualToString:playItem.trackName] && [CURBOX.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]) {
            return YES;
        }
        return NO;
    }
    
    if ([[songId uppercaseString] isEqualToString:[playItem.trackId uppercaseString]])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)canFavoriteWithPlayItem:(LPTuneInPlayItem *)playItem
{
    return (playItem.Follow != nil) && [playItem.nextAction isEqualToString:@"3"];
}

//开始播放
+ (void)startPlayMusicWithPlayItem:(LPTuneInPlayItem *)playItem header:(LPTuneInPlayHeader *)header
{
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:CURBOX.deviceInfo.soundBoxIdentity];
    
    LPPlayMusicList * musicList = [[LPPlayMusicList alloc] init];
    musicList.account = [LPMSTuneInManager sharedInstance].account;
    musicList.header = header;
    header.searchUrl = header.children[0].trackUrl;
    musicList.playMode = LPMS_PLAYMODE_PLAYLIST;
    musicList.list = @[playItem];
    
    NSDictionary *info = [[LPMDPKitManager shared] playMusicSingleSource:musicList];
    [[device getPlayer] playAudioWithMusicDictionary:info completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
        if (isSuccess) {
        }
    }];
}

//计算含有描述的cell高度
+ (NSMutableDictionary *)dealDescriptionHeightWithPlayItem:(LPTuneInPlayItem *)playItem isOpenMore:(BOOL)openMore
{
    NSMutableDictionary *cellDict = [[NSMutableDictionary alloc] init];
    CGFloat height = 0;
   
    NSString *startTime = playItem.createTime;
    if (startTime.length > 0){
        startTime = [self getLocalDateFormateUTCDate:startTime];
    }else{
        startTime = playItem.Subtitle;
    }
    
    NSString *time;
    if (playItem.trackDuration > 0)
    {
        time = [NSString stringWithFormat:@"Time:%@",[self timeFormatted:playItem.trackDuration]];
    }

    [cellDict setValue:startTime forKey:@"startTime"];
    
    NSDictionary *present = playItem.Presentation;
    if ([present[@"Layout"] isEqualToString:@"OnDemandTile"])
    {
        height += 14;
        CGSize titleSize = [self sizeWithText:playItem.trackName font:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(SCREENWIDTH - 46, 44)];
        height = height + titleSize.height + 17 + 44 + 1;
       
        [cellDict setValue:@(titleSize.height + 1) forKey:@"titleHeight"];
        
        if (openMore)
        {
            NSString *description = [NSString stringWithFormat:@"%@\n\n%@",playItem.Description,time];
            CGSize detailSize = [self sizeWithText:description font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(SCREENWIDTH - 46, SCREENHEIGHT)];
            
            [cellDict setValue:@(detailSize.height + 1) forKey:@"durationHeight"];
            [cellDict setValue:description forKey:@"time"];
            
            height = height + detailSize.height + 1 + 10;
        }
        
        [cellDict setValue:@(height) forKey:@"height"];
    }
    else if (playItem.trackImage.length > 0)
    {
        [cellDict setValue:@(82) forKey:@"height"];
    }
    else
    {
        [cellDict setValue:@(50) forKey:@"height"];
    }
    return cellDict;
}

+ (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor
{
    NSMutableAttributedString *attributedStr;
    attributedStr = [[NSMutableAttributedString alloc] initWithString:item ? item:@"" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    if (subLab.length == 0)
    {
        return attributedStr;
    }
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:subLab attributes:@{NSForegroundColorAttributeName:subColor,NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    return attributedStr;
}

/**
 将UTC日期字符串转为本地时间字符串
 eg: 2017-10-25 02:07:39  -> 2017-10-25 10:07:39
 */
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    dateFormatter.locale = [NSLocale systemLocale];
    NSDate *dateFormatted = [dateFormatter dateFromString:utcStr];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString ? dateString: utcStr;
}

//转换成时分秒
+ (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return  [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
