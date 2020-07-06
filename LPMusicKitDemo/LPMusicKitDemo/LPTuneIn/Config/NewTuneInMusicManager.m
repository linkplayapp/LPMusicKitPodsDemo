//
//  NewTuneInMusicManager.m
//  iMuzo
//
//  Created by lyr on 2019/5/23.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMusicManager.h"
#import "NewTuneInConfig.h"
#import "PresetViewController.h"
#import "TuneInPlayViewController.h"

@implementation NewTuneInMusicManager

+ (NewTuneInMusicManager *)shared
{
    static NewTuneInMusicManager *method = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        method = [[[self class] alloc] init];
    });
    return method;
}

-(id)init{
    if(self = [super init]){
    }
    return self;
}

- (void)initLPMSTuneInSDK
{
   //初始化绑定设备
    id<LPMediaSourceProtocol> deviceProtocal = [[LPMediaSourceAction alloc] init];

    //获取登录状态
    __weak typeof(self) weakSelf = self;
    if ([[LPMSTuneInManager sharedInstance] initTuneInDeviceActionObject:deviceProtocal]) {
        //获取登录状态
        [[LPMSTuneInManager sharedInstance] getTuneInAccountLoginStatus:^(BOOL isLogin, LPAccount * _Nonnull account) {
            weakSelf.isLogin = isLogin;
            weakSelf.account = account;
        }];
    }
}

- (void)updateDeviceId:(NSString *)deviceId
{
    self.deviceId = deviceId;
}

- (LPDevice *)getCurrentDevice
{
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
    return device;
}

- (NSString *)songId
{
    return [self getCurrentDevice].mediaInfo.songId;
}

- (NSString *)mediaSource
{
    return [self getCurrentDevice].mediaInfo.trackSource;
}

- (BOOL)isPlaying
{
    if ([self getCurrentDevice].deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING) {
        return YES;
    }
    return NO;
}

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

- (BOOL)isCurrentPlayingHeader:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    LPDevice *device = [self getCurrentDevice];
    if (playHeader && ![device.mediaInfo.trackSource isEqualToString:playHeader.mediaSource]) {
        return NO;
    }
    LPMediaInfo *mediaInfo = device.mediaInfo;
    LPTuneInPlayItem *playItem = playHeader.children[(int)index];
    
    if ([[mediaInfo.songId uppercaseString] isEqualToString:[playItem.trackId uppercaseString]])
    {
        return YES;
    }
    
    if (mediaInfo.songId.length ==0 || [mediaInfo.songId isEqualToString:@"0"]) {
        
        if ([mediaInfo.title isEqualToString:playItem.trackName]) {
            return YES;
        }
        return NO;
    }
    return NO;
}

//检查歌曲播放状态
- (BOOL)isHaveCurrentPlayingHeader:(LPTuneInPlayHeader *)playHeader
{
    LPDevice *device = [self getCurrentDevice];
    if (playHeader && ![device.mediaInfo.trackSource isEqualToString:playHeader.mediaSource]) {
        return NO;
    }
    LPMediaInfo *mediaInfo = device.mediaInfo;
    for (LPTuneInPlayItem *playItem in playHeader.children) {
            
       if ([[mediaInfo.songId uppercaseString] isEqualToString:[playItem.trackId uppercaseString]])
       {
           return YES;
       }
       
       if (mediaInfo.songId.length ==0 || [mediaInfo.songId isEqualToString:@"0"]) {
           
           if ([mediaInfo.title isEqualToString:playItem.trackName]) {
               return YES;
           }
           return NO;
       }
    }
    return NO;
}

- (BOOL)currentPlayIdIsChangeWithControllerName:(NSString *)name
{
    if (name.length == 0) {
        return NO;
    }
    
    LPDevice *device = [self getCurrentDevice];
    LPMediaInfo *mediaInfo = device.mediaInfo;
    
    NSString *logId = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    if (logId == nil) {
        
        NSString *currentId = [mediaInfo.songId uppercaseString];
        [[NSUserDefaults standardUserDefaults] setObject:currentId forKey:name];
        return YES;
    }
    else if (logId.length > 0) {
        
         NSString *currentId = [mediaInfo.songId uppercaseString];
         if ([currentId isEqualToString:logId])
         {
             return NO;
         }
         [[NSUserDefaults standardUserDefaults] setObject:currentId forKey:name];
         return YES;
    }
    return NO;
}

- (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor
{
    NSMutableAttributedString *attributedStr;
    attributedStr = [[NSMutableAttributedString alloc] initWithString:item ? item:@"" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:SYSTEMFONT(16)}];
    if (subLab.length == 0)
    {
        return attributedStr;
    }
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:SYSTEMFONT(16)}]];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:subLab attributes:@{NSForegroundColorAttributeName:subColor,NSFontAttributeName:SYSTEMFONT(14)}]];
    return attributedStr;
}

- (BOOL)isCanPresetWithModel:(LPTuneInPlayItem *)playItem
{
    if([GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource){
        return NO;
    }

    //缺少参数
    LPDevice *device = [self getCurrentDevice];
    LPDeviceStatus *deviceStatus = device.deviceStatus;
    NSString *supportPreset = deviceStatus ? deviceStatus.NewTuneInPreset:@"";
    if (![supportPreset isEqualToString:@"1"]) {
        return NO;
    }
    
    NSString *nextAction = playItem.nextAction;
    if ([nextAction isEqualToString:@"3"]) {
        return YES;
    }
    return NO;
}

- (void)startPlayHeader:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index Block:(void(^)(int ret, NSString *message))block
{
    if ([self isCurrentPlayingHeader:playHeader index:index]){
        block(0, @"");
        [self showPlayViewController];
        return;
    }
    
    LPPlayMusicList *musicList = [[LPPlayMusicList alloc] init];
    musicList.index = (int)index;
    musicList.header = playHeader;
    musicList.list = @[playHeader.children[index]];
    musicList.account = self.account;
    
    if ([GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource) {

        block(0, @"");

        if ([[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController respondsToSelector:@selector(alarmSourceLPPlayMusicList:)])
        {
            [[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController alarmSourceLPPlayMusicList:musicList];
        }

        [[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController.navigationController popToViewController:[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController animated:YES];
        return;
    }
    
    LPDevice *device = [self getCurrentDevice];;
    LPDevicePlayer *player = [device getPlayer];
    NSDictionary *playDict = [[LPMDPKitManager shared] playMusicSingleSource:musicList];
    
    //检查音响的状态
    [[LPMSTuneInManager sharedInstance] setTheOperationDeviceWithUUID:device.deviceInfo.soundBoxIdentity result:^(BOOL isSuccess, NSError * _Nonnull error) {
        
        if (isSuccess) {
            [player playAudioWithMusicDictionary:playDict completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
                
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
                message = TUNEINLOCALSTRING(@"newtuneIn_Time_out");
            }else{
                message = TUNEINLOCALSTRING(@"newtuneIn_Fail");
            }
            block(1, message);
        }
    }];
}

- (void)showPlayViewController{
    TuneInPlayViewController *controller = [[TuneInPlayViewController alloc] init];
    controller.deviceId = self.deviceId;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *current = [self getCurrentVC];
    [current presentViewController:controller animated:YES completion:nil];
}

- (void )presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    LPTuneInPlayItem *playItem = playHeader.children[index];
    PresetViewController *controller = [[PresetViewController alloc] init];
    controller.deviceId = [[NewTuneInMusicManager shared] deviceId];
    controller.header = playHeader;
    controller.item = playItem;
    controller.isAddPreset = YES;
    controller.account = self.account;

    UIViewController *current = [self getCurrentVC];
    if ([current isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)current pushViewController:controller animated:YES];
        return;
    }
    [current.navigationController pushViewController:controller animated:YES];
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


//计算含有描述的cell高度
- (NSMutableDictionary *)dealDescriptionCellHeight:(LPTuneInPlayItem *)playItem isOpenMore:(BOOL)openMore
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

/**
 将UTC日期字符串转为本地时间字符串
 eg: 2017-10-25 02:07:39  -> 2017-10-25 10:07:39
 */
- (NSString *)getLocalDateFormateUTCDate:(NSString *)utcStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    NSDate *dateFormatted = [dateFormatter dateFromString:utcStr];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString ? dateString: utcStr;
}

//转换成时分秒
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return  [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}


@end
