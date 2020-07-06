//
//  LPAlexaSplashViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPAlexaSplashViewController.h"
#import <LPAlexaKit/LPAlexaSplashView.h>
#import <LPMusicKit/LPDeviceManager.h>
#import "LPAlexaLoginViewController.h"

@interface LPAlexaSplashViewController ()<LPAlexaSplashDelegate>

@end

@implementation LPAlexaSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Alexa Splash";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading the view from its nib.
    LPAlexaSplashView *splashView = [[LPAlexaSplashView alloc] initAlexaSplashViewWithFrame:[UIScreen mainScreen].bounds device:self.device];
    splashView.delegate = self;
    [self.view addSubview:splashView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (LPDevice *)device {
    return [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
}

#pragma mark —————LPAlexaSplashDelegate—————

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)login {
    LPAlexaLoginViewController *controller = [[LPAlexaLoginViewController alloc] init];
    controller.uuid = self.uuid;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)skip {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
