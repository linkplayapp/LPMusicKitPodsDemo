//
//  NewTuneInMethod.m
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/2/17.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import "NewTuneInMethod.h"

@implementation NewTuneInMethod

NSString * tuneinCustomLocalizedString(NSString * key, NSString * language)
{
    if ([key length] == 0) {
        return key;
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"LPTuneIn" ofType:@"bundle"];
    NSBundle *localizableBundle = [NSBundle bundleWithPath:bundlePath];
    NSString * currentLan = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *newBundlePath = [localizableBundle pathForResource:[language length]!=0?language:currentLan ofType:@"lproj"];
    NSBundle * bundle = [NSBundle bundleWithPath:newBundlePath];
    
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    NSString * retStr = [bundle localizedStringForKey:key value:@"" table:nil];
    if ([retStr isEqualToString:@"IS_NULL_HOLDER"]) {
        return @"";
    }
    
    if (![retStr isEqualToString:key] && ![retStr isEqualToString:@""]) {
        return retStr;
    }
    NSUInteger underlineIndex = [key rangeOfString: @"_"].location;
    NSString * newKey = (underlineIndex!=NSNotFound && underlineIndex!=key.length-1)?[key substringFromIndex:underlineIndex+1]:nil;
    if (newKey)
    {
        retStr = [bundle localizedStringForKey:newKey value:@"" table:nil];
        if (![retStr isEqualToString:newKey] && ![retStr isEqualToString:@""]) {
            return retStr;
        }
    }
    return language?key:tuneinCustomLocalizedString(key, @"en");
}


//加载图片
+ (UIImage *)imageNamed:(NSString *)string
{
  return [UIImage imageNamed:[NSString stringWithFormat:@"LPTuneIn.bundle/%@", string]
    inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

+ (UIColor *)highColor
{
    return [UIColor colorWithRed:00/255.0 green:178/255.0 blue:142/255.0 alpha:1];
}

+ (UIColor *)defaultColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)lightColor
{
    return [UIColor lightGrayColor];
}

@end
