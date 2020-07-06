//
//  AmazonMusicSettingViewController.m
//  iMuzo
//
//  Created by lyr on 2018/8/27.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonMusicSettingViewController.h"
#import "AmazonMusicConfig.h"
#import "AmazonMusicSettingTableViewCell.h"
#import "AmazonMusicLoginController.h"

@interface AmazonMusicSettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *settingArray;
@property (nonatomic, strong) UIView *footerView;

@end

@implementation AmazonMusicSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.tableFooterView = self.footerView;
    self.settingArray = @[@"name",@"explict",@"logout"];
    [self.tableview reloadData];
}

//

-(BOOL)needBlurBack
{
    return YES;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(NSString *)navigationBarTitle
{
    return [AMAZONLOCALSTRING(@"primemusic_Settings") uppercaseString];
}

-(void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITabelViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"AmazonMusicSettingTableViewCell";
    AmazonMusicSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AmazonMusicSettingTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.nextImage.image = [AmazonMusicMethod imageNamed:@"am_devicelist_continue_n"];
    
    NSString *title = self.settingArray[indexPath.row];
    
    if ([title isEqualToString:@"name"]) {
        
        cell.selectBut.hidden = YES;
        cell.nextImage.hidden = YES;
        cell.titleLab.text = [AmazonMusicBoxManager shared].account.email;
    }else if ([title isEqualToString:@"explict"]){
        
        cell.selectBut.hidden = NO;
        cell.nextImage.hidden = YES;
        BOOL turnSwitch = [AmazonMusicBoxManager shared].isExplicit;
        [cell.selectBut setOn:turnSwitch animated:NO];
        cell.titleLab.text = AMAZONLOCALSTRING(@"primemusic_Block_Explicit_Songs");
        cell.block = ^(int target)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self turnSwitchOn:target];
            });
        };
    }else{
        cell.selectBut.hidden = YES;
        cell.nextImage.hidden = NO;
        cell.titleLab.text = AMAZONLOCALSTRING(@"primemusic_Sign_Out");
    }

    return cell;
}

- (void)turnSwitchOn:(int)target
{
    [[AmazonMusicMethod sharedInstance] showExplicitAlertView:target isSetting:YES Block:^(int ret)
    {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self showHud:@""];
             if (ret == 0)
             {
                 self.HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                 self.HUD.bezelView.backgroundColor = [UIColor blackColor];
                 self.HUD.customView = [[UIImageView alloc] initWithImage:[AmazonMusicMethod imageNamed:@"praiseExplicit"]];
                 self.HUD.mode = MBProgressHUDModeCustomView;
                 [self.HUD hideAnimated:YES afterDelay:2];
             }
             [self.tableview reloadData];
         });
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}


- (void)logButAction{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AMAZONLOCALSTRING(@"primemusic_Sign_Out") message:AMAZONLOCALSTRING(@"primemusic_Are_you_sure_you_want_to_quit_") preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:AMAZONLOCALSTRING(@"primemusic_Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:AMAZONLOCALSTRING(@"primemusic_Sign_Out") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self showHud:AMAZONLOCALSTRING(@"primemusic_Logging_out___")];
        
        //音响退出登录
        [[AmazonMusicBoxManager shared] boxLogOut:^(int ret, NSError * _Nonnull Result) {
            
            if (ret == 0)
            {
                [self hideHud:[NSString stringWithFormat:@"%@",AMAZONLOCALSTRING(@"primemusic_Sign_Out")]];
                
                [AmazonMusicBoxManager shared].account = nil;
                [[AmazonMusicBoxManager shared] clearExplicit];
                
                AmazonMusicLoginController *loginController = [[AmazonMusicLoginController alloc] init];
                [self.navigationController pushViewController:loginController animated:YES];
            }
            else
            {
                [self hideHud:[NSString stringWithFormat:@"%@%@",AMAZONLOCALSTRING(@"primemusic_Sign_Out"),AMAZONLOCALSTRING(@"primemusic_Fail")]];
            }
        }];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSArray *)settingArray{
    if (!_settingArray) {
        _settingArray = [[NSArray alloc] init];
    }
    return _settingArray;
}

@end
