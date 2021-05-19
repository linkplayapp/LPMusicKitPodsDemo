//
//  LPAlexaLoginViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPAlexaLoginViewController.h"
#import <LPAlexaKit/LPAlexaLoginView.h>
#import <LPMusicKit/LPDeviceManager.h>
#import <LPAlexaKit/LPAlexaManager.h>


@interface LPAlexaLoginViewController ()<LPAlexaLoginDelegate>

@end

@implementation LPAlexaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Alexa Login";
    // Do any additional setup after loading the view from its nib.
    LPAlexaLoginView *loginView = [[LPAlexaLoginView alloc] initAlexaLoginViewWithFrame:[UIScreen mainScreen].bounds device:self.device isBeta:NO betaString:@""];
    loginView.delegate = self;
    [self.view addSubview:loginView];
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

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loginFailed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Log in to Alexa failed" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)loginSuccess {
    [[LPAlexaManager sharedInstance] setAuthcodeWithDeivce:self.device completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSString *result = responseObject[@"result"];
        if ([result isEqualToString:@"OK"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Log in to Alexa successfully" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }]];
            [self presentViewController:alertController animated:true completion:nil];
        }else {
            [self loginFailed];
        }
    }];

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
