//
//  AmazonMusicConfig.h
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#ifndef AmazonMusicConfig_h
#define AmazonMusicConfig_h

// 计算屏幕的尺寸
#define WSCALE SCREENWIDTH/375.0
#define HSCALE SCREENHEIGHT/667.0
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height

//判断是否是4寸屏
#define IS4InchScreen  (([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO)

//判断是否3.5寸屏
#define IS35InchScreen ([[UIScreen mainScreen] bounds].size.height <= 568)

//RGB
#define HWCOLORA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define HWCOLOR(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define STATUSBAR_HEIGHT  [[UIApplication sharedApplication] statusBarFrame].size.height;

#define NAVGATIN_HEIGH isIPhoneXMode ? 88 : 64

#define BOTTOM_PLAYVIEW_HEIGHT isIPhoneXMode ? 84 : 50

#define isIPhoneXMode \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})




#endif /* AmazonMusicConfig_h */
