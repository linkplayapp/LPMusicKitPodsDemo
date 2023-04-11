//
//  NewTuneInSettingController.m
//  iMuzo
//
//  Created by lyr on 2019/5/9.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInSettingController.h"
#import "NewTuneInNavigationBar.h"
#import "NewTuneInMenuView.h"
#import "NewTuneInMainController.h"
#import "NewTuneInFavoriteController.h"
#import "NewTuneInBrowseController.h"
#import "NewTuneInSearchController.h"
#import "NewTuneInPublicMethod.h"
#import "NewTuneInLoginViewController.h"

#import "NewTuneInConfig.h"
#import "Masonry.h"

@interface NewTuneInSettingController ()<NewTuneInNavigationBarDelegate, LPMSTuneInLoginDelegate>
{
    NSDate * startDate;
}

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NewTuneInNavigationBar *navBarMethod;
@property (strong, nonatomic) NewTuneInMenuView *menuView;

@end

@implementation NewTuneInSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    float barViewHeight = self.navigationController.navigationBar.frame.size.height;
    NSArray *navButArr = [self.navBarMethod navigationButHeight:barViewHeight];
    self.navigationItem.rightBarButtonItems = navButArr;
    self.navigationItem.leftBarButtonItems = [self.navBarMethod navigationLeft];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.menuView.hidden = YES;
}

- (UIView *)tableFootView
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 46 + 55)];
    UIButton *logoutBut = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - 308)/2.0, 0, 308, 46)];
    [logoutBut setBackgroundImage:[UIImage imageNamed:@"global_button_001_default"] forState:UIControlStateNormal];

    if ([LPMSTuneInManager sharedInstance].account.token.length == 0)
    {
        [logoutBut setTitle:LOCALSTRING(@"newtuneIn_login") forState:UIControlStateNormal];
    }
    else
    {
        [logoutBut setTitle:LOCALSTRING(@"newtuneIn_logout") forState:UIControlStateNormal];
    }
    logoutBut.titleLabel.font = [UIFont systemFontOfSize:16];
    [logoutBut addTarget:self action:@selector(logOutAction) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:logoutBut];
    [logoutBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(308, 46));
        make.center.mas_equalTo(footView);
    }];
    return footView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //退出按钮
    self.tableView.tableFooterView = [self tableFootView];
}

- (void)logOutAction
{
    if ([LPMSTuneInManager sharedInstance].account.token.length == 0)
    {
        NewTuneInLoginViewController *loginView = [[NewTuneInLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:LOCALSTRING(@"newtuneIn_Would_you_like_to_log_out_") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:LOCALSTRING(@"newtuneIn_Cancel") style:UIAlertActionStyleCancel handler:nil]];
        __weak typeof(self) weakSelf = self;
        [alertController addAction:[UIAlertAction actionWithTitle:LOCALSTRING(@"newtuneIn_logout") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf logout];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)logout
{
    [self showHud:nil];
    __weak typeof(self) weakSelf = self;
    [[LPMSTuneInManager sharedInstance] tuneInSignOut:^(LPTuneInRequestType result, NSError * _Nonnull error) {
        
        if (result == LP_TUNEIN_REQUEST_SUCCESS) {
       
            [weakSelf hideHud:@"" afterDelay:0 type:0];
            weakSelf.tableView.tableFooterView = [self tableFootView];
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf hideHud:LOCALSTRING(@"newtuneIn_Log_out_fail__Please_try_again_") afterDelay:2 type:0];
        }
    }];
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
    return YES;
}

- (BOOL)needPopGestureRecognizer {
    return YES;
}

#pragma mark ---- TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark -- amazonMusicNavgationBar delegate
- (void)selectMusicNavigationBar:(NewTuneInNavButType)type
{
    if (type == TuneIn_NavBut_Search)
    {
        NewTuneInSearchController *search = [[NewTuneInSearchController alloc] init];
        [self.navigationController pushViewController:search animated:YES];
    }
    else if (type == TuneIn_NavBut_Back)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        if (self.menuView.isHidden)
        {
            self.menuView.hidden = NO;
        }
        else
        {
            self.menuView.hidden = YES;
        }
        
        __weak typeof(self) weakSelf = self;
        self.menuView.block = ^(NSInteger index)
        {
            switch (index) {
                case 0:
                {
                    NewTuneInMainController *main = [[NewTuneInMainController alloc] init];
                    [weakSelf.navigationController pushViewController:main animated:NO];
                }
                    break;
                case 1:
                {
                    NewTuneInBrowseController *browse = [[NewTuneInBrowseController alloc] init];
                    [weakSelf.navigationController pushViewController:browse animated:NO];
                }
                    break;
                case 2:
                {
                    NewTuneInFavoriteController *setting = [[NewTuneInFavoriteController alloc] init];
                    [weakSelf.navigationController pushViewController:setting animated:NO];
                }
                    break;
                case 4:
                {
                    
                }
                    break;
                case 5:
                {
                    weakSelf.menuView.hidden = YES;
                }
                    break;
                    
                default:
                    break;
            }
        };
    }
}

- (NewTuneInMenuView *)menuView
{
    if (!_menuView)
    {
        _menuView = [[NewTuneInMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _menuView.select = 3;
        [self.view addSubview:_menuView];
        [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_topMargin);
            make.left.right.bottom.mas_equalTo(0);
//            make.edges.mas_equalTo(0);
        }];
    }
    return _menuView;
}

- (NewTuneInNavigationBar *)navBarMethod
{
    if (!_navBarMethod) {
        _navBarMethod = [[NewTuneInNavigationBar alloc] init];
        _navBarMethod.delegate = self;
    }
    return _navBarMethod;
}

#pragma mark - LPMSTuneInLoginDelegate
- (void)lpTuneInAuthcodeSuccess
{
    [self showHud:@""];
}

- (void)lpTuneInLoginSuccess
{
    [self hideHud:@""];
    
    int interval = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000);
    
    [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_Login_successful")];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)lpTuneInLoginFail:(NSError *)error
{
    [self hideHud:@""];
    
    int interval = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000);
    
    NSInteger codes = error.code;
    if(codes == -1001)
    {
        [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_Time_out")];
    }else{
        [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_Login_failed")];
    }
}

@end
