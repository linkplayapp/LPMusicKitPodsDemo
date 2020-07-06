//
//  LPDeviceListViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPDeviceListViewController.h"
#import <LPMusicKit/LPMusicKit.h>
#import "LPDeviceListTableViewCell.h"
#import "DeviceKVOObject.h"
#import "LPWiFiSetupViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LPDeviceFunctionViewController.h"
#import "LPBLESearchViewController.h"
#import "LPLocalMusicViewController.h"

#define LPDeviceInfoChangeNotification @"LPDeviceInfoChangeNotification"

@interface LPDeviceListViewController ()
<LPDeviceManagerObserver, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *deviceListArray; /** Device list */
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray <DeviceKVOObject *> *deviceKVOArray; /** Device KVO */

@end

@implementation LPDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Device List";
    self.deviceKVOArray = [NSMutableArray array];
    [[LPDeviceManager sharedInstance] debugSwitch:YES];
    [[LPDeviceManager sharedInstance] addObserver:self];
    [[LPDeviceManager sharedInstance] start:@""];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithDeviceInfoChange:) name:LPDeviceInfoChangeNotification object:nil];
    // KVO Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceInfoByKey:) name:@"updateDeviceInfoByKey" object:nil];
    [self addFooterView];
    
    
    if (@available(iOS 13,*)) {
        // Get location permission, you can get the Wi-Fi name connected to the phone
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)addFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120 , [UIScreen mainScreen].bounds.size.width, 180)];
    footerView.backgroundColor = [UIColor clearColor];
    
    float cancelHeight = 50;
    UIButton *AlternateButton = [[UIButton alloc] initWithFrame:CGRectMake(15, (60-cancelHeight)/2.f, [UIScreen mainScreen].bounds.size.width-30, cancelHeight)];
    [AlternateButton setTitle:@"Alternate Setup Method" forState:UIControlStateNormal];
    [AlternateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [AlternateButton setBackgroundColor:[UIColor lightGrayColor]];
    [AlternateButton addTarget:self action:@selector(AlternatePressed) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:AlternateButton];
    
    UIButton *BLESetupButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 60 + (60-cancelHeight)/2.f, [UIScreen mainScreen].bounds.size.width-30, cancelHeight)];
    [BLESetupButton setTitle:@"BLE Setup Method" forState:UIControlStateNormal];
    [BLESetupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [BLESetupButton setBackgroundColor:[UIColor lightGrayColor]];
    [BLESetupButton addTarget:self action:@selector(BLESetupPressed) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:BLESetupButton];

    _tableView.tableFooterView = footerView;

}

#pragma mark - notification methods

-(void)updateDeviceInfoByKey:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    NSLog(@"Info Change = %@", dictionary);
}

-(void)dealWithDeviceInfoChange:(NSNotification *)notification
{
    // Get device list
    self.deviceListArray = [[[LPDeviceManager sharedInstance] deviceArray] mutableCopy];
    // Just get a list of master devices
    // self.deviceListArray = [[[LPDeviceManager sharedInstance] getMasterDevices] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deviceListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPDeviceListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LPDeviceListTableViewCell" owner:self options:nil] lastObject];
    }
    LPDevice *device = self.deviceListArray[indexPath.row];
    cell.deviceName.text = device.deviceStatus.friendlyName;
    cell.UUIDLabel.text = device.deviceStatus.UUID;
    cell.IPLabel.text = [NSString stringWithFormat:@"%@--%@",device.deviceStatus.IP, (device.deviceStatus.roomState == LP_ROOM_MASTER)?@"Master":@"Slave"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPDevice *device = self.deviceListArray[indexPath.row];
    
    LPDeviceFunctionViewController *controller = [[LPDeviceFunctionViewController alloc] init];
    controller.uuid = device.deviceStatus.UUID;
    [self.navigationController pushViewController:controller animated:YES];

}

#pragma mark —————Alternate Setup Method—————
- (void)AlternatePressed {
    LPWiFiSetupViewController *controller = [[LPWiFiSetupViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark —————BLE Setup Method—————
- (void)BLESetupPressed {
    LPBLESearchViewController *controller = [[LPBLESearchViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

/**********************************************/
#pragma mark - LPDeviceManagerObserver methods
- (void)onLPDeviceOnline:(LPDevice *)device
{
    // Get device list
    self.deviceListArray = [[[LPDeviceManager sharedInstance] deviceArray] mutableCopy];
    // Just get a list of master devices
    // self.deviceListArray = [[[LPDeviceManager sharedInstance] getMasterDevices] mutableCopy];
    
    // Add KVO
    [self addDevice:device];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)onLPDeviceOffline:(LPDevice *)device
{
    NSLog(@"-- remove %@",[[device deviceStatus] UUID]);
    [self removeDevice:device];
    // Get device list
    self.deviceListArray = [[[LPDeviceManager sharedInstance] deviceArray] mutableCopy];
    // Just get a list of master devices
    // self.deviceListArray = [[[LPDeviceManager sharedInstance] getMasterDevices] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)onLPDeviceUpdate:(LPDevice *)device
{
    NSLog(@"-- update %@",[[device deviceStatus] UUID]);
    [self.tableView reloadData];
}


- (void)addDevice:(LPDevice *)device{
    BOOL exist = NO;
    for (DeviceKVOObject * boxKVO in self.deviceKVOArray) {
        if ([boxKVO.boxInfo.deviceStatus.UUID isEqualToString:device.deviceStatus.UUID]) {
            exist = YES;
        }
    }
    
    if (!exist) {
        DeviceKVOObject * boxKVO = [[DeviceKVOObject alloc]initWithLPDevice:device];
        [self.deviceKVOArray addObject:boxKVO];
    }
}

- (void)removeDevice:(LPDevice *)device{
    BOOL exist = NO;
    DeviceKVOObject * removeBoxKVO;
    for (DeviceKVOObject * boxKVO in self.deviceKVOArray) {
        if ([boxKVO.boxInfo.deviceStatus.UUID isEqualToString:device.deviceStatus.UUID]) {
            exist = YES;
            removeBoxKVO = boxKVO;
        }
    }
    if (exist) {
        [self.deviceKVOArray removeObject:removeBoxKVO];
    }
}


- (NSMutableArray *)deviceListArray {
    if (!_deviceListArray) {
        _deviceListArray = [NSMutableArray array];
    }
    return _deviceListArray;
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
