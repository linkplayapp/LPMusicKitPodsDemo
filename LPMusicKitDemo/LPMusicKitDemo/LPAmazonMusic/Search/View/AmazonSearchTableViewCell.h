//
//  AmazonSearchTableViewCell.h
//  iMuzo
//
//  Created by lyr on 2018/8/20.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPAmazonMusicPlayItem;
@class LPAmazonMusicPlayHeader;

typedef NS_ENUM(NSUInteger, tableViewCellType) {
    ArtistsType = 0,//正常的类型
    AlbumesType,
    SongsType,
    StationsType,
    PlaylistsType
};

typedef void (^buttonDidBlock)(int target);

@interface AmazonSearchTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView CellType:(NSString *)cellIdentifier;

@property (nonatomic, strong) LPAmazonMusicPlayItem *model;
@property (nonatomic, assign) tableViewCellType cellType;
@property (nonatomic, copy) buttonDidBlock block;

@end
