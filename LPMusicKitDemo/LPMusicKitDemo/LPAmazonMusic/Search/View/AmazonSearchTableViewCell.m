//
//  AmazonSearchTableViewCell.m
//  iMuzo
//
//  Created by lyr on 2018/8/20.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonSearchTableViewCell.h"
#import "AmazonMusicConfig.h"
#import "UIImageView+WebCache.h"

@interface AmazonSearchTableViewCell ()

@property (nonatomic, strong) UIImageView *titleImage;
@property (nonatomic, strong) UIButton *saveBut;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *lineImg;
@property (nonatomic, strong) SDWebImageManager *downImageManager;
@property (nonatomic, strong) UIImageView *unlimiteView;

@end

@implementation AmazonSearchTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView CellType:(NSString *)cellIdentifier
{
    NSString *ID = cellIdentifier;
    AmazonSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AmazonSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
        [self addAllControl];
    }
    return self;
}

- (void)addAllControl{
    
    [self addSubview:self.titleImage];
    [self addSubview:self.titleLab];
    [self addSubview:self.lineImg];
    [self addSubview:self.unlimiteView];
    
    self.titleImage.frame = CGRectMake(14, (68-54)/2.0*WSCALE, 54*WSCALE, 54*WSCALE);
    self.titleLab.frame = CGRectMake(CGRectGetMaxX(self.titleImage.frame)+10, self.titleImage.frame.origin.y, SCREENWIDTH - 54*WSCALE - 74*WSCALE - 20 , 54*WSCALE);
    self.lineImg.frame = CGRectMake(10, 69*WSCALE, SCREENWIDTH - 20, 1*WSCALE);
    self.unlimiteView.frame = CGRectMake(SCREENWIDTH - 35 , (70*WSCALE - 15)/2.0, 20, 20);
}

#pragma mark all Action
- (void)selectButAction{
    if (_block) {
        _block(0);
    }
}

- (void)setModel:(LPAmazonMusicPlayItem *)model{
    _model = model;

    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:_model.trackImage] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            self.titleImage.image = image;
        }
    }];
    
    switch (self.cellType) {
        case ArtistsType:
        {
            self.titleImage.layer.cornerRadius = 54*WSCALE/2.0;
            self.titleImage.layer.masksToBounds = YES;
            self.saveBut.hidden = YES;
            self.titleLab.text = _model.trackName;
        }
            break;
        case AlbumesType:
        {
            self.titleImage.layer.masksToBounds = NO;
            [self setCellAllObject];
        }
            break;
        case SongsType:
        {
            self.titleImage.layer.masksToBounds = NO;
            if ([AmazonMusicBoxManager shared].isExplicit)
            {
                if (model.isExplicit)
                {
                    self.unlimiteView.hidden = YES;
                    [self setSongCellShowTitle];
                    return;
                }
            }
            [self setCellAllObject];
        }
            break;
        case StationsType:
        {
            self.titleImage.layer.masksToBounds = NO;
            self.titleLab.text = _model.trackName;
        }
            break;
        case PlaylistsType:
        {
            self.titleImage.layer.masksToBounds = NO;
            self.titleLab.text = _model.trackName;
        }
            break;
            
        default:
            break;
    }
}

- (void)setCellAllObject
{
    NSMutableAttributedString *attrnitamaStr;
    if (_model.subTitle.length == 0)
    {
        NSString *allStr =[NSString stringWithFormat:@"%@",_model.trackName];
        attrnitamaStr = [[NSMutableAttributedString alloc] initWithString:allStr];
    }else{
        NSString *allStr = [NSString stringWithFormat:@"%@\n%@",_model.trackName,_model.subTitle];
        attrnitamaStr = [[NSMutableAttributedString alloc] initWithString:allStr];
        [attrnitamaStr addAttribute:NSForegroundColorAttributeName
                              value:THEME_HIGH_COLOR                                  range:NSMakeRange(_model.trackName.length, _model.subTitle.length + 1)];
        [attrnitamaStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(_model.trackName.length, _model.subTitle.length)];
    }
    [self.titleLab setAttributedText:attrnitamaStr];
}

- (void)setSongCellShowTitle
{
    NSMutableAttributedString *attributedStr;
    attributedStr = [[NSMutableAttributedString alloc] initWithString:_model.trackName.length > 0 ? _model.trackName:@"" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    if (_model.subTitle.length == 0) {
        [self.titleLab setAttributedText:attributedStr];
        return;
    }
    
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:_model.subTitle.length > 0 ? _model.subTitle : @""  attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    [self.titleLab setAttributedText:attributedStr];
}

- (UIImageView *)titleImage
{
    if (!_titleImage) {
        _titleImage = [[UIImageView alloc] init];
        _titleImage.contentMode = UIViewContentModeScaleAspectFill;
        _titleImage.image = [AmazonMusicMethod imageNamed:@"defaultArtwork"];
    }
    return _titleImage;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.numberOfLines = 3;
    }
    return _titleLab;
}

- (UIButton *)saveBut
{
    if (!_saveBut) {
        _saveBut = [[UIButton alloc] init];
        [_saveBut addTarget:self action:@selector(selectButAction) forControlEvents:UIControlEventTouchUpInside];
        _saveBut.hidden = YES;
    }
    return _saveBut;
}

- (SDWebImageManager *)downImageManager
{
    if (!_downImageManager) {
        _downImageManager = [[SDWebImageManager alloc] init];
    }
    return _downImageManager;
}

- (UIImageView *)lineImg
{
    if (!_lineImg) {
        _lineImg = [[UIImageView alloc] init];
        _lineImg.backgroundColor = HWCOLORA(255, 255, 255, 0.2);
        _lineImg.hidden = YES;
    }
    return _lineImg;
}

- (UIImageView *)unlimiteView
{
    if (!_unlimiteView) {
        _unlimiteView = [[UIImageView alloc] init];
        _unlimiteView.image = [AmazonMusicMethod imageNamed:@"am_devicelist_continue_n"];
        _unlimiteView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _unlimiteView;
}


@end
