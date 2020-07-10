//
//  LPDefaulePlayView.m
//  muzoplayer
//
//  Created by lyr on 2020/7/3.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "LPDefaulePlayView.h"
#import "NSObject+FBKVOController.h"
#import "UIImageView+WebCache.h"
#import <LPMusicKit/LPDeviceManager.h>
#import <LPMusicKit/LPDeviceInfo.h>
#import <LPMusicKit/LPDevicePlayer.h>

#import "LPProgressSlider.h"
#import "LPVolumeSlider.h"
#import "LPBasicHeader.h"

//接收到固件的当前时间超过100H默认为0
#define LIVERADIO_TIME_OUT 360000

@interface LPDefaulePlayView ()<LPProgressSliderDelegate, LPVolumeSliderDelegate,LPSliderDatasource>
/**
 UI
 */
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *alphaImage;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIImageView *trackImage;

@property (weak, nonatomic) IBOutlet LPProgressSlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImage;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *loopModeButton;
@property (weak, nonatomic) IBOutlet UIButton *goAheadButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UIButton *playlistButton;
@property (weak, nonatomic) IBOutlet LPVolumeSlider *volumeSlider;

@property (weak, nonatomic) IBOutlet UIButton *deviceButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disMissButtonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceButtonBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackImageWidth;

/**
 AmazonMusci
 */
@property (weak, nonatomic) IBOutlet UIButton *thumbDownButton;
@property (weak, nonatomic) IBOutlet UIButton *thumbUpButton;

/**
 Content
 */
@property (nonatomic, assign) NSTimeInterval currentTime; /** 歌曲当前播放时间 */
@property (nonatomic, assign) NSTimeInterval totalTime; /** 歌曲总时间 */
@property (nonatomic, assign) BOOL progressUpdateLock;
@property (nonatomic,assign,getter = isPlaying) BOOL playing;/**是否在播放*/
@property (nonatomic, assign) BOOL skipButtonPressed;
@property (nonatomic, assign) CGFloat currentVolume;/**当前的音量*/

@end


@implementation LPDefaulePlayView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.trackImage.contentMode = UIViewContentModeScaleAspectFit;
    self.backImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backImage.clipsToBounds = YES;
    self.trackImage.clipsToBounds = YES;
    
    self.trackImage.layer.masksToBounds = YES;
    self.trackImage.layer.cornerRadius = 4;
    
    self.subTitleLabel.alpha = 0.5;
    self.trackImageWidth.constant = 308*WSCALE;
    
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
    [self insertSubview:effectView belowSubview:self.alphaImage];
   
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
    
    //loopmode
    [self.loopModeButton setImage:[self imageNamed:@"muzo_play_shunxu"] forState:UIControlStateNormal];
    
    //next
    [self.backButton setImage:[self imageNamed:@"muzo_play_next_n"] forState:UIControlStateNormal];
    [self.backButton setImage:[self imageNamed:@"muzo_play_next_d"] forState:UIControlStateHighlighted];
    
    //ahead
    [self.goAheadButton setImage:[self imageNamed:@"muzo_play_last_n"] forState:UIControlStateNormal];
    [self.goAheadButton setImage:[self imageNamed:@"muzo_play_last_d"] forState:UIControlStateHighlighted];
    
    //play
    [self.playButton setImage:[self imageNamed:@"muzo_play_playnow_n"] forState:UIControlStateNormal];
    [self.playButton setImage:[self imageNamed:@"muzo_play_playnow_d"] forState:UIControlStateSelected];
    
    //favorite
    [self.favoriteButton setImage:[self imageNamed:@"muzo_play_like_d"] forState:UIControlStateNormal];
    
    //thumb up
    [self.thumbUpButton setImage:[self imageNamed:@"muzo_playam_like_n"] forState:UIControlStateNormal];
    
    //thumb down
    [self.thumbDownButton setImage:[self imageNamed:@"muzo_playam_hate_n"] forState:UIControlStateNormal];
   
    self.trackNameLabel.text = self.subTitleLabel.text = @"";
    
    self.currentTime = self.totalTime = 0;
     self.deviceNameLabel.text = self.boxInfo.deviceStatus.friendlyName;
    
    self.progressSlider.frame = CGRectMake(18, CGRectGetMidX(self.trackImage.frame) + 2, SCREENWIDTH - 36, 30) ;
    self.volumeSlider.frame = CGRectMake(CGRectGetMaxX(self.soundButton.frame), CGRectGetMidX(self.soundButton.frame) + 12, SCREENWIDTH - CGRectGetMaxX(self.soundButton.frame)*2, 20);
}

///去除外面的手势
- (void)dealRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer swipeGestureRecognizer:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    [panGestureRecognizer requireGestureRecognizerToFail:self.progressSlider.panGestureRecognizer];
    [swipeGestureRecognizer requireGestureRecognizerToFail:self.progressSlider.panGestureRecognizer];
    
    [panGestureRecognizer requireGestureRecognizerToFail:self.volumeSlider.panGestureRecognizer];
    [swipeGestureRecognizer requireGestureRecognizerToFail:self.volumeSlider.panGestureRecognizer];
}

- (void)refreshUI
{
    self.progressSlider.frame = CGRectMake(18, CGRectGetMidX(self.trackImage.frame) + 2, SCREENWIDTH - 36, 30) ;
    self.volumeSlider.frame = CGRectMake(CGRectGetMaxX(self.soundButton.frame), CGRectGetMidX(self.soundButton.frame) + 12, SCREENWIDTH - CGRectGetMaxX(self.soundButton.frame)*2, 20);
}

- (void)refresState
{
    self.progressSlider.delegate = self;
    self.volumeSlider.delegate = self;
    self.volumeSlider.datasource = self;

    if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING)
    {
        [self setPlayMode:YES];
        [self updateProgressCurrent];
    }
    //            else if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PAUSED_PLAYBACK)
    //            {
    //                [weakSelf.progressSlider stop];
    //                [weakSelf setPlayMode:NO];
    //            }
    else if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_TRANSITIONING)
    {
        [self.progressSlider stop];
    }
    else
    {
        [self.progressSlider stop];
        if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_STOPPED)
        {
            [self tryLockProgressSlider];
            [self updateStoppedProgressSliderCurrentTime];
            [self performSelector:@selector(unlockProgressSlider) withObject:nil afterDelay:2.0];
        }
        [self setPlayMode:NO];
    }
    [self updateProgressEnabled];
    [self updateSomeButtonEnabled];
    
    [self KVO];
}

-(void)clean
{
    _progressSlider.delegate = nil;
    _volumeSlider.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.KVOController unobserveAll];
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
           NSString *source = weakSelf.boxInfo.mediaInfo.trackSource;
           
            if ([source isEqualToString:AMAZON_MUSIC_SOURCE]) {
                weakSelf.sourceImage.image = [self imageNamed:@"amazon-music-logo"];
            }else{
                weakSelf.sourceImage.image = [self imageNamed:@""];
            }
        });
    }];
    
//    //收藏
//    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"isFollowing" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self updateFavoriteStatus];
//        });
//    }];
    
    //歌曲当前时间
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"relativeTime" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"current time : %f    staut:%d", self.boxInfo.deviceStatus.relativeTime, self.boxInfo.deviceInfo.playStatus);
            
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
            
            if (self.boxInfo.deviceStatus.trackDuration == 0)
            {
                if (self.boxInfo.deviceStatus.relativeTime > 0 || weakSelf.progressSlider.totalTime > 0){
                    return ;
                }
            }
            
            if (weakSelf.progressSlider.totalTime == self.boxInfo.deviceStatus.trackDuration)
            {
                return ;
            }
            weakSelf.progressSlider.totalTime = self.boxInfo.deviceStatus.trackDuration;
            
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
//            else if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PAUSED_PLAYBACK)
//            {
//                [weakSelf.progressSlider stop];
//                [weakSelf setPlayMode:NO];
//            }
            else if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_TRANSITIONING)
            {
                [weakSelf.progressSlider stop];
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
    
    //loopmode
    [self.KVOController observe:self.boxInfo.deviceInfo keyPath:@"playMode" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateLoopMode:self.boxInfo.deviceInfo.playMode];
        });
    }];
    
    //friendlyName
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"friendlyName" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
             weakSelf.deviceNameLabel.text = weakSelf.boxInfo.deviceStatus.friendlyName;
        });
    }];
    
}

#pragma mark ------ Alert view
- (void)showAlertViewWithPlayError:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self.playViewcontroller presentViewController:alertController animated:YES completion:nil];
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
    self.subTitleLabel.text = self.boxInfo.mediaInfo.artist;
}

- (void)updateCoverImage:(NSString *)artworkUri {
 
    [self.trackImage sd_setImageWithURL:[NSURL URLWithString:artworkUri] placeholderImage:[self imageNamed:@"Group"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image == nil) {
            self.boxInfo.mediaInfo.artwork = [self imageNamed:@"Group"];
            self.backImage.image = [self imageNamed:@"NewTuneInBackImage"];
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
    }else{
        _progressSlider.currentTime = middleTimer >= self.boxInfo.deviceStatus.trackDuration?self.boxInfo.deviceStatus.trackDuration:middleTimer;
    }
}


#pragma mark ------ Volume Slider
- (void)volumeSlider:(LPVolumeSlider *)slider volumeIsChanging:(CGFloat)volume
{
    [[self.boxInfo getPlayer] setVolume:volume];
}

- (void)volumeSlider:(LPVolumeSlider *)slider volumeDidChange:(CGFloat)volume
{
    if (self.boxInfo.deviceStatus.volume != volume)
    {
        [[self.boxInfo getPlayer] setVolume:volume];
        self.currentVolume = volume;
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
- (void)progressSliderProgressWillChange:(LPProgressSlider *)slider
{
    [self tryLockProgressSlider];
}

- (void)progressSlider:(LPProgressSlider *)slider progressDidChange:(CGFloat)progress
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
    self.userInteractionEnabled = YES;
    
    self.backButton.enabled = prevEnabled;
    self.goAheadButton.enabled = nextEnabled;
    self.favoriteButton.enabled = favoriteEnabled;
    self.playButton.enabled = playEnabled;
    self.loopModeButton.enabled = stopEnabled;
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

-(void)updateLoopMode:(LPPlayMode)mode
{
    NSString * btImageName = nil;
    
    switch (mode)
    {
        case LP_LISTREPEAT:
            btImageName = @"muzo_play_shunxu";
            break;
        case LP_SINGLEREPEAT:
            btImageName = @"muzo_play_danqu";
            break;
        case LP_SHUFFLE:
            btImageName = @"muzo_play_suiji";
            break;
        case LP_SHUFFLEREPEAT:
            btImageName = @"muzo_play_suiji";
            break;
        case LP_DEFAULT:
            btImageName = @"muzo_play_shunxu";
            break;
        default:
            btImageName = @"muzo_play_shunxu";
            break;
    }

    UIImage *normalImage = [self imageNamed:btImageName];
    [self.loopModeButton setImage:normalImage forState:UIControlStateNormal];
}


#pragma mark ------ Button Action
- (IBAction)dismissButtonAction:(id)sender {
    
    [self clean];
    [self.playViewcontroller dismissViewControllerAnimated:YES];
}

- (IBAction)moreButtonAction:(id)sender {
    
}


- (IBAction)playButtonAction:(id)sender {
    
    if (self.isPlaying) {
        [[self.boxInfo getPlayer] pause:^(BOOL isSuccess, NSString * _Nullable result) {
        }];
        
        [self setPlayMode:NO];
        [self.progressSlider stop];
        
    }else{
        
        [[self.boxInfo getPlayer] play:^(BOOL isSuccess, NSString * _Nullable result) {
        }];
        
        [self.progressSlider play];
        [self setPlayMode:YES];
    }
}

- (IBAction)loopModeButtonAction:(id)sender {

    if(self.boxInfo.deviceInfo.playMode < LP_SHUFFLE)
    {
        int loopMode = ++self.boxInfo.deviceInfo.playMode;
        [[self.boxInfo getPlayer] setPlayMode:loopMode];
    }else{
        [[self.boxInfo getPlayer] setPlayMode:LP_LISTREPEAT];
    }
}

- (IBAction)backButtonAction:(id)sender {
    
    [[self.boxInfo getPlayer] next:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
    _skipButtonPressed = YES;
   
    self.boxInfo.deviceStatus.relativeTime = 0;
    self.progressSlider.progress = 0;
    [self updateCurrentTime];
        
    self.backButton.enabled = NO;
    self.goAheadButton.enabled = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateSomeButtonEnabled];
    });
}

- (IBAction)goAheadButtonAction:(id)sender {
    
    [[self.boxInfo getPlayer] previous:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
    
    self.boxInfo.deviceStatus.relativeTime = 0;
    self.progressSlider.progress = 0;
    [self updateCurrentTime];
           
    self.backButton.enabled = NO;
    self.goAheadButton.enabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateSomeButtonEnabled];
    });
}


- (IBAction)favoriteButtonAction:(id)sender {
    
   
    
    

    
}

- (IBAction)soundButtonAction:(id)sender {
    
    CGFloat volume = self.boxInfo.deviceStatus.volume;
    if (volume == 0) {
        [[self.boxInfo getPlayer] setVolume:self.currentVolume];
        self.volumeSlider.volume = self.currentVolume;
        [self.soundButton setImage:[self imageNamed:@"muzo_network_wifi_sound"] forState:UIControlStateNormal];
    }else{
        self.currentVolume = volume;
        [[self.boxInfo getPlayer] setVolume:0];
        self.volumeSlider.volume = 0;
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
  return [UIImage imageNamed:[NSString stringWithFormat:@"LPDefaultPlayView.bundle/%@", string]
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}
- (IBAction)thumbDownButtonAction:(id)sender {
    

}

- (IBAction)thumbUpButtonAction:(id)sender {
    

}

@end
