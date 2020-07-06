//
//  NewTuneInLoginViewController.m
//  iMuzo
//
//  Created by lyr on 2019/7/30.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInLoginViewController.h"
#import "NewTuneInConfig.h"
#import "NewTuneInMainController.h"
#import "NewTuneInSettingController.h"

@interface NewTuneInLoginViewController ()<LPTuneInLoginDelegate>

@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) UILabel *errorLab;

@property (nonatomic, strong) LPTuneInLoginView *webView;

@end

@implementation NewTuneInLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.backImage];
    self.backImage.image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
    
    //back
    float barViewHeight = self.navigationController.navigationBar.frame.size.height;
    UIButton *backBut;

    backBut = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBut setFrame:CGRectMake(0,0, 44, barViewHeight)];
    [backBut setImage:[NewTuneInMethod imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backBut setImage:[NewTuneInMethod imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted|UIControlStateSelected];
    backBut.imageEdgeInsets =UIEdgeInsetsMake(0, -30, 0, 0);
    [backBut addTarget:self action:@selector(cancelButAction)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBut];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    //WebView
    [self.view addSubview:self.webView];
}

-(NSString *)navigationBarTitle
{
    return [[NSString stringWithFormat:@"TuneIn %@", TUNEINLOCALSTRING(@"newtuneIn_login")] uppercaseString];
}

- (void)cancelButAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return NO;
}

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return NO;
}

#pragma mark -- LoginView Delegate
- (void)tuneInLoginResult:(LPTuneInLoginResult)result userInfo:(LPAccount *)userInfo Error:(NSError *)error
{
    if (result == lp_tunein_login_success)
    {
        [NewTuneInMusicManager shared].account = userInfo;
        [NewTuneInMusicManager shared].isLogin = YES;
        
        [self.view makeToast:TUNEINLOCALSTRING(@"newtuneIn_Login_successful")];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
             [self.navigationController popViewControllerAnimated:YES];
        });
    }else if (result == lp_tunein_login_back)
    {
       [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if (error.code == -1001) {
            [self.view makeToast:TUNEINLOCALSTRING(@"newtuneIn_Time_out")];
        }else{
            [self.view makeToast:TUNEINLOCALSTRING(@"newtuneIn_Login_failed")];
        }
    }
}


- (void)newTuneInLoginWebViewError:(NSString *)error
{
    [self.view makeToast:error];
}

- (LPTuneInLoginView *)webView
{
    if (!_webView) {
        CGRect navRect = self.navigationController.navigationBar.frame;
        
        _webView = [[LPTuneInLoginView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) navigationHeight:navRect.size.height];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIImageView *)backImage
{
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    }
    return _backImage;
}

- (UILabel *)errorLab
{
    if (!_errorLab) {
        _errorLab = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREENHEIGHT - 100)/2.0, SCREENWIDTH, 100)];
        _errorLab.textColor = [UIColor blackColor];
        _errorLab.font = [UIFont systemFontOfSize:16];
        _errorLab.numberOfLines = 0;
        _errorLab.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_errorLab];
    }
    return _errorLab;
}


@end
