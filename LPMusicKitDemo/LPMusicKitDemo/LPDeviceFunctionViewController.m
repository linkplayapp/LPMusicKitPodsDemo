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
#import "LPDeviceFunctionTableViewCell.h"

#import "LPPlayViewController.h"
#import <LPMusicKit/LPUSBManager.h>
#import "LPUSBViewController.h"
#import "NewTuneInMainController.h"
#import "NewTuneInPublicMethod.h"

@interface LPDeviceFunctionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *functionArray; /** SDK Demo 列表 */
@property (nonatomic, strong) LPDevice *currentDevice;
@end

@implementation LPDeviceFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.functionArray = @[@"Alarm",@"Alexa Alarm",@"Sleep timer",@"Alexa",@"Passthrough",@"Preset", @"Multiroom", @"NAS", @"OTA", @"iPhone media library", @"Personal Hotspot", @"Password", @"TuneIn"];
    self.currentDevice = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
    
     __weak typeof(self) weakSelf = self;
    [[LPUSBManager sharedInstance] getUSBDiskStatusWithID:self.uuid completionHandler:^(BOOL isHaveUSB) {
        if (isHaveUSB) {
            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:weakSelf.functionArray];
            [dataArray addObject:@"USB"];
            weakSelf.functionArray = [dataArray copy];
            [weakSelf.tableView reloadData];
        }
    }];
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
    LPPlayViewController *controller = [[LPPlayViewController alloc] init];
    controller.deviceId = self.uuid;
    controller.source = device.mediaInfo.trackSource;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self presentViewController:controller animated:YES completion:nil];
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
    static NSString *CellIdentifier = @"LPFunctionCell";
    LPDeviceFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LPDeviceFunctionTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    NSString *functionName = self.functionArray[indexPath.row];
    cell.titleLabel.text = functionName;
    cell.switchButton.hidden = ![functionName isEqualToString:@"Personal Hotspot"];
    cell.valueLabel.hidden = ![functionName isEqualToString:@"Password"];
    cell.valueLabel.text = self.currentDevice.deviceStatus.password;
    cell.switchButton.on = !self.currentDevice.deviceStatus.isSSIDHidden;
    
    [cell.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.switchButton.tag = indexPath.row;
    cell.switchButton.onTintColor = [UIColor redColor];
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
    }else if ([name isEqualToString:@"USB"]) {
        LPUSBViewController *controller = [[LPUSBViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"iPhone media library"]) {
        LPLocalMusicViewController *controller = [[LPLocalMusicViewController alloc] init];
        controller.uuid = self.uuid;
        [self.navigationController pushViewController:controller animated:YES];
    }else if ([name isEqualToString:@"TuneIn"]) {
        
        id<LPMediaSourceProtocol> deviceProtocal = [[LPMediaSourceAction alloc] init];
        [[LPMDPKitManager shared] initDeviceActionObject:deviceProtocal];
        
        __weak typeof(self) weakSelf = self;
        NSString *uuid = CURBOX.deviceInfo.soundBoxIdentity;
        
        [[NewTuneInPublicMethod shared] startLocationCheck];
        [[NewTuneInPublicMethod shared] bindingDeviceWithDeviceId:uuid block:^(int ret) {
            if (ret == 0) {
                NewTuneInMainController *vc = [[NewTuneInMainController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                
            }
        }];
    }

}

- (IBAction)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch *)sender;
    BOOL isHidden = !switchButton.on;
    [self.currentDevice.deviceSettings hideSSID:isHidden completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([responseObject[@"result"] isEqualToString:@"OK"]) {
             // If the device SSID has not set a password, you need to prompt the user to set a password
            if (!isHidden) {
                [self.currentDevice.deviceSettings setSSIDPassword:@"123456789" completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
                    if ([responseObject[@"result"] isEqualToString:@"OK"]) {
                        [self.tableView reloadData];
                    }else {
                        NSLog(@"Failed to set SSID password");
                        // Hide device SSID again
                        [self hideSSID:YES];
                    }
                }];
            }
        }else {
            //
            [self.tableView reloadData];
        }
    }];

}

- (void)hideSSID:(BOOL)hide {
    [self.currentDevice.deviceSettings hideSSID:hide completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self.tableView reloadData];
    }];
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
