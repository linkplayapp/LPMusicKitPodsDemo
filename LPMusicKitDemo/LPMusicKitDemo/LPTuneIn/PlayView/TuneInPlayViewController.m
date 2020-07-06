//
//  TuneInPlayViewController.m
//  LPMDPKitDemo
//
//  Created by lyr on 2020/4/21.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import "TuneInPlayViewController.h"
#import "NewTuneInConfig.h"
#import "NSObject+FBKVOController.h"
#import "UIImageView+WebCache.h"
#import <LPMusicKit/LPDeviceManager.h>
#import <LPMusicKit/LPDeviceInfo.h>
#import <LPMusicKit/LPDevicePlayer.h>

#import "TuneInProgressSlider.h"
#import "TuneInVolumeSlider.h"

//接收到固件的当前时间超过100H默认为0
#define LIVERADIO_TIME_OUT 360000

@interface TuneInPlayViewController ()<TuneInProgressSliderDelegate, TuneInVolumeSliderDelegate,TuneInVolumeSliderDatasource>

/**
 UI
 */
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *alphaImage;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIImageView *trackImage;

@property (weak, nonatomic) IBOutlet TuneInProgressSlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImage;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *goAheadButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UIButton *playlistButton;
@property (weak, nonatomic) IBOutlet TuneInVolumeSlider *volumeSlider;


@property (weak, nonatomic) IBOutlet UIButton *deviceButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disMissButtonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceButtonBottom;

/**
 Content
 */
@property (nonatomic, assign) NSTimeInterval currentTime; /** 歌曲当前播放时间 */
@property (nonatomic, assign) NSTimeInterval totalTime; /** 歌曲总时间 */

@property (nonatomic, assign) BOOL progressUpdateLock;

@property (nonatomic,assign,getter = isPlaying) BOOL playing;

@property (nonatomic, assign) BOOL skipButtonPressed;



@end


@implementation TuneInPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackImage.contentMode = UIViewContentModeScaleAspectFit;
    self.backImage.contentMode = UIViewContentModeScaleAspectFill;
    self.trackImage.layer.masksToBounds = YES;
    self.trackImage.layer.cornerRadius = 4;
    
    //设置位置
    if (isIPhoneXMode) {
        self.disMissButtonTop.constant = 20 + 44;
        self.deviceButtonBottom.constant = 14 + 34;
    }else if(IS4InchScreen){
        self.disMissButtonTop.constant = 8;
        self.deviceButtonBottom.constant = 6;
    }else{
        self.disMissButtonTop.constant = 20;
        self.deviceButtonBottom.constant = 14;
    }
    
    //模糊处理
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    [self.view insertSubview:effectView belowSubview:self.alphaImage];
   
    //dissmiss
    [self.dismissButton setImage:[self imageNamed:@"muzo_play_back_n"] forState:UIControlStateNormal];
    //more
    [self.moreButton setImage:[self imageNamed:@"muzo_play_more_n"] forState:UIControlStateNormal];
    
    //device
    [self.deviceButton setImage:[self imageNamed:@"muzo_network_wifi_device"] forState:UIControlStateNormal];
    //sound
    [self.soundButton setImage:[self imageNamed:@"muzo_network_wifi_sound"] forState:UIControlStateNormal];
    //playlist
    [self.playlistButton setImage:[self imageNamed:@"muzo_network_wifi_playlist"] forState:UIControlStateNormal];
    
    //stop
    [self.stopButton setImage:[self imageNamed:@"muzo_play_stopnow_a"] forState:UIControlStateNormal];
    
    //back
    [self.backButton setImage:[self imageNamed:@"muzo_play_tunein_l30"] forState:UIControlStateNormal];
    //play
    [self.playButton setImage:[self imageNamed:@"muzo_play_playnow_n"] forState:UIControlStateNormal];
    [self.playButton setImage:[self imageNamed:@"muzo_play_playnow_d"] forState:UIControlStateSelected];
    
    //goahend
    [self.goAheadButton setImage:[self imageNamed:@"muzo_play_tunein_r30"] forState:UIControlStateNormal];
    //favorite
    [self.favoriteButton setImage:[self imageNamed:@"muzo_play_tunein_like"] forState:UIControlStateNormal];
    
    self.deviceNameLabel.text = self.boxInfo.deviceStatus.friendlyName;
    
    self.currentTime = self.totalTime = 0;
    
    self.progressSlider.delegate = self;
    self.progressSlider.frame = CGRectMake(18, CGRectGetMidX(self.trackImage.frame) + 2, SCREENWIDTH - 36, 30) ;
    
    self.volumeSlider.delegate = self;
    self.volumeSlider.datasource = self;
    self.volumeSlider.frame = CGRectMake(CGRectGetMaxX(self.soundButton.frame), CGRectGetMidX(self.soundButton.frame) + 12, SCREENWIDTH - CGRectGetMaxX(self.soundButton.frame)*2, 20);

    [self KVO];   
}

// 获取当前操作的音箱对象
- (LPDevice *)boxInfo {
    return [[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
}

- (void)KVO {
    
    __weak typeof(self) weakSelf = self;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
    //歌名 歌手
    [self.KVOController observe:self.boxInfo.mediaInfo keyPaths:@[@"title",@"artist",@"album"] options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updatePlayerInformation];
        });
    }];

    //专辑图
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"artworkUri" options:options block:^(id observer, id object, NSDictionary *change) {
        NSString * artworkUri = weakSelf.boxInfo.mediaInfo.artworkUri;
        artworkUri = [artworkUri isEqualToString:@"un_known"] ? @"" :artworkUri;
        [weakSelf updateCoverImage:artworkUri];
    }];
    
    //source
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"trackSource" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
           NSString * artworkUri = weakSelf.boxInfo.mediaInfo.trackSource;
           weakSelf.sourceImage.image = [NewTuneInMethod imageNamed:@"tunein_logo_login"];
        });
    }];
    
    //收藏
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"isFollowing" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFavoriteStatus];
        });
    }];
    
    //直播
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"isLive" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.progressUpdateLock == NO)
            {
                BOOL isLive = self.boxInfo.mediaInfo.isLive;
                if (isLive)
                {
                    weakSelf.progressSlider.totalTime = 0;
                    weakSelf.progressSlider.rightTimeLabel.text = TUNEINLOCALSTRING(@"newtuneIn_Live");
                }
               
                [self updateSomeButtonEnabled];
                [self updateProgressEnabled];
            }
        });
    }];
    
    
    //歌曲当前时间
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"relativeTime" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.progressUpdateLock == NO)
            {
               [weakSelf updateCurrentTime];
               [weakSelf updateProgressEnabled];
            }
        });
    }];
    // 歌曲总时间
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"trackDuration" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isLive = self.boxInfo.mediaInfo.isLive;
            if (isLive){
                weakSelf.progressSlider.totalTime = 0;
                weakSelf.progressSlider.leftTimeLabel.text = TUNEINLOCALSTRING(@"newtuneIn_Live");
            }else{
                if (self.boxInfo.deviceStatus.trackDuration == 0)
                {
                    if (self.boxInfo.deviceStatus.relativeTime > 0 || weakSelf.progressSlider.totalTime > 0){
                        return ;
                    }
                    return ;
                }
                
                if (weakSelf.progressSlider.totalTime == self.boxInfo.deviceStatus.trackDuration)
                {
                    return ;
                }
                weakSelf.progressSlider.totalTime = self.boxInfo.deviceStatus.trackDuration;
            }
            [self updateProgressEnabled];
        });
    }];
    
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"volume" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat volume = self.boxInfo.deviceStatus.volume;
            [weakSelf updateVolume:volume];
        });
    }];
    
    [self.KVOController observe:self.boxInfo.deviceInfo keyPath:@"playStatus" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING)
            {
                [weakSelf setPlayMode:YES];
                [weakSelf updateProgressCurrent];
            }
            else if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING)
            {
                [weakSelf.progressSlider stop];
                [weakSelf setPlayMode:NO];
            }
            else
            {
                [weakSelf.progressSlider stop];
                if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_STOPPED)
                {
                    //NSLog(@"---------------dmrState播放状态为Stopped");
                    [weakSelf tryLockProgressSlider];
                    [weakSelf updateStoppedProgressSliderCurrentTime];
                    [weakSelf performSelector:@selector(unlockProgressSlider) withObject:nil afterDelay:2.0];
                }
                [weakSelf setPlayMode:NO];
            }
            [weakSelf updateProgressEnabled];
            [weakSelf updateSomeButtonEnabled];
        });
    }];
    
    [self.KVOController observe:self.boxInfo.mediaInfo keyPaths:@[@"canPlay"] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{

            BOOL canPlay = self.boxInfo.mediaInfo.canPlay;
            NSString *songID = self.boxInfo.mediaInfo.songId;
            NSString *trackSource = self.boxInfo.mediaInfo.trackSource;

            if (![trackSource isEqualToString:NEW_TUNEIN_SOURCE]) {
                return ;
            }

            if (songID == nil || [songID isEqualToString:@"0"] || songID.length == 0) {
                return;
            }

            if (!canPlay)
            {
                BOOL isHaveSongId = [self isHaveAlertSongId:songID];
                if (isHaveSongId)
                {
                    return ;
                }
                
                [self showAlertViewWithPlayError:TUNEINLOCALSTRING(@"newtuneIn_Now_can__t_play_please_choose_others")];
                [weakSelf setPlayMode:NO];
                [weakSelf updateSomeButtonEnabled];
                [weakSelf updateProgressEnabled];
            }
            else
            {
                [self isHaveAlertSongId:@""];
            }
        });
    }];

    [self.KVOController observe:self.boxInfo.mediaInfo keyPaths:@[@"playErrorCode"] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *message = self.boxInfo.mediaInfo.playErrorMessage;
            NSString *code = self.boxInfo.mediaInfo.playErrorCode;
            NSString *songID = self.boxInfo.mediaInfo.songId;
            NSString *trackSource = self.boxInfo.mediaInfo.trackSource;

            if (![trackSource isEqualToString:NEW_TUNEIN_SOURCE]) {
                return ;
            }

            if (code == nil || code.length == 0 || [code isEqualToString:@"200"]) {
                return;
            }

            if (message.length > 0)
            {
                BOOL isHaveSongId = [self isHaveAlertSongId:songID];
                if (isHaveSongId)
                {
                    return ;
                }
                [self showAlertViewWithPlayError:TUNEINLOCALSTRING(@"newtuneIn_Now_can__t_play_please_choose_others")];
                [weakSelf setPlayMode:NO];
            }
        });
    }];
}

#pragma mark ------ Alert view
- (void)showAlertViewWithPlayError:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:TUNEINLOCALSTRING(@"newtuneIn_OK") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isHaveAlertSongId:(NSString *)songId
{
    NSString *ID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"alertViewErrorSongId"]] ;
    if (songId.length > 0 && [ID isEqualToString:songId])
    {
        [[NSUserDefaults standardUserDefaults] setObject:songId forKey:@"alertViewErrorSongId"];
        return YES;
    }
    else if (songId.length == 0 && ID.length == 0)
    {
        return NO;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:songId.length > 0 ? songId:@"" forKey:@"alertViewErrorSongId"];
        return NO;
    }
}

#pragma mark ------ Set Content
- (void)updatePlayerInformation {
    self.trackNameLabel.text = self.boxInfo.mediaInfo.title;
    self.subTitleLabel.text = self.boxInfo.mediaInfo.subtitle;
}

- (void)updateCoverImage:(NSString *)artworkUri {
 
    [self.trackImage sd_setImageWithURL:[NSURL URLWithString:artworkUri] placeholderImage:[NewTuneInMethod imageNamed:@"tunein_music_playnew"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image == nil) {
            self.boxInfo.mediaInfo.artwork = [NewTuneInMethod imageNamed:@"tunein_music_playnew"];
            self.backImage.image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
        }else {
            self.boxInfo.mediaInfo.artwork = image;
            self.backImage.image = image;
        }
    }];
}

- (void)updateFavoriteStatus
{
    BOOL isFollowing = self.boxInfo.mediaInfo.isFollowing;
    if (![self.boxInfo.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]){
        return;
    }
        
    if (isFollowing){
        [self.favoriteButton setImage:[self imageNamed:@"tunein_music_more_favorite_d"] forState:UIControlStateNormal];
    }else{
        [self.favoriteButton setImage:[self imageNamed:@"muzo_play_tunein_like"] forState:UIControlStateNormal];
    }
}


- (void)updateCurrentTime
{
    //非播放状态
    if (!self.isPlaying)
    {
        // 用tempTimer来接收当前时间，防止在处理逻辑的时候，又有新的事件过来
        NSTimeInterval tempTimer = self.boxInfo.deviceStatus.relativeTime >= self.boxInfo.deviceStatus.trackDuration?self.boxInfo.deviceStatus.trackDuration:self.boxInfo.deviceStatus.relativeTime;
        _progressSlider.currentTime = tempTimer;
        return;
    }
    
    NSTimeInterval middleTimer = self.boxInfo.deviceStatus.relativeTime;

    if (!_progressSlider.sliderUpdateTimer || ![_progressSlider.sliderUpdateTimer isValid])
    {
        [self updateProgressCurrent];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgressCurrent) object:nil];
    
//  获取固件返回当前时间  和 本地进度条时间 的 时间差
    float timeInterval = _progressSlider.currentTime - middleTimer;
    
//  如果本地进度条时间 和 固件返回时间差 在5秒，且当前时间！= 0，说明本地进度条快了，等等固件。 如果大于5秒，有可能是拖动进度条，需要响应。
//  本来本地进度条时间 如果大于固件返回时间，应该同步的，但是由于Spotify要求，则改为等待
    if(timeInterval <= 5 && timeInterval > 0 && middleTimer != 0)
    {
        [_progressSlider stop];
        [self performSelector:@selector(updateProgressCurrent) withObject:nil afterDelay:timeInterval];
    }else if (self.boxInfo.mediaInfo.isLive){
        _progressSlider.currentTime = middleTimer;
    }else{
        _progressSlider.currentTime = middleTimer >= self.boxInfo.deviceStatus.trackDuration?self.boxInfo.deviceStatus.trackDuration:middleTimer;
    }
}


#pragma mark ------ Volume Slider
- (void)volumeSlider:(TuneInVolumeSlider *)slider volumeIsChanging:(CGFloat)volume
{
    [[self.boxInfo getPlayer] setVolume:volume];
}

- (void)volumeSlider:(TuneInVolumeSlider *)slider volumeDidChange:(CGFloat)volume
{
    if (self.boxInfo.deviceStatus.volume != volume)
    {
        [[self.boxInfo getPlayer] setVolume:volume];
    }
}

- (void)updateVolume:(CGFloat)volume{
    if (volume == 0) {
        [self.soundButton setImage:[self imageNamed:@"muzo_play_volume_off"] forState:UIControlStateNormal];
    }else{
        [self.soundButton setImage:[self imageNamed:@"muzo_network_wifi_sound"] forState:UIControlStateNormal];
    }
    [self.volumeSlider setVolume:volume];
}


#pragma mark ------ Progress Slider
- (void)progressSliderProgressWillChange:(TuneInProgressSlider *)slider
{
    [self tryLockProgressSlider];
}

- (void)progressSlider:(TuneInProgressSlider *)slider progressDidChange:(CGFloat)progress
{
    [self.progressSlider stop];
    self.boxInfo.deviceInfo.playStatus = LP_PLAYER_STATE_TRANSITIONING;
    
    if(progress == 1)
    {
        [self tryLockProgressSlider];
        self.progressSlider.currentTime = 0;
    }
    
    LPDevicePlayer *player = [self.boxInfo getPlayer];
    if(progress >= 1)
    {
        [player play:^(BOOL isSuccess, NSString * _Nullable result) {
        }];
    }
    else
    {
        [player setProgress:progress*self.progressSlider.totalTime completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
            
        }];
    }
    
    //unlock progress slider after a short while
    [self performSelector:@selector(unlockProgressSlider) withObject:nil afterDelay:6.0];
}

- (BOOL)currentPlayPauseState
{
    return self.playing;
}

- (void)updateStoppedProgressSliderCurrentTime
{
    self.progressSlider.currentTime = 0;
}

-(void)tryLockProgressSlider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgressCurrent) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(unlockProgressSlider) object:nil];
    
    [self performSelector:@selector(lockProgressSlider) withObject:nil];
}

-(void)updateProgressCurrent
{
    if (self.boxInfo.mediaInfo.isLive && self.boxInfo.deviceStatus.relativeTime > LIVERADIO_TIME_OUT) {
        return;
    }
    [self.progressSlider play];
}

- (void)lockProgressSlider
{
    self.progressUpdateLock = YES;
}

- (void)unlockProgressSlider
{
    self.progressUpdateLock = NO;
}

//LiveRadio是否需要计时显示播放时长
- (BOOL)currentPlayLiveRadioIsTiming
{
    if (self.progressSlider.totalTime == 0 && self.boxInfo.deviceStatus.trackDuration == 0){
        return YES;
    }
    return self.boxInfo.mediaInfo.isLive;
}

//滑动条是否可用
-(void)updateProgressEnabled
{
    if(self.boxInfo.deviceInfo.playStatus != LP_PLAYER_STATE_PLAYING &&
       self.boxInfo.deviceInfo.playStatus != LP_PLAYER_STATE_PAUSED_PLAYBACK &&
       self.boxInfo.deviceInfo.playStatus != LP_PLAYER_STATE_TRANSITIONING)
    {
        self.progressSlider.userInteractionEnabled = NO;
        return;
    }

    if(self.boxInfo.deviceStatus.relativeTime + self.boxInfo.deviceStatus.trackDuration == 0)
    {
        self.progressSlider.userInteractionEnabled = NO;
        return;
    }

    if (!self.boxInfo.mediaInfo.canPlay)
    {
        self.progressSlider.userInteractionEnabled = NO;
        return;
    }

    if (self.boxInfo.mediaInfo.isLive)
    {
        self.progressSlider.userInteractionEnabled = NO;
        return;
    }
    self.progressSlider.userInteractionEnabled = YES;
}


#pragma mark ------ Button Enabled
-(void)updateSomeButtonEnabled
{
    BOOL prevEnabled = YES;
    BOOL nextEnabled = YES;
    BOOL favoriteEnabled = YES;
    BOOL playEnabled = YES;
    BOOL stopEnabled = YES;
 
    if (self.boxInfo.mediaInfo.songId != nil)
    {
        if (self.boxInfo.mediaInfo.canPlay)
        {
            prevEnabled = YES;
            nextEnabled = YES;
        }
        else
        {
            prevEnabled = NO;
            nextEnabled = NO;
            playEnabled = NO;
        }
        
        if (self.boxInfo.mediaInfo.isLive)
        {
            prevEnabled = NO;
            nextEnabled = NO;
        }
        else
        {
            prevEnabled = YES;
            nextEnabled = YES;
        }
    }

    if (self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_NO_MEDIA_PRESENT)
    {
        prevEnabled = NO;
        nextEnabled = NO;
        favoriteEnabled = NO;
        playEnabled = NO;
    }
    else if (self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_STOPPED)
    {
        prevEnabled = NO;
        nextEnabled = NO;
        favoriteEnabled = NO;
        stopEnabled = NO;
    }
    
    if (self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_TRANSITIONING)
    {
       self.playButton.userInteractionEnabled = NO;
       self.backButton.userInteractionEnabled = NO;
       self.goAheadButton.userInteractionEnabled = NO;
    }
    else
    {
        self.playButton.userInteractionEnabled = YES;
        self.backButton.userInteractionEnabled = YES;
        self.goAheadButton.userInteractionEnabled = YES;
    }
    
    self.backButton.enabled = prevEnabled;
    self.goAheadButton.enabled = nextEnabled;
    self.favoriteButton.enabled = favoriteEnabled;
    self.playButton.enabled = playEnabled;
    self.stopButton.enabled = stopEnabled;
}

#pragma mark ------ Play Status
- (void)setPlayMode:(BOOL)play
{
    if (self.skipButtonPressed && !play) {
        return;
    }
    [self setPlayModeInternal:play];
}

- (void)setPlayModeInternal:(BOOL)play
{
    if (play) {
        self.playing = YES;
        [self.playButton setImage:[self imageNamed:@"muzo_play_stopnow_n"] forState:UIControlStateNormal];
        [self.playButton setImage:[self imageNamed:@"muzo_play_stopnow_d"] forState:UIControlStateHighlighted];
    }
    else {
        self.playing = NO;
        [self.playButton setImage:[self imageNamed:@"muzo_play_playnow_n"] forState:UIControlStateNormal];
        [self.playButton setImage:[self imageNamed:@"muzo_play_playnow_d"] forState:UIControlStateHighlighted];
    }
}

#pragma mark ------ Button Action
- (IBAction)dismissButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)moreButtonAction:(id)sender {
    
}
- (IBAction)playButtonAction:(id)sender {
    
}
- (IBAction)stopButtonAction:(id)sender {
    
}
- (IBAction)backButtonAction:(id)sender {
    
}
- (IBAction)goAheadButtonAction:(id)sender {
}
- (IBAction)favoriteButtonAction:(id)sender {
    
}

- (IBAction)soundButtonAction:(id)sender {
    
    CGFloat volume = self.boxInfo.deviceStatus.volume;
    if (volume == 0) {
        [[self.boxInfo getPlayer] setVolume:50];
        [self.soundButton setImage:[self imageNamed:@"muzo_network_wifi_sound"] forState:UIControlStateNormal];
    }else{
        [[self.boxInfo getPlayer] setVolume:0];
        [self.soundButton setImage:[self imageNamed:@"muzo_play_volume_off"] forState:UIControlStateNormal];
    }
}
- (IBAction)playlistButtonAction:(id)sender {
}
- (IBAction)deviceButton:(id)sender {
}


//加载图片
- (UIImage *)imageNamed:(NSString *)string
{
  return [UIImage imageNamed:[NSString stringWithFormat:@"TuneInPlayView.bundle/%@", string]
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}


@end
