//
//  AmazonMusicMainTableViewCell.m
//  iMuzo
//
//  Created by 程龙 on 2018/12/6.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonMusicMainTableViewCell.h"
#import "AmazonMusicConfig.h"
#import "UIImageView+WebCache.h"

@interface AmazonMusicMainTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *titleImage;
@property (nonatomic, strong) UIImageView *lineImg;
@property (nonatomic, strong) UIImageView *nextImage;

@end

@implementation AmazonMusicMainTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"AmazonMusicMainTableViewCell";
    AmazonMusicMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[AmazonMusicMainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
        [self addAllControl];
    }
    return self;
}

- (void)addAllControl
{
    [self addSubview:self.titleImage];
    [self addSubview:self.titleLab];
    [self addSubview:self.lineImg];
    [self addSubview:self.nextImage];
    
    self.titleImage.frame = CGRectMake(16, (70 - 50)*WSCALE/2.0, 50*WSCALE, 50*WSCALE);
    self.titleLab.frame = CGRectMake(CGRectGetMaxX(self.titleImage.frame) + 10, 10, 200*WSCALE, 50*WSCALE);
    self.lineImg.frame = CGRectMake(10, 70*WSCALE - 1, SCREENWIDTH - 20, 1);
    self.nextImage.frame = CGRectMake(SCREENWIDTH - 45 , (70*WSCALE - 15)/2.0, 20, 20);
}

- (void)setMode:(LPAmazonMusicPlayItem *)mode
{
    _mode = mode;
    [self.titleImage sd_setImageWithURL:[NSURL URLWithString:mode.trackImage] placeholderImage:[AmazonMusicMethod imageNamed:@"defaultArtwork"]];
    self.titleLab.text = mode.trackName;
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UIImageView *)titleImage
{
    if (!_titleImage)
    {
        _titleImage = [[UIImageView alloc] init];
        _titleImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _titleImage;
}

- (UIImageView *)lineImg
{
    if (!_lineImg)
    {
        _lineImg = [[UIImageView alloc] init];
        _lineImg.backgroundColor = HWCOLORA(255, 255, 255, 0.2);
        _lineImg.hidden = YES;
    }
    return _lineImg;
}

- (UIImageView *)nextImage
{
    if (!_nextImage)
    {
        _nextImage = [[UIImageView alloc] init];
        _nextImage.image = [AmazonMusicMethod imageNamed:@"am_devicelist_continue_n"];
        _nextImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _nextImage;
}


@end
