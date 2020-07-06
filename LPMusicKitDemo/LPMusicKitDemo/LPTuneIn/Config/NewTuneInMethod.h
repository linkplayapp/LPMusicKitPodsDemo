//
//  NewTuneInMethod.h
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/2/17.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define newTuneIn_HIGH_COLOR [NewTuneInMethod highColor]
#define newTuneIn_DEFAULT_COLOR [NewTuneInMethod defaultColor]
#define newTuneIn_LIGHT_COLOR [NewTuneInMethod lightColor]

@interface NewTuneInMethod : NSObject

//翻译
NSString *tuneinCustomLocalizedString(NSString * string, NSString * comment);
#define TUNEINLOCALSTRING(string) tuneinCustomLocalizedString(string, @"")

+ (UIColor *)highColor;//高亮

+ (UIColor *)defaultColor;//普通字色

+ (UIColor *)lightColor;//浅色

+ (UIImage *)imageNamed:(NSString *)string;//加载图片


@end

NS_ASSUME_NONNULL_END
