//
//  LPLocalMusicViewController.h
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/13.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LPLocalMusicType) {
    LPLocalMusic_song = 0,
    LPLocalMusic_artist,
    LPLocalMusic_album,
    LPLocalMusic_songlist
};

NS_ASSUME_NONNULL_BEGIN

@interface LPLocalMusicViewController : UIViewController

@property (nonatomic, copy) NSString *uuid; /** 设备UUID */

@property (nonatomic, assign) LPLocalMusicType musicType; /** <#注释#> */

@end

NS_ASSUME_NONNULL_END
