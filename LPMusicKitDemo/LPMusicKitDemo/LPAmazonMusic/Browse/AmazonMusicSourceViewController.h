//
//  AmazonMusicSourceViewController.h
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "BasicViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class LPAmazonMusicPlayHeader;
@class LPAmazonMusicPlayItem;

typedef NS_ENUM(NSInteger,AmazonMusicSourceCellType)
{
    AmazonMusic_Ablum_Type = 0,
    AmazonMusic_Songs_Type,
    AmazonMusic_PlayList_Type,
    AmazonMusic_Station_Type
};

@interface AmazonMusicSourceViewController : BasicViewController

@property (nonatomic, strong) LPAmazonMusicPlayHeader *playHeader;
@property (nonatomic, strong) LPAmazonMusicPlayItem *playItem;
@property (nonatomic, assign) AmazonMusicSourceCellType cellType;

@property (nonatomic, assign) BOOL isFromSearch;//是否来自搜索
@property (nonatomic, strong) NSDictionary *searchDictionary;//来自搜索的内容

@end

NS_ASSUME_NONNULL_END
