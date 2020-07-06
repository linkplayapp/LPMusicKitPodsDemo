//
//  LPPlayerViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/16.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPPlayerViewController.h"
#import "NSObject+FBKVOController.h"
#import <LPMusicKit/LPDeviceManager.h>
#import <LPMusicKit/LPDeviceInfo.h>
#import <LPMusicKit/LPDevicePlayer.h>
#import "UIImageView+WebCache.h"
#define COVER_TRANSFORM_SPEED 1.0
#define COVER_TRANSFORM_TIME 200000.0

@interface LPPlayerViewController ()

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) NSTimeInterval currentTime; /** 歌曲当前播放时间 */
@property (nonatomic, assign) NSTimeInterval totalTime; /** 歌曲总时间 */
@property (nonatomic, retain) NSTimer *sliderUpdateTimer;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *voiceProgressBar;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *alphaImage;
@property (weak, nonatomic) IBOutlet UIButton *amazonMusicThumUp;
@property (weak, nonatomic) IBOutlet UIButton *amazonMusicThumDown;

@end

@implementation LPPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //模糊处理
     UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
     UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
     effectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
     [self.view insertSubview:effectView belowSubview:self.alphaImage];
    
    self.currentTime = self.totalTime = 0;
    self.coverImage.layer.masksToBounds = YES;
    self.coverImage.layer.cornerRadius = 120;
    self.previousButton.imageView.contentMode = self.nextButton.imageView.contentMode = self.playButton.imageView.contentMode =UIViewContentModeScaleAspectFit;
    
    [self KVO];
}

- (void)KVO {
    
    __weak typeof(self) weakSelf = self;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
    // 歌名 歌手
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
    //音源
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"trackSource" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updatePlayerTrackSource];
        });
    }];
    
    //收藏
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"isFollowing" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
                [self updateFavoriteStatus];
        });
    }];
    
    // 歌曲当前时间
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"relativeTime" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            if(weakSelf.progressUpdateLock == NO)
            {
                [weakSelf updateCurrentTime];
            }
        });
    }];
    // 歌曲总时间
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"trackDuration" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.totalTime = weakSelf.boxInfo.deviceStatus.trackDuration;
            [weakSelf.totalTimeLabel setText:[weakSelf timeStringFromFloat:weakSelf.boxInfo.deviceStatus.trackDuration]];
//            [weakSelf updateProgressEnabled];
        });
    }];
    
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"volume" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateVolume];
        });
    }];
    
    
    [self.KVOController observe:self.boxInfo.deviceInfo keyPath:@"playStatus" options:options block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING)
            {
                [weakSelf setPlayModeInternal:YES];
                [weakSelf startTransformRecordView];
            }
            else if(weakSelf.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_TRANSITIONING)
            {
                // 缓冲
//                [weakSelf.progressSlider stop];
//                [weakSelf stopTransformRecordView];
            }
            else
            {
//                [weakSelf.progressSlider stop];
//                [weakSelf stopTransformRecordView];
                // 暂停
                if(weakSelf.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PAUSED_PLAYBACK)
                {
//                    [weakSelf tryLockProgressSlider];
//                    [weakSelf updateStoppedProgressSliderCurrentTime];
//                    [weakSelf performSelector:@selector(unlockProgressSlider) withObject:nil afterDelay:2.0];
                }
                [weakSelf setPlayModeInternal:NO];
                [weakSelf stopTransformRecordView];
            }
//            [weakSelf updateProgressEnabled];
//            [weakSelf updateHintToast];
        });
    }];
    
    
    //prime music 评级
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"ratingURI" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSString * mediaSource = self.boxInfo.mediaInfo.trackSource;
            if (![mediaSource isEqualToString:AMAZON_MUSIC_SOURCE])
            {
                if (!self.amazonMusicThumUp.isHidden){
                    self.amazonMusicThumUp.hidden = YES;
                    self.amazonMusicThumDown.hidden = YES;
                }
                return ;
            }

            NSString *url = self.boxInfo.mediaInfo.ratingURI;
            if (url.length == 0 )
            {
                if (!self.amazonMusicThumUp.isHidden)
                {
                    self.amazonMusicThumUp.hidden = YES;
                    self.amazonMusicThumDown.hidden = YES;
                }
                return ;
            }
        });
    }];
}


#pragma mark —————KVO—————
- (void)setPlayModeInternal:(BOOL)play
{
    if (play) {
        self.playing = YES;
        [self play];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else {
        self.playing = NO;
        [self stop];
        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

- (void)updatePlayerInformation {
    self.titleLabel.text = self.boxInfo.mediaInfo.title;
    self.artistLabel.text = self.boxInfo.mediaInfo.artist;
    
    if ([self.boxInfo.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]) {
        self.artistLabel.text = self.boxInfo.mediaInfo.subtitle;
    }
}

- (void)updateCurrentTime {
    NSTimeInterval tempTime = self.boxInfo.deviceStatus.relativeTime;
    NSLog(@"relativeTime = %f", tempTime);
//    if (self.currentTime <= self.boxInfo.deviceStatus.relativeTime)
    {
        self.currentTime = self.boxInfo.deviceStatus.relativeTime;
        self.currentTimeLabel.text = [self timeStringFromFloat:self.boxInfo.deviceStatus.relativeTime];
    }
}

- (void)updateCoverImage:(NSString *)artworkUri {
    
    [self.coverImage sd_setImageWithURL:[NSURL URLWithString:artworkUri] placeholderImage:[UIImage imageNamed:@"defaultcover"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image == nil) {
            self.boxInfo.mediaInfo.artwork = [UIImage imageNamed:@"defaultcover"];
            self.backImage.image = nil;
        }else {
            self.boxInfo.mediaInfo.artwork = image;
            self.backImage.image = image;
        }
    }];
}

- (void)updatePlayerTrackSource{
    if ([self.boxInfo.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]) {
        self.stopButton.hidden = NO;
        self.favoriteButton.hidden = NO;
        self.previousButton.enabled = NO;
        self.nextButton.enabled = NO;
    }else{
        self.stopButton.hidden = YES;
        self.favoriteButton.hidden = YES;
        self.previousButton.enabled = YES;
        self.nextButton.enabled = YES;
    }
}

- (void)updateFavoriteStatus
{
    BOOL isFollowing = self.boxInfo.mediaInfo.isFollowing;
    if (![self.boxInfo.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]){
        return;
    }
        
    if ( isFollowing){
        [self.favoriteButton setImage:[UIImage imageNamed:@"tunein_music_more_favorite_d"] forState:UIControlStateNormal];
    }else{
        [self.favoriteButton setImage:[UIImage imageNamed:@"tunein_music_more_favorite_n"] forState:UIControlStateNormal];
    }
}
- (void)updateVolume {
    self.voiceProgressBar.value = self.boxInfo.deviceStatus.volume;
}


- (NSString *)timeStringFromFloat:(CGFloat)time
{
    int min = (int)(time/60);
    int sec = (int)time%60;
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

#pragma mark —————动画—————
- (void)startTransformRecordView
{
    CABasicAnimation * animation = (CABasicAnimation *)[self.coverImage.layer animationForKey:@"covertransform"];
    if(!animation) {
        animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithDouble:0.0f];
        animation.toValue = [NSNumber numberWithDouble:(M_PI * 20000.0f)];
        animation.cumulative = YES;
        animation.speed = COVER_TRANSFORM_SPEED;
        animation.duration = COVER_TRANSFORM_TIME;
        animation.repeatCount = HUGE_VALF;
        [self.coverImage.layer addAnimation:animation forKey:@"covertransform"];
    }else {
        CABasicAnimation * animation = (CABasicAnimation *)[self.coverImage.layer animationForKey:@"covertransform"];
        NSNumber *currentAngle = nil;
        if(animation) {
            currentAngle = [self.coverImage.layer.presentationLayer valueForKeyPath:@"transform.rotation"];
            [self.coverImage.layer removeAllAnimations];
        }
        animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = currentAngle;
        animation.byValue = [NSNumber numberWithDouble:(M_PI * 20000.0f)];
        animation.cumulative = YES;
        animation.speed = COVER_TRANSFORM_SPEED;
        animation.duration = COVER_TRANSFORM_TIME;
        animation.repeatCount = HUGE_VALF;
        [self.coverImage.layer addAnimation:animation forKey:@"covertransform"];
        if(self.boxInfo.deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING) {
            self.coverImage.layer.speed = COVER_TRANSFORM_SPEED;
        }else {
            [self stopTransformRecordView];
        }
    }
}

- (void)stopTransformRecordView {
    CFTimeInterval pausedTime = [self.coverImage.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.coverImage.layer.speed = 0.0;
    self.coverImage.layer.timeOffset = pausedTime;
}

#pragma mark —————进度条—————

- (void)play{
    if (!self.sliderUpdateTimer || ![self.sliderUpdateTimer isValid]) {
        self.sliderUpdateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(runSlider) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.sliderUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stop {
    [self.sliderUpdateTimer invalidate];
}

- (void)runSlider {
    
    if ([self.boxInfo.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]){
        if (self.boxInfo.deviceStatus.trackDuration == 0) {
            [self setProgress:0];
            self.currentTime += 1.0;
            [self.currentTimeLabel setText:[self timeStringFromFloat:round(self.currentTime)]];
            return;
        }
    }
    
    if(self.totalTime == 0)
        return;
    
    if(self.totalTime <= self.currentTime)
    {
        [self setProgress:1];
        return;
    }
    self.currentTime += 1.0;
    CGFloat newProgress;
    if (fabs(self.totalTime-0) < FLT_EPSILON) {
        newProgress = 0;
    }
    else {
        newProgress = self.currentTime / self.totalTime;
        if (self.currentTime/self.totalTime < 0) {
            newProgress = 0;
        }
    }
    
    if (self.currentTime > self.totalTime) {
        newProgress = 1.0;
    }
    [self setProgress:newProgress];
    [self.currentTimeLabel setText:[self timeStringFromFloat:round(self.currentTime)]];
}

- (void)setProgress:(CGFloat)progress {
    self.progressBar.value = progress;
}

#pragma mark —————播放方法—————

- (IBAction)playButtonPress:(id)sender {
    if (self.playing) {
        [[self.boxInfo getPlayer] pause:^(BOOL isSuccess, NSString * _Nullable result) {
            
        }];
    }else {
        [[self.boxInfo getPlayer] play:^(BOOL isSuccess, NSString * _Nullable result) {
            
        }];
    }
}

- (IBAction)previousButtonPress:(id)sender {
    [[self.boxInfo getPlayer] previous:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
}
- (IBAction)nextButtonPress:(id)sender {
    [[self.boxInfo getPlayer] next:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
}

// 改变音箱的音量
- (IBAction)voiceProgressValueChange:(id)sender {
    UISlider *vocieSender = (UISlider *)sender;
    [[self.boxInfo getPlayer] setVolume:vocieSender.value];
}
// 改变歌曲进度条
- (IBAction)progressValueChange:(id)sender {
    UISlider *progressSender = (UISlider *)sender;
    NSTimeInterval progress = progressSender.value * self.boxInfo.deviceStatus.trackDuration;
    [[self.boxInfo getPlayer] setProgress:progress completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
        
    }];
}

- (IBAction)dismissButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)stopButtonAction:(id)sender {

    if (self.boxInfo.deviceInfo.playStatus != LP_PLAYER_STATE_PAUSED_PLAYBACK && self.boxInfo.deviceInfo.playStatus != LP_PLAYER_STATE_NO_MEDIA_PRESENT)
    {
        self.stopButton.userInteractionEnabled = NO;
        [[self.boxInfo getPlayer] stop:^(BOOL isSuccess, NSString * _Nullable result) {
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.stopButton.userInteractionEnabled = YES;
                 if (isSuccess) {
                     [self setPlayModeInternal:NO];
                 }
             });
        }];
    }
}

- (IBAction)favoriteButtonAction:(id)sender {
    
     self.favoriteButton.enabled = NO;
     BOOL isFollowing = self.boxInfo.mediaInfo.isFollowing;
     NSString *songId = self.boxInfo.mediaInfo.songId;
    
//     if (isFollowing)
//     {
//         LPTuneInRequest *request = [[LPTuneInRequest alloc] init];
//         [request tuneInDeleteFavoritesWithTrackId:songId success:^(NSArray * _Nonnull list) {
//
//             [self.view makeToast:@"tuneIn_Removed_Favorite_Successfully" duration:2 position:@"CSToastPositionCenter"];
//             [self.favoriteButton setImage:[UIImage imageNamed:@"tunein_music_more_favorite_n"] forState:UIControlStateNormal];
//             self.favoriteButton.enabled = YES;
//
//         } failure:^(NSError * _Nonnull error) {
//             [self.view makeToast:@"newtuneIn_Fail" duration:2 position:@"CSToastPositionCenter"];
//             self.favoriteButton.enabled = YES;
//         }];
//     }
//     else
//     {
//         LPTuneInRequest *request = [[LPTuneInRequest alloc] init];
//         [request tuneInAddFavoritesWithTrackId:songId success:^(NSArray * _Nonnull list) {
//             [self.view makeToast:@"newtuneIn_Favorites_Success" duration:2 position:@"CSToastPositionCenter"];
//             [self.favoriteButton setImage:[UIImage imageNamed:@"tunein_music_more_favorite_d"] forState:UIControlStateNormal];
//             self.favoriteButton.enabled = YES;
//
//         } failure:^(NSError * _Nonnull error) {
//             [self.view makeToast:@"newtuneIn_Fail" duration:2 position:@"CSToastPositionCenter"];
//             self.favoriteButton.enabled = YES;
//
//         }];
//     }
}
- (IBAction)amazonMusicThumDownAction:(id)sender {
    
//    NSDictionary *thumbInfo = [self thumbDictionary];
//    int thumbRating = [thumbInfo[@"thumbRating"] intValue];
//    int trackTime = self.boxInfo.deviceStatus.relativeTime > 0 ? self.boxInfo.deviceStatus.relativeTime * 1000 : 1000;
//    NSString *newUrl = [NSString stringWithFormat:@"%@%@",thumbInfo[@"url"],thumbInfo[@"ratingURL"]];
//    [[AmazonMusicBoxManager shared] thumpDownOrUpState:thumbRating == 1 ? 0:1 position:trackTime deviceId:self.boxInfo.deviceStatus.UUID Url:newUrl Block:^(int ret, NSString * _Nonnull message) {
//        if (ret == 0){
//            [self setThumUpAndDownStatu:thumbRating == 1 ? 0:1];
//
//            if (thumbRating != 1) {
//                [[self.boxInfo getPlayer] next:^(BOOL isSuccess, NSString * _Nullable result) {
//
//                }];
//            }
//        }
//
//        if (message.length > 0) {
//            [self.view makeToast:message duration:2 position:@"CSToastPositionCenter"];
//        }
//    }];
}

- (IBAction)amazonMusicThumUpAction:(id)sender {
//    NSDictionary *thumbInfo = [self thumbDictionary];
//    int thumbRating = [thumbInfo[@"thumbRating"] intValue];
//    int trackTime = self.boxInfo.deviceStatus.relativeTime > 0 ? self.boxInfo.deviceStatus.relativeTime * 1000 : 1000;
//    NSString *newUrl = [NSString stringWithFormat:@"%@%@",thumbInfo[@"url"],thumbInfo[@"ratingURL"]];
//
//    [[AmazonMusicBoxManager shared] thumpDownOrUpState:thumbRating == 2 ? 0:2 position:trackTime deviceId:self.boxInfo.deviceStatus.UUID Url:newUrl Block:^(int ret, NSString * _Nonnull message) {
//        if (ret == 0){
//            [self setThumUpAndDownStatu:thumbRating == 2 ? 0:2];
//        }
//
//        if (message.length > 0) {
//            [self.view makeToast:message duration:2 position:@"CSToastPositionCenter"];
//        }
//    }];
}

- (void)requestStationThumbState:(NSString *)url
{
//    [[AmazonMusicBoxManager shared] getThumbStateWithUrl:url deviceId:self.boxInfo.deviceStatus.UUID block:^(int ret, int statu) {
//
//        if (ret == 0){
//            if (self.amazonMusicThumUp.isHidden){
//                self.amazonMusicThumUp.hidden = NO;
//                self.amazonMusicThumDown.hidden = NO;
//            }
//            [self setThumUpAndDownStatu:statu];
//
//        }else{
//            self.amazonMusicThumUp.hidden = YES;
//            self.amazonMusicThumDown.hidden = YES;
//        }
//    }];
}

//- (NSDictionary *)thumbDictionary
//{
//    return [AmazonMusicBoxManager shared].stationThumb;
//}

- (void)setThumUpAndDownStatu:(int)statu
{
    //0:no status 1.thumb down 2:thumb up
    if (statu == 2){
        [self.amazonMusicThumDown setImage:[UIImage imageNamed:@"amazonMusic_contra_n"] forState:UIControlStateNormal];
        [self.amazonMusicThumUp setImage:[UIImage imageNamed:@"amazonMusic_praise_d"] forState:UIControlStateNormal];
    }else if (statu == 1){
        [self.amazonMusicThumDown setImage:[UIImage imageNamed:@"amazonMusic_contra_d"] forState:UIControlStateNormal];
        [self.amazonMusicThumUp setImage:[UIImage imageNamed:@"amazonMusic_praise_n"] forState:UIControlStateNormal];
    }else{
        [self.amazonMusicThumDown setImage:[UIImage imageNamed:@"amazonMusic_contra_n"] forState:UIControlStateNormal];
        [self.amazonMusicThumUp setImage:[UIImage imageNamed:@"amazonMusic_praise_n"] forState:UIControlStateNormal];
    }
}

// 获取当前操作的音箱对象
- (LPDevice *)boxInfo {
    return [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
}



@end
