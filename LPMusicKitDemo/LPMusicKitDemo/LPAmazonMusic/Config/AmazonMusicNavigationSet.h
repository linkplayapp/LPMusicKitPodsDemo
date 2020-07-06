//
//  AmazonMusicNavigationBar.h
//  iMuzo
//
//  Created by 程龙 on 2018/12/12.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,AmazonMusicNavButType)
{
    NavBut_Search = 0,
    NavBut_Setting,
};

@protocol AmazonMusicNavigationBarDelegate <NSObject>

- (void)selectMusicNavigationBar:(AmazonMusicNavButType)type;

@end

@interface AmazonMusicNavigationSet : NSObject

@property (assign,nonatomic) id<AmazonMusicNavigationBarDelegate> delegate;

/*  添加search、setting按钮
 *  barViewHeight : button Height
 *  return: @[button]
 */
- (NSArray *)navigationButHeight:(NSInteger)barViewHeight;


@end


