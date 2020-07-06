//
//  NewTuneInSettingController.m
//  iMuzo
//
//  Created by lyr on 2019/5/9.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInSettingController.h"
#import "NewTuneInConfig.h"
#import "NewTuneInNavigationBar.h"
#import "NewTuneInMenuView.h"
#import "NewTuneInMainController.h"
#import "NewTuneInFavoriteController.h"
#import "NewTuneInBrowseController.h"
#import "NewTuneInSearchController.h"
#import "NewTuneInLoginViewController.h"
#import "LPDeviceFunctionViewController.h"
#import "AlarmClockMusicViewController.h"

@interface NewTuneInSettingController ()<NewTuneInNavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NewTuneInNavigationBar *navBarMethod;
@property (strong, nonatomic) NewTuneInMenuView *menuView;

@end

@implementation NewTuneInSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.backImage.image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
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
    [logoutBut setBackgroundImage:[NewTuneInMethod imageNamed:@"global_button_001_default"] forState:UIControlStateNormal];
    
    if (![NewTuneInMusicManager shared].isLogin)
    {
        [logoutBut setTitle:TUNEINLOCALSTRING(@"newtuneIn_login") forState:UIControlStateNormal];
    }
    else
    {
        [logoutBut setTitle:TUNEINLOCALSTRING(@"newtuneIn_logout") forState:UIControlStateNormal];
    }
    
    [logoutBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBut.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [logoutBut addTarget:self action:@selector(logOutAction) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:logoutBut];
    
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
    if (![NewTuneInMusicManager shared].isLogin)
    {
        NewTuneInLoginViewController *loginView = [[NewTuneInLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:TUNEINLOCALSTRING(@"newtuneIn_Would_you_like_to_log_out_") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:TUNEINLOCALSTRING(@"newtuneIn_Cancel") style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:TUNEINLOCALSTRING(@"newtuneIn_logout") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self logout];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)logout
{
    [self showHud:@""];
    [[LPMSTuneInManager sharedInstance] tuneInLogOut:^(int ret, NSError * _Nonnull error) {
        
        if (ret == 0) {
            [NewTuneInMusicManager shared].isLogin = NO;
            [NewTuneInMusicManager shared].account = nil;
            
            [self hideHud:@"" afterDelay:0 type:0];
            self.tableView.tableFooterView = [self tableFootView];
            [self.tableView reloadData];
            
        }else{
           [self hideHud:TUNEINLOCALSTRING(@"newtuneIn_Log_out_fail__Please_try_again_") afterDelay:0 type:0];
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

#pragma mark -- amazonMusicNavigationBar delegate
- (void)selectMusicNavigationBar:(NewTuneInNavButType)type
{
    if (type == NavBut_Search)
    {
        NewTuneInSearchController *search = [[NewTuneInSearchController alloc] init];
        [self.navigationController pushViewController:search animated:YES];
    }
    else if (type == NavBut_Back)
    {
        if ([GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource) {
            
            for (UIViewController *tempController in self.navigationController.viewControllers) {

                if ([tempController isKindOfClass:[AlarmClockMusicViewController class]]) {

                    [self.navigationController popToViewController:tempController animated:YES];
                }
            }
            return;
        }

        for (UIViewController *tempController in self.navigationController.viewControllers) {

            if ([tempController isKindOfClass:[LPDeviceFunctionViewController class]]) {
                [self.navigationController popToViewController:tempController animated:YES];
            }
        }
    }
    else
    {
        if (self.menuView.isHidden)
        {
            self.menuView.hidden = NO;
        }else{
            self.menuView.hidden = YES;
        }
        
        __weak typeof(self) weakSelf = self;
        self.menuView.block = ^(NSInteger index)
        {
            switch (index) {
                case 0:
                {
                    NewTuneInMainController *main = [[NewTuneInMainController alloc] init];
                    [weakSelf.navigationController pushViewController:main animated:YES];
                }
                    break;
                case 1:
                {
                    NewTuneInBrowseController *browse = [[NewTuneInBrowseController alloc] init];
                    [weakSelf.navigationController pushViewController:browse animated:YES];
                }
                    break;
                case 2:
                {
                    NewTuneInFavoriteController *setting = [[NewTuneInFavoriteController alloc] init];
                    [weakSelf.navigationController pushViewController:setting animated:YES];
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
    if (!_menuView){
        _menuView = [[NewTuneInMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _menuView.select = 3;
        [self.view addSubview:_menuView];
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


@end
