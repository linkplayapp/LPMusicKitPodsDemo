//
//  NewTuneInMusicDetailHead.m
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMusicDetailHead.h"
#import "NewTuneInConfig.h"
#import <CoreText/CoreText.h>
#import <SDWebImage/SDWebImage.h>


@interface NewTuneInMusicDetailHead ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLab;
@property (weak, nonatomic) IBOutlet UIImageView *middleImage;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBut;
@property (weak, nonatomic) IBOutlet UIButton *playBut;
@property (weak, nonatomic) IBOutlet UIButton *middleMoreBut;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLab;
@property (weak, nonatomic) IBOutlet UILabel *middleMoreLab;
@property (weak, nonatomic) IBOutlet UIImageView *middleMoreImage;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DetailTextViewTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewHeightCon;
@property (nonatomic, strong) UIButton *detailBut;
@property (nonatomic, strong) UILabel *subDetailLab;
//不可播放
@property (nonatomic, strong) UILabel *noCanPlayLab;
//详情
@property (nonatomic, strong) UILabel *locationLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopIconCon;
@property (nonatomic, assign) LPPlayStatus playing_State;

@end

@implementation NewTuneInMusicDetailHead

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"NewTuneInMusicDetailHead" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionReusableView类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UIView class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
        
        self.frame = frame;
        
        [self setAllObject];
    }
    return self;
}

- (void)setAllObject
{
    self.iconImage.layer.masksToBounds = YES;
    self.iconImage.layer.cornerRadius = 4;
    self.iconImage.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    self.middleImage.layer.masksToBounds = YES;
    self.middleImage.layer.cornerRadius = 25;
    self.middleImage.layer.borderWidth = 1;
    
    self.favoriteBut.backgroundColor = [UIColor clearColor];
    self.middleMoreBut.backgroundColor = [UIColor clearColor];
    
    self.favoriteImage.image = [UIImage imageNamed:@"tunein_favorites_title_n"];
    self.favoriteLab.text = LOCALSTRING(@"newtuneIn_Favorite");
    
    self.middleMoreLab.text = LOCALSTRING(@"newtuneIn_more");
 
    self.middleMoreImage.image = [UIImage imageNamed:@"tunein_details_mores_n"];
    self.middleImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.favoriteLab.textColor = [UIColor lightGrayColor];
    self.middleMoreLab.textColor = [UIColor lightGrayColor];

    [self setPlayButImage:[UIImage imageNamed:@"tunein_play_n"] forState:UIControlStateNormal];

    self.detailLab.backgroundColor = [UIColor clearColor];
    self.detailLab.font = [UIFont systemFontOfSize:14];
    self.detailLab.textColor = [UIColor whiteColor];
}

- (UILabel *)subDetailLab
{
    if (!_subDetailLab) {
        _subDetailLab = [[UILabel alloc] init];
        _subDetailLab.backgroundColor = [UIColor clearColor];
        _subDetailLab.font = [UIFont systemFontOfSize:14];
        _subDetailLab.textColor = [UIColor whiteColor];
        _subDetailLab.numberOfLines = 3;
        _subDetailLab.hidden = YES;
    }
    return _subDetailLab;
}

-(void)setInfoMoreOpen:(BOOL)infoMoreOpen
{
    _infoMoreOpen = infoMoreOpen;
}

- (void)setDetailMoreOpen:(BOOL)detailMoreOpen
{
    _detailMoreOpen = detailMoreOpen;
}

- (void)setCurrentPlay:(BOOL)currentPlay
{
    _currentPlay = currentPlay;
}

- (void)setPlayItem:(LPTuneInPlayItem *)playItem
{
    _playItem = playItem;
    
    
    //标题
    self.titleLab.text = playItem.trackName;
    self.titleLab.font = [UIFont systemFontOfSize:18];
    self.titleLab.textColor = [UIColor whiteColor];
    CGSize titleSize = [self sizeWithText:[NSString stringWithFormat:@"%@", playItem.trackName] font:[UIFont systemFontOfSize:18] maxSize:CGSizeMake(SCREENWIDTH - 174, 78)];
    self.titleHeightCon.constant = titleSize.height + 1;
    self.titleTopIconCon.constant = (104 - 26 - titleSize.height - 1)/2.0;
    
    //图片
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[UIImage imageNamed:@"tunein_album_logo"]];

    //点赞
    self.subTitleLab.font = [UIFont systemFontOfSize:14];
    self.subTitleLab.textColor = [UIColor whiteColor];
    NSDictionary *follow = playItem.Follow;
    if (follow)
    {
        self.subTitleLab.text = follow[@"FollowText"];
    
        //是否收藏
        BOOL haveFollow = [follow[@"IsFollowing"] boolValue];
        if (haveFollow)
        {
            self.favoriteImage.image = [UIImage imageNamed:@"tunein_favorites_title_d"];
        }
        else
        {
            self.favoriteImage.image = [UIImage imageNamed:@"tunein_favorites_title_n"];
        }
    }
    
    if (self.infoMoreOpen)
    {
        self.locationLab.hidden = NO;
        NSDictionary *properties = playItem.Properties[@"Location"];
        self.locationLab.frame = CGRectMake(24, CGRectGetMaxY(self.middleImage.frame) + 24, SCREENWIDTH - 48, 20);
        NSString *location = properties[@"DisplayName"];
        self.locationLab.text = [NSString stringWithFormat:@"Location: %@",location.length > 0 ? location: @"No"];
        
        self.middleMoreLab.text = LOCALSTRING(@"newtuneIn_Less");
        self.middleMoreImage.image = [UIImage imageNamed:@"tunein_details_mores_d"];
    }
    else
    {
        self.middleMoreLab.text = LOCALSTRING(@"newtuneIn_more");
        self.locationLab.hidden = YES;
        self.middleMoreImage.image = [UIImage imageNamed:@"tunein_details_mores_n"];
    }
    
    self.middleMoreImage.tintColor = [UIColor lightGrayColor];
    
    if ([GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource)
    {
        self.playBut.enabled = NO;
    }
    else
    {
        self.playBut.enabled = YES;
    }
    
    //播放状态
    if (self.currentPlay) {
    
        if (CURBOX.deviceInfo.playStatus  == LP_PLAYER_STATE_PLAYING){
            
            [self stopActivity];
            [self setPlayButImage:[UIImage imageNamed:@"tunein_play_d"] forState:UIControlStateNormal];
            self.playing_State = LP_PLAYER_STATE_PLAYING;
            return;
        }else if (CURBOX.deviceInfo.playStatus  == LP_PLAYER_STATE_TRANSITIONING){
            
            [self startActivity];
            self.playing_State = LP_PLAYER_STATE_TRANSITIONING;
            return;
        }
    }
    
    [self stopActivity];
    [self setPlayButImage:[UIImage imageNamed:@"tunein_play_n"] forState:UIControlStateNormal];
    self.playing_State = LP_PLAYER_STATE_PAUSED_PLAYBACK;
}

- (void)setLocalPlayState:(NSString *)localPlayState
{
    _localPlayState = localPlayState;
}

- (void)setDict:(NSMutableDictionary *)dict
{
    _dict = dict;
   
    NSString *haveStr = dict[@"detail"];
    
    if (haveStr.length > 0)
    {
        self.detailLab.hidden = NO;
        if (self.infoMoreOpen)
        {
            int infoHeight = [dict[@"infoHeight"] intValue];
            self.DetailTextViewTopCon.constant = infoHeight;
        }
        else
        {
            self.DetailTextViewTopCon.constant = 18;
        }
        
        self.detailTextViewHeightCon.constant = [dict[@"detailHeight"] intValue] + 1;
        
        NSArray *lineArr = [self getLinesArrayInLabel:haveStr];
        self.detailLab.numberOfLines = 0;
        self.subDetailLab.hidden = YES;
        if (lineArr.count > 3 && !self.detailMoreOpen)
        {
            [self detailTextViewArr:lineArr Height:[dict[@"detailHeight"] intValue] + 1];
        }
        else
        {
            self.detailLab.text = haveStr;
        }
    }
    else
    {
         self.detailLab.hidden = YES;
    }
}

- (IBAction)favoriteButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(favoriteButtonAction:GuideId:)])
    {
        NSDictionary *action = self.playItem.Follow;
        if (action)
        {
            BOOL haveFav = [action[@"IsFollowing"] boolValue];
            [self.delegate favoriteButtonAction:haveFav GuideId:self.playItem.trackId];
        }
        else
        {
            [self.delegate favoriteButtonAction:NO GuideId:self.playItem.trackId];
        }
    }
}

- (IBAction)playButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playButtonActionIsCurrentPlay:)])
    {
        [self.delegate playButtonActionIsCurrentPlay:self.currentPlay];
    }
}

- (IBAction)middleMoreButtonAction:(id)sender
{
    self.infoMoreOpen = !self.infoMoreOpen;
    if ([self.delegate respondsToSelector:@selector(userInfoMoreOpen:DetailMoreOpen:)])
    {
        [self.delegate userInfoMoreOpen:self.infoMoreOpen DetailMoreOpen:self.detailMoreOpen];
    }
}

- (void)detailButAction
{
    self.detailMoreOpen = !self.detailMoreOpen;
    self.detailBut.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(userInfoMoreOpen:DetailMoreOpen:)])
    {
        [self.delegate userInfoMoreOpen:self.infoMoreOpen DetailMoreOpen:self.detailMoreOpen];
    }
}

- (void)detailTextViewArr:(NSArray *)lineArr Height:(CGFloat)height
{
    if([self.detailBut isDescendantOfView:self])
    {
        [self.detailBut removeFromSuperview];
    }
    
    if([self.subDetailLab isDescendantOfView:self])
    {
        [self.subDetailLab removeFromSuperview];
    }
    
    self.detailLab.text = @"";
    self.subDetailLab.hidden = NO;
    self.subDetailLab.text = [NSString stringWithFormat:@"%@%@%@", lineArr[0],lineArr[1],lineArr[2]];
    self.subDetailLab.frame = CGRectMake(0, 0, SCREENWIDTH - 26, height - 16);
    [self.detailLab addSubview:self.subDetailLab];
    
    self.detailBut.frame = CGRectMake(1, height - 16, 44, 16);
    self.detailBut.userInteractionEnabled = YES;
    self.detailLab.userInteractionEnabled = YES;
    self.detailBut.hidden = NO;
    
    self.detailBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.detailLab addSubview:self.detailBut];
}

- (UIButton *)detailBut
{
    if (!_detailBut) {
        _detailBut = [[UIButton alloc] init];
        [_detailBut setTitle:LOCALSTRING(@"newtuneIn_more") forState:UIControlStateNormal];
        
        [_detailBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _detailBut.backgroundColor = [UIColor clearColor];
        _detailBut.titleLabel.font = [UIFont systemFontOfSize:14];
        [_detailBut addTarget:self action:@selector(detailButAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailBut;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return  [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (NSArray *)getLinesArrayInLabel:(NSString *)str{

    NSString *text = str;
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    CGRect rect = CGRectMake(13, 100, SCREENWIDTH - 26, 100);
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        //NSLog(@"''''''''''''''''''%@",lineString);
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}

- (UILabel *)noCanPlayLab
{
    if (!_noCanPlayLab) {
        _noCanPlayLab = [[UILabel alloc] init];
        _noCanPlayLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        
        _noCanPlayLab.textAlignment = NSTextAlignmentCenter;
       _noCanPlayLab.textColor = HWCOLORA(80, 227, 194, 1);
       _noCanPlayLab.layer.borderColor = HWCOLORA(80, 227, 194, 1).CGColor;
        _noCanPlayLab.text = LOCALSTRING(@"newtuneIn_This_show_will_be_available_later__Please_come_back_then_");
        _noCanPlayLab.layer.borderWidth = 1;
        _noCanPlayLab.numberOfLines = 0;
        [self addSubview:_noCanPlayLab];
    }
    return _noCanPlayLab;
}

- (UILabel *)locationLab
{
    if (!_locationLab) {
        _locationLab = [[UILabel alloc] init];
        _locationLab.font = [UIFont systemFontOfSize:14];
        _locationLab.textColor = [UIColor whiteColor];
        _locationLab.textAlignment = NSTextAlignmentLeft;
        _locationLab.text = [NSString stringWithFormat:@"%@:",LOCALSTRING(@"newtuneIn_Location")];
        [self addSubview:_locationLab];
    }
    return _locationLab;
}

- (void)startActivity
{
    self.playBut.userInteractionEnabled = NO;
    [self.playBut setBackgroundImage:[UIImage imageNamed:@"tunein_play_bg"] forState:UIControlStateNormal];
    NSString *filePath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"play_transitioning" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *gif = [UIImage sd_imageWithGIFData:imageData];
    [self setPlayButImage:gif forState:UIControlStateNormal];
}

- (void)setPlayButImage:(UIImage *)image forState:(UIControlState)state{
    [self.playBut setImage:image forState:state];
    self.playBut.tintColor = [UIColor whiteColor];
}

- (void)stopActivity
{
    self.playBut.userInteractionEnabled = YES;
}


@end
