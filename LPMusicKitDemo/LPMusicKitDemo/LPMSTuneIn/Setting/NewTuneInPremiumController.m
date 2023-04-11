//
//  NewTuneInPremiumController.m
//  iMuzo
//
//  Created by 程龙 on 2019/9/23.
//  Copyright © 2019 wiimu. All rights reserved.
//

#import "NewTuneInPremiumController.h"
#import "NewTuneInConfig.h"

#import "NewTuneInPublicMethod.h"
#import "Masonry.h"
@interface NewTuneInPremiumController ()<LPTuneInPremiumDelegate>

@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) LPTuneInPremiumView *webView;

@end

@implementation NewTuneInPremiumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backImage.hidden = YES;
  
    UIImage *image = [UIImage imageNamed:@"navigationBarDefaultBg"];
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width/2) topCapHeight:0];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [self.view addSubview:self.backImage];
    
    //back
    UIButton *backButton;
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setFrame:CGRectMake(0, 0, 44, 44)];
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [backButton addTarget:self action:@selector(cancelButAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"tunein_icon_close"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    //WebView
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_topMargin);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottomMargin).offset(0);
    }];
}

-(NSString *)navigationBarTitle
{
    return [NSString stringWithFormat:@"TuneIn %@", LOCALSTRING(@"newtuneIn_Premium")];
}

- (void)cancelButAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- premium delegate
- (void)lpTuneInPremiumSuccess
{
    if ([self.delegate respondsToSelector:@selector(newTuneInPremiumControllerResult:)])
    {
        [self.delegate newTuneInPremiumControllerResult:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)lpTuneInPremiumFail:(NSError *)error
{
    [self.view makeToast:LOCALSTRING(@"newtuneIn_Premium_opt_in_failed")];
}

- (LPTuneInPremiumView *)webView
{
    if (!_webView) {
        
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
