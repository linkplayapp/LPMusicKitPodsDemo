//
//  LPAmazonMusicLoginViewController.m
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicLoginController.h"
#import "AmazonMusicMainViewController.h"
#import "LPDeviceFunctionViewController.h"

@interface AmazonMusicLoginController ()<AmazonMusicLoginDelegate>

@property (nonatomic, strong) LPAmazonMusicLoginView *webView;

@end

@implementation AmazonMusicLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[AmazonMusicBoxManager shared] clearExplicit];
    
    //WebView
    [self.view addSubview:self.webView];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(NSString *)navigationBarTitle
{
    return [AMAZONLOCALSTRING(@"primemusic_Amazon_Login") uppercaseString];
}

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return NO;
}

-(void)backButtonPressed
{
    for (UIViewController *tempController in self.navigationController.viewControllers) {
        if ([tempController isKindOfClass:[LPDeviceFunctionViewController class]]) {
            [self.navigationController popToViewController:tempController animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -- LoginView Delegate
- (void)amazonMusicLoginResult:(AmazonMusicLoginResult)result userInfo:(nonnull LPAmazonMusicAccount *)userInfo error:(nonnull NSError *)error
{
    if (result == amazonMusic_login_success){
        [AmazonMusicBoxManager shared].account = userInfo;
        
        AmazonMusicMainViewController *mainController = [[AmazonMusicMainViewController alloc] init];
        [self.navigationController pushViewController:mainController animated:YES];
    }else{
        NSLog(@"amazonMusic: %ld",(long)error.code);
        NSString *message;
        if (error.code == -1001) {
            message =AMAZONLOCALSTRING(@"primemusic_The_connection_has_timed_out_");
        }else{
            message =AMAZONLOCALSTRING(@"primemusic_Fail");
        }
        [self.view makeToast:message];
    }
}

- (void)amazonMusicLoginWebViewError:(NSString *)error
{
    [self.view makeToast:error];
}

- (LPAmazonMusicLoginView *)webView
{
    if (!_webView)
    {
        CGRect navRect = self.navigationController.navigationBar.frame;
        
        _webView = [[LPAmazonMusicLoginView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) navigationHeight:navRect.size.height + 50];
        _webView.delegate = self;
    }
    return _webView;
}

@end
