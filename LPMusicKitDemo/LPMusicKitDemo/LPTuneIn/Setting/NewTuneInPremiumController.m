//
//  NewTuneInPremiumController.m
//  iMuzo
//
//  Created by 程龙 on 2019/9/23.
//  Copyright © 2019 wiimu. All rights reserved.
//

#import "NewTuneInPremiumController.h"
#import "NewTuneInConfig.h"

@interface NewTuneInPremiumController ()<LPTuneInPremiumDelegate>

@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) LPTuneInPremiumView *webView;

@end

@implementation NewTuneInPremiumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    UIImage *image = [NewTuneInMethod imageNamed:@"navigationBarDefaultBg"];
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width/2) topCapHeight:0];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [self.view addSubview:self.backImage];
    self.backImage.image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
    self.title = [NSString stringWithFormat:@"TuneIn %@", TUNEINLOCALSTRING(@"newtuneIn_Premium")];
    //back
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [backButton addTarget:self action:@selector(cancelButAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[NewTuneInMethod imageNamed:@"tunein_icon_close"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    //WebView
    [self.view addSubview:self.webView];
}

- (void)cancelButAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- premium delegate
- (void)tuneInPremiumResult:(LPTuneInPremiumResult)result Error:(NSError *)error
{
    if (result == lp_tunein_premium_success)
    {
        if ([self.delegate respondsToSelector:@selector(newTuneInPremiumControllerResult:)])
        {
            [self.delegate newTuneInPremiumControllerResult:YES];
        }
    }
    else
    {
        [self.view makeToast:TUNEINLOCALSTRING(@"newtuneIn_Premium_opt_in_failed")];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (LPTuneInPremiumView *)webView
{
    if (!_webView) {
        //获取导航栏的rect
        CGRect navRect = self.navigationController.navigationBar.frame;
        
        _webView = [[LPTuneInPremiumView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) navigationHeight:navRect.size.height];
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


@end
