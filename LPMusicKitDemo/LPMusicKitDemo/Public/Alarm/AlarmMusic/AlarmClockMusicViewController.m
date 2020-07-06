//  category: alarm
//
//  AlarmClockMusicViewController.m
//  iMuzo
//
//  Created by Ning on 15/4/10.
//  Copyright (c) 2015年 wiimu. All rights reserved.
//

#import "AlarmClockMusicViewController.h"
#import "PresetViewController.h"
//#import "NewTuneInMainController.h"

#define LISTNAMEKEY @"listNameKey"
#define MUSICARRAYKEY @"musicArrayKey"
#define PRESENTARRAY @"presentArray"

@interface AlarmClockMusicViewController ()
{
    NSMutableArray *musicSourceArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation AlarmClockMusicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [UIImage imageNamed:@"global_default_backgound"];
    musicSourceArray = [NSMutableArray array];
    
    [musicSourceArray addObject:@{LISTNAMEKEY:@"Preset_Content", MUSICARRAYKEY: @[@"设备内容"]}];
    
    NSMutableArray *alarmMusicArray = [[NSMutableArray alloc] init];
    
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
    
    //是否支持TuneIn的闹钟
    LPDeviceStatus *deviceStatus = device.deviceStatus;
    NSString *supportPreset = deviceStatus ? deviceStatus.NewTuneInPreset:@"";
    if ([supportPreset isEqualToString:@"1"]) {
        [alarmMusicArray addObject:[NSString stringWithFormat:@"%@", NEW_TUNEIN_SOURCE]];
    }

    [musicSourceArray addObject:@{LISTNAMEKEY: @"Alarm_Music", MUSICARRAYKEY:alarmMusicArray}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(NSString *)navigationBarTitle
{
    return [@"alarm_Music" uppercaseString];
}

- (BOOL)isNavigationBackEnabled
{
    return YES;
}

- (BOOL)needBackGroundImageView
{
    return NO;
}

-(void)backButtonPressed
{
    [GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController = nil;
    [GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- UITableViewDelegate &&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [musicSourceArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [musicSourceArray[section][MUSICARRAYKEY] count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return musicSourceArray[section][LISTNAMEKEY];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"kCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }else{
        for(UIView * subview in [cell.contentView subviews]){
            [subview removeFromSuperview];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    NSDictionary *tempDictionary = musicSourceArray[indexPath.section];
    
    if([tempDictionary[LISTNAMEKEY] isEqualToString:@"Preset_Content"]){
        
        cell.textLabel.text = @"alarm_Preset_Content";
    }else if([tempDictionary[LISTNAMEKEY] isEqualToString:@"Alarm_Music"]){
        
        NSString *musicName = tempDictionary[MUSICARRAYKEY][indexPath.row];
        cell.textLabel.text = musicName;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource = YES;
    
    NSDictionary *tempDictionary = musicSourceArray[indexPath.section];
   
    if([tempDictionary[LISTNAMEKEY] isEqualToString:@"Preset_Content"]){
        
        PresetViewController *presentVC = [[PresetViewController alloc] init];
        presentVC.deviceId = self.deviceId;
        presentVC.isAddAlarmClock = YES;
        [self.navigationController pushViewController:presentVC animated:YES];
    }else if([tempDictionary[LISTNAMEKEY] isEqualToString:@"Alarm_Music"]){
        
        NSString *sourceName = tempDictionary[MUSICARRAYKEY][indexPath.row];
        if ([sourceName isEqualToString:NEW_TUNEIN_SOURCE]) {
            
//            [self tuneInAction];
        }
    }
}
//
//- (void)tuneInAction
//{
//    //初始化绑定设备
//    id<LPMediaSourceProtocol> deviceProtocal = [[LPMediaSourceAction alloc] init];
//    if ([[LPTuneInDeviceManager sharedInstance] initTuneInDeviceActionObject:deviceProtocal deviceId:self.deviceId]) {
//        
//        //获取登录状态
//        __weak typeof(self) weakSelf = self;
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [[LPTuneInDeviceManager sharedInstance] getTuneInAccountLoginStatus:^(int ret, NSDictionary *result) {
//            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//            
//            if (ret == 0) {
//                //账号
//                BOOL isLogin = [result[@"isLogin"] boolValue];
//                BOOL accountIsChange = [result[@"accountIsChange"] boolValue];
//                NSString *userName = result[@"userName"] ? result[@"userName"]:@"";
//                [NewTuneInMusicManager shared].isLogin = isLogin;
//                [NewTuneInMusicManager shared].userName = userName;
//                
//                //设备的账号发生变化
//                if (isLogin && accountIsChange)
//                {
//                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TUNEINLOCALSTRING(@"newtuneIn_Prompt") message:TUNEINLOCALSTRING(@"newtuneIn_TuneIn_account_has_been_changed") preferredStyle:UIAlertControllerStyleAlert];
//                    
//                    [alertController addAction:[UIAlertAction actionWithTitle:TUNEINLOCALSTRING(@"newtuneIn_OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    
//                        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//                        NewTuneInMainController *mainController = [[NewTuneInMainController alloc] init];
//                        [self.navigationController pushViewController:mainController animated:YES];
//                    }]];
//                    [weakSelf presentViewController:alertController animated:YES completion:nil];
//                }else{
//
//                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//                    NewTuneInMainController *mainController = [[NewTuneInMainController alloc] init];
//                    [self.navigationController pushViewController:mainController animated:YES];
//                }
//            }else{
//                [weakSelf.view makeToast:TUNEINLOCALSTRING(@"Speaker is busy,please try again") duration:3.f position:@"center"];
//            }
//        }];
//    }
//}

@end
