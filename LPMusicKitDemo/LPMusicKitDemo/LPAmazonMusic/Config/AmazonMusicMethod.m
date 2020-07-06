//
//  AmazonMusicMethod.m
//  LPMDPKitDemo
//
//  Created by lyr on 2019/9/9.
//  Copyright © 2019年 Linkplay-jack. All rights reserved.
//

#import "AmazonMusicMethod.h"
#import "AmazonMusicLoginController.h"
#import "AmazonMusicMainViewController.h"

@interface AmazonMusicMethod ()
{
    BOOL isVisibleAlert;//alert是否有效
    UIViewController *alertViewController;
}
@property (copy) void (^alertViewBlock)(int ret, NSDictionary * result);
@property (nonatomic, strong) NSDictionary *requestDict;

@end

@implementation AmazonMusicMethod

+ (instancetype)sharedInstance{
    static AmazonMusicMethod *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[AmazonMusicMethod alloc] init];
    });
    return singleton;
}

NSString * amazonMusicLocalizedString(NSString * key, NSString * language)
{
    if ([key length] == 0) {
        return key;
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"LPAmazonMusicUI" ofType:@"bundle"];
    NSBundle *localizableBundle = [NSBundle bundleWithPath:bundlePath];
    NSString * currentLan = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *newBundlePath = [localizableBundle pathForResource:[language length]!=0?language:currentLan ofType:@"lproj"];
    NSBundle * bundle = [NSBundle bundleWithPath:newBundlePath];
    
    if (bundle == nil) {
        newBundlePath = [localizableBundle pathForResource:@"en" ofType:@"lproj"];
        bundle = [NSBundle bundleWithPath:newBundlePath];
    }
    
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
    return language?key:amazonMusicLocalizedString(key, @"en");
}


+ (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor
{
    NSMutableAttributedString *attributedStr;
    attributedStr = [[NSMutableAttributedString alloc] initWithString:item?item:@"" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    if (subLab.length == 0)
    {
        return attributedStr;
    }
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:subLab?subLab:@"" attributes:@{NSForegroundColorAttributeName:subColor,NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    return attributedStr;
}

- (UIColor *)highColor
{
    return [UIColor colorWithRed:00/255.0 green:178/255.0 blue:142/255.0 alpha:1];
}

- (UIColor *)defaultColor
{
    return [UIColor whiteColor];
}

- (UIColor *)lightColor
{
    return [UIColor lightGrayColor];
}

///open webview
- (void)openWebView:(NSString *)url
{
    if (url.length == 0)
    {
        return;
    }
  
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"primeMusicBuyAccount"];
    NSURL *amazonUrl = [NSURL URLWithString:url];
    
    if (@available(iOS 10.0,*))
    {
        [[UIApplication sharedApplication] openURL:amazonUrl options:@{} completionHandler:^(BOOL success) {
            NSLog(@"AmazonMusic buy account webView");
        }];
    }else{
        [[UIApplication sharedApplication] openURL:amazonUrl];
    }
}

#pragma mark -- Show Explict View
- (void)showExplicitAlertView:(int)target isSetting:(BOOL)setting Block:(void(^)(int ret))block
{
    NSString *title;
    NSString *message;
    NSString *next;
    NSString *cancel;
    
    if (setting)
    {
        if (target == 0)
        {
            title = AMAZONLOCALSTRING(@"primemusic_Unblock_Explicit_Songs");
            message = AMAZONLOCALSTRING(@"primemusic_Songs_with_explicit_language_are_blocked_on_this_device__Would_you_like_to_unblock_");
            next = AMAZONLOCALSTRING(@"primemusic_Unblock");
            cancel = AMAZONLOCALSTRING(@"primemusic_Cancel");
        }
        else
        {
            title = AMAZONLOCALSTRING(@"primemusic_Unblock_Explicit_Songs");
            message = AMAZONLOCALSTRING(@"primemusic_Songs_with_explicit_language_will_be_blocked_on_this_device_");
            next = AMAZONLOCALSTRING(@"primemusic_Block");
            cancel = AMAZONLOCALSTRING(@"primemusic_Cancel");
        }
    }
    else
    {
        title = @"Explicit Songs";
        message = @"Songs with explicit language are blocked on this device.";
        next = nil;
        cancel = @"OK";
    }
    
    [self showAlertViewTitle:title Message:message Cancel:cancel Next:next Request:@{@"target":@(target)} Target:1000 Block:^(int ret, NSDictionary *result)
     {
         block(ret);
     }];
}

#pragma mark -- Alert Request Error
- (void)showAlertRequestError:(NSDictionary *)alertDict Block:(void(^)(int ret, NSDictionary * result))block
{
    NSArray *optionArr = alertDict[@"options"] && [alertDict[@"options"] isKindOfClass:[NSArray class]]  ? alertDict[@"options"] : @[];
    NSString *cancel;
    NSString *conti;
    NSDictionary *arr0 = optionArr.firstObject;
    NSDictionary *arr1 = optionArr.lastObject;
    NSString *requestUrl;
    
    if (optionArr.count == 0)
    {
        [self showToastView:alertDict[@"explanation"]];
        return;
    }
    
    if (arr0[@"uri"])
    {
        conti = arr0[@"label"];
        cancel = arr1[@"label"];
        requestUrl = arr0[@"uri"];
    }
    else
    {
        conti = arr1[@"label"];
        cancel = arr0[@"label"];
        requestUrl = arr1[@"uri"];
    }
    
    if ([cancel isEqualToString:conti])
    {
        conti = nil;
    }
    
    [self showAlertViewTitle:alertDict[@"brief"] Message:alertDict[@"explanation"] Cancel:cancel Next:conti Request:@{@"url":requestUrl ? requestUrl :@""} Target:1001 Block:^(int ret, NSDictionary *result)
     {
         block(ret,result);
     }];
}


#pragma mark --- alertView method
- (void)showAlertViewTitle:(NSString *)title Message:(NSString *)message Cancel:(NSString *)cancel Next:(NSString *)next Request:(NSDictionary *)dict Target:(NSInteger)tag Block:(void(^)(int ret, NSDictionary * result))block
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->isVisibleAlert) {
            block(3, nil);
            return;
        }
        
        self.requestDict = [[NSDictionary alloc] initWithDictionary:dict];
        self.alertViewBlock = block;
        self->isVisibleAlert = YES;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (cancel) {
            [alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                self->isVisibleAlert = NO;
                
                [self->alertViewController.view removeFromSuperview];
                
                if (tag == 1000)
                {
                    NSString *result = weakSelf.requestDict[@"target"];
                    if ([result integerValue] == 0) //关闭
                    {
                        weakSelf.alertViewBlock(1, nil);
                    }else{
                        weakSelf.alertViewBlock(1, nil);
                    }
                }
                else if (tag == 1001)
                {
                    weakSelf.alertViewBlock(0,nil);
                }
            }]];
        }
        if (next) {
            [alertController addAction:[UIAlertAction actionWithTitle:next style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                self->isVisibleAlert = NO;
                [self->alertViewController.view removeFromSuperview];
                
                if (tag == 1000)
                {
                    NSString *result = self.requestDict[@"target"];
                    if ([result integerValue] == 0) //关闭
                    {
                        [[AmazonMusicBoxManager shared] sendExplicitStateToBox:0 block:^(int ret) {
                            
                            if (ret == 0) {
                                weakSelf.alertViewBlock(0, @{});
                                
                            }else{
                                weakSelf.alertViewBlock(1, nil);
                            }
                        }];
                    }else{
                       
                        [[AmazonMusicBoxManager shared] sendExplicitStateToBox:1 block:^(int ret) {
                            
                            if (ret == 0) {
                                
                                weakSelf.alertViewBlock(0, @{});
                            }else{
                                
                                weakSelf.alertViewBlock(1, nil);
                            }
                        }];
                    }
                }
                else if (tag == 1001){
                    weakSelf.alertViewBlock(1,weakSelf.requestDict);
                }
            }]];
        }

        self->alertViewController = [[UIViewController alloc] init];
        [[self currentWindow] addSubview:self->alertViewController.view];
        [self->alertViewController presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)showToastView:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self currentWindow] makeToast:message duration:2 position:@"CSToastPositionCenter"];
    });
}

- (void)switchRootIsLoginController
{
    UIViewController *current = [self getCurrentVC];
    AmazonMusicLoginController *login = [[AmazonMusicLoginController alloc] init];
    [current.navigationController pushViewController:login animated:YES];
}

//加载图片
+ (UIImage *)imageNamed:(NSString *)string
{
  return [UIImage imageNamed:[NSString stringWithFormat:@"LPAmazonMusicUI.bundle/%@", string]
    inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

-(UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal)
            {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (UIWindow *)currentWindow
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal)
            {
                window = tempWindow;
                break;
            }
        }
    }
    return window;
}

///current window
- (UIViewController *)currentController
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *topController = window.rootViewController;
    while (topController.presentedViewController) {
       topController = topController.presentedViewController;
    }
    return topController;
}

@end
