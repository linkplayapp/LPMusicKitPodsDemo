//
//  LPDeviceFunction ViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPDeviceFunctionViewController.h"
#import "LPAlexaManagerViewController.h"
#import "PresetViewController.h"
#import "LPPlayerViewController.h"
#import "LPMultiroomViewController.h"
#import "AlarmClockMainViewController.h"
#import "LPNASViewController.h"
#import "LPUpdateViewController.h"
#import "LPLocalMusicViewController.h"

#import "NewTuneInMusicManager.h"
#import "NewTuneInMainController.h"
#import "TuneInPlayViewController.h"

#import "AmazonMusicMainViewController.h"
#import "AmazonMusicLoginController.h"
#import "LPDefaultPlayViewController.h"
#import <LPMusicKit/LPUSBManager.h>
#import "LPUSBViewController.h"

@interface LPDeviceFunctionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *functionArray; /** SDK Demo 列表 */
@end

@implementation LPDeviceFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.functionArray = @[@"Alarm",@"Alexa Alarm",@"Sleep timer",@"Alexa",@"Passthrough",@"Preset", @"Multiroom", @"NAS", @"OTA",@"TuneIn", @"iPhone media library"];
    
     __weak typeof(self) weakSelf = self;
    [[LPUSBManager sharedInstance] getUSBDiskStatusWithID:self.uuid completionHandler:^(BOOL isHaveUSB) {
        if (isHaveUSB) {
            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:weakSelf.functionArray];
            [dataArray addObject:@"USB"];
            weakSelf.functionArray = [dataArray copy];
            [weakSelf.tableView reloadData];
        }
    }];
    
    //初始化TuneIn
    [[NewTuneInMusicManager shared] initLPMSTuneInSDK];
    
    //AmazonMusic 暂时只支持美国地区用户,以en_US来判断是否打开AmazonMusic.
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    if ([regionCode rangeOfString:@"en_US"].location != NSNotFound)
    {
        NSMutableArray *functionArray = [[NSMutableArray alloc] initWithArray:self.functionArray];
        [functionArray addObject:@"AmazonMusic"];
        self.functionArray = [functionArray copy];
        
        //初始化AmazonMusic
        [[AmazonMusicBoxManager shared] initAmazonMuiscSDK];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:UIBarStyleDefault];
    UIButton * showPlayViewButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [showPlayViewButton setTitle:@"ShowPlayView" forState:UIControlStateNormal];
    [showPlayViewButton addTarget:self action:@selector(showPlayViewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [showPlayViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    showPlayViewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:showPlayViewButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)showPlayViewButtonPressed {
    
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
    if ([device.mediaInfo.trackSource isEqualToString:NEW_TUNEIN_SOURCE]) {
        TuneInPlayViewController *controller = [[TuneInPlayViewController alloc] init];
        controller.deviceId = self.uuid;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self presentViewController:controller animated:YES completion:nil];
    }else if ([device.mediaInfo.trackSource isEqualToString:AMAZON_MUSIC_SOURCE]){
        LPDefaultPlayViewController *controller = [[LPDefaultPlayViewController alloc] init];
        controller.deviceId = self.uuid;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        LPDefaultPlayViewController *controller = [[LPDefaultPlayViewController alloc] init];
        controller.deviceId = self.uuid;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - tableview datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.functionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    else
    {
        for (UIView *subView in cell.contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    NSString *functionName = self.functionArray[indexPath.row];
    cell.textLabel.text = functionName;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = self.functionArray[indexPath.row];
    if ([name isEqualToString:@"Alarm"]) {
        AlarmClockMainViewController *controller = [[AlarmClockMainViewController alloc] init];
        controller.deviceId = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if ([name isEqualToString:@"Alexa"]) {
        LPAlexaManagerViewController *controller = [[LPAlexaManagerViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if ([name isEqualToString:@"Preset"]) {
        PresetViewController *controller = [[PresetViewController alloc] init];
        controller.deviceId = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"Multiroom"]) {
        LPMultiroomViewController *controller = [[LPMultiroomViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"NAS"]) {
        LPNASViewController *controller = [[LPNASViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"OTA"]) {
        LPUpdateViewController *controller = [[LPUpdateViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"Passthrough"]) {
        LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
        [[device getPassthrough] connect];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passthroughConnectionStateChanged:) name:LPPassthroughConnectionStateChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passThroughMessageCome:) name:LPPassThroughMessageCome object:nil];
    }else if ([name isEqualToString:@"TuneIn"]){
        [[NewTuneInMusicManager shared] updateDeviceId:self.uuid];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        NewTuneInMainController *mainController = [[NewTuneInMainController alloc] init];
        [self.navigationController pushViewController:mainController animated:YES];
    }else if ([name isEqualToString:@"AmazonMusic"]){
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [[AmazonMusicBoxManager shared] updateDeviceId:self.uuid];
        if ([AmazonMusicBoxManager shared].account) {
            AmazonMusicMainViewController *mainController = [[AmazonMusicMainViewController alloc] init];
            [self.navigationController pushViewController:mainController animated:YES];
        }else{
            AmazonMusicLoginController *mainController = [[AmazonMusicLoginController alloc] init];
            [self.navigationController pushViewController:mainController animated:YES];
        }
    }else if ([name isEqualToString:@"USB"]) {
        LPUSBViewController *controller = [[LPUSBViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"iPhone media library"]) {
        LPLocalMusicViewController *controller = [[LPLocalMusicViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark —————Passthrough—————

- (void)passthroughConnectionStateChanged:(NSNotification *)notificaiton {
    NSDictionary *dictionary = notificaiton.object;
    NSLog(@"isConnected = %@", dictionary[@"isConnected"]);
}

- (void)passThroughMessageCome:(NSNotification *)notificaiton {
    NSDictionary *dictionary = notificaiton.object;
    NSLog(@"response = %@", dictionary[@"response"]);
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
