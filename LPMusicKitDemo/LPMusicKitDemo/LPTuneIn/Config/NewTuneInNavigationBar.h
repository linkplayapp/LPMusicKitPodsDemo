//
//  NewTuneInNavigationBar.h
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/2/16.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,NewTuneInNavButType)
{
    NavBut_Search = 0,
    NavBut_Setting,
    NavBut_Back
};

@protocol NewTuneInNavigationBarDelegate <NSObject>

- (void)selectMusicNavigationBar:(NewTuneInNavButType)type;

@end


@interface NewTuneInNavigationBar : NSObject

@property (weak,nonatomic) id<NewTuneInNavigationBarDelegate> delegate;

/*  添加search、setting按钮
 *  barViewHeight : button Height
 *  return: @[button]
 */
- (NSArray *)navigationButHeight:(NSInteger)barViewHeight;

- (NSArray *)navigationLeft;


@end

NS_ASSUME_NONNULL_END
