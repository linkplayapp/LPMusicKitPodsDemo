//
//  AmazonMusicMethod.h
//  LPMDPKitDemo
//
//  Created by lyr on 2019/9/9.
//  Copyright © 2019年 Linkplay-jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define THEME_HIGH_COLOR [AmazonMusicMethod sharedInstance].highColor
#define THEME_DEFAULT_COLOR [AmazonMusicMethod sharedInstance].defaultColor
#define THEME_LIGHT_COLOR [AmazonMusicMethod sharedInstance].lightColor

@interface AmazonMusicMethod : NSObject

@property (nonatomic, readonly) UIColor * highColor;//高亮
@property (nonatomic, readonly) UIColor * defaultColor;//普通字色
@property (nonatomic, readonly) UIColor * lightColor;//浅色

///国际化
NSString * amazonMusicLocalizedString(NSString * string, NSString * comment);
#define AMAZONLOCALSTRING(string) amazonMusicLocalizedString(string, @"")

+ (AmazonMusicMethod *)sharedInstance;

+ (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor;

+ (UIImage *)imageNamed:(NSString *)string;

///show Explicit
- (void)showExplicitAlertView:(int)target isSetting:(BOOL)setting Block:(void(^)(int ret))block;

///show AlertView
- (void)showAlertRequestError:(NSDictionary *)alertDict Block:(void(^)(int ret, NSDictionary * result))block;

///open webview
- (void)openWebView:(NSString *)url;

///show toast
- (void)showToastView:(NSString *)message;

///Login Controller
- (void)switchRootIsLoginController;

///current window
- (UIViewController *)currentController;


@end

NS_ASSUME_NONNULL_END
