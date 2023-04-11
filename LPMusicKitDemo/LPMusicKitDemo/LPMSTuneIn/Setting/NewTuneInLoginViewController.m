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

#import "NewTuneInPublicMethod.h"
#import "Masonry.h"
#import "LPBasicHeader.h"

@interface NewTuneInLoginViewController ()<LPTuneInLoginDelegate>
{
    NSDate * startDate;
}

@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) LPTuneInLoginView *webView;
@property (nonatomic, strong) UILabel *errorLab;

@end

@implementation NewTuneInLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    startDate = [NSDate date];

    [self.view addSubview:self.backImage];
    self.backImage.hidden = YES;
    
    //back
    float barViewHeight = self.navigationController.navigationBar.frame.size.height;
    UIButton *backBut;
    backBut = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBut setFrame:CGRectMake(0,0, 44, barViewHeight)];
    [backBut setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backBut setImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted|UIControlStateSelected];
    backBut.imageEdgeInsets =UIEdgeInsetsMake(0, -30, 0, 0);
    [backBut addTarget:self action:@selector(cancelButAction)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBut];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_topMargin);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottomMargin).offset(0);
    }];
}

-(NSString *)navigationBarTitle
{
    return [[NSString stringWithFormat:@"TuneIn %@", LOCALSTRING(@"newtuneIn_login")] uppercaseString];
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
- (void)lpTuneInLoginSuccess
{
    int interval = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000);
    
    [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_Login_successful")];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
         [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)lpTuneInLoginFail:(NSError *)error
{
    int interval = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000);
    
    NSInteger codes = error.code;
    if(codes == -1001)
    {
        [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_Time_out")];
    }else{
        [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_Login_failed")];
    }
}

- (LPTuneInLoginView *)webView
{
    if (!_webView) {
    
        CGRect navRect = self.navigationController.navigationBar.frame;
        CGFloat height = navRect.size.height;
        height = BOTTOM_PLAYVIEW_HEIGHT;
        height = height + 55 + navRect.size.height;

        NSString * url = nil;
        NSString * redirectUrl = nil;
        
        _webView = [[LPTuneInLoginView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) navigationHeight:height url:url redirectUrl:redirectUrl];
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
        _errorLab.textColor = [UIColor whiteColor];
        _errorLab.font = [UIFont systemFontOfSize:16];
        _errorLab.numberOfLines = 0;
        _errorLab.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_errorLab];
    }
    return _errorLab;
}


@end
