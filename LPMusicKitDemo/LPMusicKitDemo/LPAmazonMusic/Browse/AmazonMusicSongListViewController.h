//
//  AmazonMusicSongListViewController.h
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "BasicViewController.h"
#import "AmazonMusicSongListViewController.h"

@class LPAmazonMusicPlayItem;
@class LPAmazonMusicPlayHeader;

NS_ASSUME_NONNULL_BEGIN

@interface AmazonMusicSongListViewController : BasicViewController

@property (nonatomic, strong) LPAmazonMusicPlayItem *playItem;
@property (nonatomic, strong) LPAmazonMusicPlayHeader *playHeader;

@property (nonatomic, assign) BOOL isFromSearch;//是否来自搜索
@property (nonatomic, assign) NSDictionary *searchDictionary;//来自搜索的内容

@end

NS_ASSUME_NONNULL_END
