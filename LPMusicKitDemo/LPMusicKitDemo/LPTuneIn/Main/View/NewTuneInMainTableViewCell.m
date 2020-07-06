//
//  NewTuneInMainTableViewCell.m
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMainTableViewCell.h"
#import "NewTuneInConfig.h"
#import "NewTuneInCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NewTuneInCollectionViewImageCell.h"

@interface NewTuneInMainTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) MainCollectionViewCellType type;

@end

@implementation NewTuneInMainTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView CellType:(NSString *)cellIdentifier type:(MainCollectionViewCellType)type
{
    NSString *ID = cellIdentifier;
    NewTuneInMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[NewTuneInMainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID type:type];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(MainCollectionViewCellType)type {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.type = type;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
        [self addAllControl];
    }
    return self;
}

- (void)addAllControl
{
    [self addSubview:self.collectionView];
}

- (void)setPlayHeader:(LPTuneInPlayHeader *)playHeader
{
    _playHeader = playHeader;
    [self.collectionView reloadData];
}

- (void)reloadLoad
{
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        if (self.type == Cell_image_title)
        {
            layout.minimumLineSpacing = 8;
            layout.minimumInteritemSpacing = 8;
            layout.itemSize = CGSizeMake(104, 145);
        }
        else
        {
            layout.minimumLineSpacing = 6;
            layout.minimumInteritemSpacing = 6;
            layout.itemSize = CGSizeMake(187, 95);
        }
        layout.sectionInset = UIEdgeInsetsMake(0, 22, 0, 22);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        if (self.type == Cell_image_title)
        {
             _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 145) collectionViewLayout:layout];
        }
        else
        {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 95) collectionViewLayout:layout];
        }
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;

        [_collectionView registerClass:[NewTuneInCollectionViewCell class] forCellWithReuseIdentifier:@"NewTuneInCollectionViewShowTitleCell"];
        [_collectionView registerClass:[NewTuneInCollectionViewImageCell class] forCellWithReuseIdentifier:@"NewTuneInCollectionViewShowImageCell"];
        
    }
    return _collectionView;
}

#pragma mark -- UICollectionViewDelegate && UICollectionDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *modelArr = self.playHeader.children;
    return modelArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == Cell_image_title)
    {
        NewTuneInCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewTuneInCollectionViewShowTitleCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        
        NSMutableArray *modelArr = self.playHeader.children;
        LPTuneInPlayItem *browseModel = modelArr[indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        [cell.image sd_setImageWithURL:[NSURL URLWithString:browseModel.trackImage] placeholderImage:[NewTuneInMethod imageNamed:@"tunein_album_logo"]];
        cell.title.font = [UIFont systemFontOfSize:14];
        
        LPTuneInPlayHeader *header = [[LPTuneInPlayHeader alloc] init];
        header.mediaSource = NEW_TUNEIN_SOURCE;
        if ([[NewTuneInMusicManager shared] isCurrentPlayingHeader:self.playHeader index:indexPath.row])
        {
            cell.title.textColor = HWCOLORA(80, 227, 194, 1);
        }
        else
        {
            cell.title.textColor = [UIColor whiteColor];
        }
        
        cell.title.text = browseModel.trackName;
        cell.title.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    else
    {
        NewTuneInCollectionViewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewTuneInCollectionViewShowImageCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        
        NSMutableArray *modelArr = self.playHeader.children;
        LPTuneInPlayItem *browseModel = modelArr[indexPath.row];
        cell.backgroundColor = [UIColor clearColor];
        
        NSDictionary *imageDict = browseModel.Properties ? browseModel.Properties[@"BrickImage"] :@{};
        NSString *path = imageDict[@"ImageUrl"];
        cell.image.contentMode = UIViewContentModeScaleAspectFit;
        [cell.image sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[NewTuneInMethod imageNamed:@"tunein_album_logo"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image)
            {
                cell.image.contentMode = UIViewContentModeScaleAspectFill;
                [cell.image setImage:image];
            }
        }];
        
        #ifdef NEWTUNEIN_PRESENT_OPEN
        //是否可以预置
        __weak typeof(self) weakSelf = self;
        BOOL isCanPreset = [[NewTuneInMusicManager shared] isCanPresetWithModel:browseModel];
        if (isCanPreset)
        {
            cell.presentButton.hidden = NO;
            cell.block = ^{

                if (weakSelf.block) {
                    weakSelf.block(indexPath.row, 1);
                }
            };
        }
        else
        {
           cell.presentButton.hidden = YES;
        }
        #endif
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (_block) {
        _block(indexPath.row, 0);
    }
}


@end
