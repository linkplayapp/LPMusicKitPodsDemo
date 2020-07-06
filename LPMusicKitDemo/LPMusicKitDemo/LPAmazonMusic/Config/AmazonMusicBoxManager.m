//
//  AmazonMusicBoxManager.m
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicBoxManager.h"
#import <CommonCrypto/CommonCryptor.h>
#import "LPDefaultPlayViewController.h"

@implementation AmazonMusicBoxManager

+ (instancetype)shared{
    static AmazonMusicBoxManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[AmazonMusicBoxManager alloc] init];
    });
    return singleton;
}

- (instancetype)init
{
    if (self = [super init])
    {
        //监听设备状态变化
        [[NSNotificationCenter defaultCenter] removeObserver:self name:LPMSAmazonMusicAccountChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(amazonMusicDeviceInfoChanged:) name:LPMSAmazonMusicAccountChangeNotification object:nil];
    }
    return self;
}

/**
 初始化SDK
 */
- (void)initAmazonMuiscSDK
{
    //初始化绑定设备
    id<LPMediaSourceProtocol> deviceProtocal = [[LPMediaSourceAction alloc] init];

    //获取登录状态
    __weak typeof(self) weakSelf = self;
    if ([[LPMSAmazonMusicManager sharedInstance] initAmazonMusicDeviceActionObject:deviceProtocal]) {
        //获取登录状态
        [[LPMSAmazonMusicManager sharedInstance] getLPAmazonMusicAccountLoginStatus:^(int isLogin, LPAmazonMusicAccount * _Nonnull account) {
            weakSelf.account = account;
        }];
    }
}

- (void)updateDeviceId:(NSString *)deviceId
{
    self.deviceId = deviceId;
}

- (void)amazonMusicDeviceInfoChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dictioanry = notification.object;
        int statu = dictioanry[@"statu"] ? [dictioanry[@"statu"] intValue]: 0;
        if (statu == 0) {
            return;
        }

        LPAmazonMusicNetworkError *networkError = dictioanry[@"info"] ? (LPAmazonMusicNetworkError *)dictioanry[@"info"]: [[LPAmazonMusicNetworkError alloc] init];

        //log out
        if (statu == LP_ACCOUNT_NEEDS_TO_LOGIN_AGAIN){

            [self clearExplicit];
            self.account = nil;
            [[AmazonMusicMethod sharedInstance] switchRootIsLoginController];

         //Account used by other devices
         }else if (statu == LP_ACCOUNT_ALREADY_USED_ON_OTHER_DEVICES) {

            [self sendPause];
            [[AmazonMusicMethod sharedInstance] showAlertRequestError:networkError.alertDict Block:^(int ret, NSDictionary * _Nonnull result) {
                if (ret == 1) {

                    //request server
                    LPAmazonMusicNetwork *netWork = [[LPAmazonMusicNetwork alloc] init];
                    NSString *playUrl = networkError.alertDict[@"playUrl"];
                    [netWork keepPlayingMusicUrl:[NSString stringWithFormat:@"%@%@",playUrl,result[@"url"]] success:^(NSString *url, NSDictionary *response) {

                        [self sendPlay];

                    } failure:^(LPAmazonMusicNetworkError *error) {

                        [[AmazonMusicMethod sharedInstance] showToastView:AMAZONLOCALSTRING(@"primemusic_Fail")];
                    }];
                }else{
                    
                    [self sendPause];
                }
            }];
        //Need to buy membership
        }else if (statu == LP_ACCOUNT_NEEDS_TO_BE_PAID){

            [self sendStop];

            [[AmazonMusicMethod sharedInstance] showAlertRequestError:networkError.alertDict Block:^(int ret, NSDictionary * _Nonnull result) {
                if (ret == 1)
                {
                    [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
                }
            }];

        //play error
        }else if (statu == LP_ACCOUNT_PLAYBACK_ERROR){

            [self sendStop];

            [[AmazonMusicMethod sharedInstance] showAlertRequestError:networkError.alertDict Block:^(int ret, NSDictionary * _Nonnull result) {
                if (ret == 1)
                {
                    [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
                }
            }];
        }
    });
}

- (void)setAccount:(LPAmazonMusicAccount *)account
{
    _account = account;
}

#pragma mark ------ 设备信息
- (LPDevice *)getCurrentDevice
{
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
    return device;
}

- (NSString *)songId
{
    NSString *selectTrack = [[NSUserDefaults standardUserDefaults] objectForKey:@"HaveSelectTrackUsePlaying"];
    if (selectTrack && selectTrack.length > 0) {
        return selectTrack;
    }
    return [self getCurrentDevice].mediaInfo.songId;
}

- (NSString *)mediaSource
{
    return [self getCurrentDevice].mediaInfo.trackSource;
}

- (NSString *)currentQueue
{
    LPDeviceInfo *deviceInfo = [self getCurrentDevice].deviceInfo;
    return deviceInfo.currentQueue;
}

- (NSString *)mediaTitle
{
    return [self getCurrentDevice].mediaInfo.title;
}

- (BOOL)isPlaying
{
    if ([self getCurrentDevice].deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING){
        return YES;
    }
    return NO;
}

#pragma mark ------ 设备播放相关

- (void)sendPlay
{
    LPDevicePlayer *player = [[self getCurrentDevice] getPlayer];
    [player play:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
}

- (void)sendPause
{
    LPDevicePlayer *player = [[self getCurrentDevice] getPlayer];
    [player pause:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
}

- (void)sendStop
{
    LPDevicePlayer *player = [[self getCurrentDevice] getPlayer];
    [player stop:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
}

//当前歌曲是否正在播放
- (BOOL)trackIsPlaying:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem;
{
    //音源是否为AamazonMusic
    if (![[self mediaSource] isEqualToString:playHeader.mediaSource]) {
        return NO;
    }
    
    if (playItem.trackId.length > 0 && [playItem.trackId isEqualToString:@"0"])
    {
        if ([playItem.trackName isEqualToString:[self mediaTitle]]){
            
            if (![self isPlaying]) {
                [self sendPlay];
            }
            return YES;
        }
    }else if(playItem.trackUrl.length > 0){
        
        if ([playItem.trackId isEqualToString:[self songId]]) {
            if (![self isPlaying]) {
                [self sendPlay];
            }
            return YES;
            
        }else if ([[self currentQueue] isEqualToString:playItem.trackName]){
            
            if (![self isPlaying]) {
                [self sendPlay];
            }
            return YES;
        }
    }
    
    return NO;
}


- (void)playOtherDevice:(NSString *)uuid playHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem Block:(void(^)(int ret, NSString *message))block
{
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:uuid];
    LPDevicePlayer *player = [[LPDevicePlayer alloc] init];
    player = [device getPlayer];

    //拼接XML
    LPPlayMusicList *musicList = [[LPPlayMusicList alloc] init];
    musicList.index = (int)playItem.index;
    musicList.header = playHeader;
    musicList.list = @[playItem];
    NSDictionary *playDict = [[LPMDPKitManager shared] playMusicSingleSource:musicList];
    
    //指定播放的音响
    [[LPMSAmazonMusicManager sharedInstance] setTheOperationDeviceWithUUID:uuid explicitIsOpen:NO result:^(BOOL isSuccess, NSError * _Nonnull error) {
        
        if (isSuccess) {
            //开始播放
            [player playAudioWithMusicDictionary:playDict completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
                
                NSLog(@"start play: %@ isSuccess:%d", playDict, isSuccess);
                
                if(isSuccess){
                    block(0, @"");
                }else{
                    block(1, result);
                }
            }];
        }else{
            
            NSString *message;
            if (error.code == -1001) {
                message = AMAZONLOCALSTRING(@"primemusic_NO_Result");
            }else{
                message = AMAZONLOCALSTRING(@"primemusic_Fail");
            }
            block(1, message);
        }
    }];
}

/**
 当前是否显示more
 */
- (BOOL)isShowMoreWithPlayItem:(LPAmazonMusicPlayItem *)playItem playHeader:(LPAmazonMusicPlayHeader *)playHeader
{
    if (playHeader.headType != LP_HEADER_TYPE_SONG) {
        return NO;
    }
    
    if (playItem.playable && !playItem.navigation){
        return YES;
    }
    return NO;
}


//开始播放
- (void)startPlayHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem Block:(void(^)(int ret, NSString *message))block
{
    LPDevice *device = [self getCurrentDevice];
    LPDevicePlayer *player = [[LPDevicePlayer alloc] init];
    player = [device getPlayer];

    //拼接XML
    LPPlayMusicList *musicList = [[LPPlayMusicList alloc] init];
    musicList.index = (int)playItem.index;
    musicList.header = playHeader;
    musicList.list = @[playItem];
    NSDictionary *playDict = [[LPMDPKitManager shared] playMusicSingleSource:musicList];
    
    //指定播放的音响
    [[LPMSAmazonMusicManager sharedInstance] setTheOperationDeviceWithUUID:self.deviceId explicitIsOpen:NO result:^(BOOL isSuccess, NSError * _Nonnull error) {
        
        if (isSuccess) {
            
            //开始播放
            [player playAudioWithMusicDictionary:playDict completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
                
                NSLog(@"start play: %@ isSuccess:%d", playDict, isSuccess);
                
                if(isSuccess){
                    block(0, @"");
                    [self showPlayViewController];
                }else{
                    block(1, result);
                }
            }];
        }else{
            
            NSString *message;
            if (error.code == -1001) {
                message = AMAZONLOCALSTRING(@"primemusic_NO_Result");
            }else{
                message = AMAZONLOCALSTRING(@"primemusic_Fail");
            }
            block(1, message);
        }
    }];
}

//音响退出登录
- (void)boxLogOut:(void(^)(int ret, NSError *Result))block
{
    [[LPMSAmazonMusicManager sharedInstance] amazonMusicLogOut:^(int ret, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (ret == 0) {
                block(0, nil);
            }else{
                block(1, error);
            }
        });
    }];
}

#pragma mark ------ 音乐过滤
- (BOOL)isExplicit
{
    NSNumber *ret = [[NSUserDefaults standardUserDefaults] objectForKey:@"amazonMusicExplicit"];
    if (ret) {
        return [ret boolValue];
    }
    return NO;
}

- (void)sendExplicitStateToBox:(int)retts block:(void(^)(int ret))block;
{
    [[LPMSAmazonMusicManager sharedInstance] updateDeviceExplicitStatuWithUUID:self.deviceId isOpen:retts result:^(int ret, NSError * _Nonnull error) {
        
        if (ret == 0) {

            [[NSUserDefaults standardUserDefaults] setObject:@(retts) forKey:@"amazonMusicExplicit"];
            block(0);
        }else {

            block(1);
        }
    }];
}

- (void)clearExplicit
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"amazonMusicExplicit"];
}

#pragma mark ------ 展示播放界面
- (void)showPlayViewController{
    LPDefaultPlayViewController *controller = [[LPDefaultPlayViewController alloc] init];
    controller.deviceId = self.deviceId;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *current = [self getCurrentVC];
    [current presentViewController:controller animated:YES completion:nil];
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal)
            {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

#pragma mark ------ 音乐评级
- (void)getThumbStateWithUrl:(NSString *)url deviceId:(NSString *)deviceId block:(void(^)(int ret, int statu))block
{
    if(!self.account){
        block(1, 0);
        return;
    }

    self.stationThumb = @{@"url":url};
    LPAmazonMusicNetwork *network = [[LPAmazonMusicNetwork alloc] init];
    [network getStationsThumbStatu:url success:^(NSString *url, NSDictionary *response) {

        NSNumber *thumbRating = response[@"thumbRating"] ? response[@"thumbRating"]:@(0);
        NSString *ratingUrl = response[@"ratingURI"] ? response[@"ratingURI"]:@"";
        self.stationThumb = @{@"thumbRating":thumbRating,
                              @"ratingURL":ratingUrl,
                              @"url":url
                            };
        if (block){
            block(0, [thumbRating intValue]);
        }

    } failure:^(LPAmazonMusicNetworkError *error) {

        self.stationThumb = @{};
        if (block){
            block(1, 0);
        }
    }];
}

- (void)thumpDownOrUpState:(int)state position:(int)position deviceId:(NSString *)deviceId Url:(NSString *)url Block:(void(^)(int ret, NSString *message))block
{
    if(!self.account){
        block(1, 0);
        return;
    }

    LPAmazonMusicNetwork *network = [[LPAmazonMusicNetwork alloc] init];
    [network sendStationsThumbStatu:url thumbRating:state position:position success:^(NSString *url, NSDictionary *response) {

        NSMutableDictionary *dict = [self.stationThumb mutableCopy];
        [dict setValue:@(state) forKey:@"thumbRating"];
        self.stationThumb = dict;
        
        NSDictionary *resultDict = response[@"trackRatingResponses"] ? response[@"trackRatingResponses"][@"rating_response"]:@{};

        if (block){
          block(0, resultDict ? resultDict[@"message"]:@"");
        }
    } failure:^(LPAmazonMusicNetworkError *error) {
        if (block){
          block(1, error.message);
        }
    }];
}

/**
 添加到更多
 */
- (void)openMoreViewWithPlayHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem headerType:(LPHeaderType)headerType;
{

}

- (NSDictionary *)stationThumb
{
    if (!_stationThumb) {
        _stationThumb = [[NSDictionary alloc] init];
    }
    return _stationThumb;
}


@end
