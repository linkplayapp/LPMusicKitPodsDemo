//
//  LPBLESearchViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/9.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPBLESearchViewController.h"
#import <LPBLESetupKit/LPBLESetupKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MBProgressHUD.h"
#import "LPOtherWiFiViewController.h"

@interface LPBLESearchViewController ()<LPBLEManagerDelegate>
{
    BOOL isTouchSearchBLE;
    NSTimer *searchTimer;
    NSDate *checkDate;
}

@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *UUID;

@end

@implementation LPBLESearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // If you don’t have location permission, please user:
    /**
     [[LPBLEManager shareInstance] getWLANListWithCallback:^(id  _Nullable apList) {
         NSLog(@"WLANList = %@", apList);
     }];
     To get a list of WLANs around the device
     */

    
    self.title = @"BLE Setup";
    self.deviceArray = [NSMutableArray array];
    [LPBLEManager shareInstance].delegate = self;
    __weak __typeof__(self) weakSelf = self;
    isTouchSearchBLE = YES;
    if ([LPBLEManager shareInstance].state == CBManagerStatePoweredOn) {
        isTouchSearchBLE = NO;
        [[LPBLEManager shareInstance] startScan:^(LPPeripheral * _Nonnull peripheral) {
            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf.deviceArray addObject:peripheral];
            [strongSelf.tableView reloadData];
        }];
    }
}

#pragma mark —————LPBLEManagerDelegate —————
- (void)BLEManger:(LPBLEManager *)BLEManger BLEState:(CBManagerState)state {
    NSLog(@"BLE state");
    __weak __typeof__(self) weakSelf = self;
    if (isTouchSearchBLE) {
        if (state == CBManagerStatePoweredOn) {
            [[LPBLEManager shareInstance] startScan:^(LPPeripheral * _Nonnull peripheral) {
                __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf.deviceArray addObject:peripheral];
                [strongSelf.tableView reloadData];
            }];
        }
    }

}

#pragma mark - tableview datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_deviceArray count];
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
    LPPeripheral * peripheralObj = _deviceArray[indexPath.row];
    cell.textLabel.text = peripheralObj.peripheral.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPPeripheral *peripheral = _deviceArray[indexPath.row];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LPBLEManager shareInstance] connectBLE:peripheral callback:^(LP_BLE_CONNECT_RESULT state) {
        if (state == LP_BLE_CONNECT_SUCCESS) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please enter the password" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = @"Please enter the password";
                }];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UITextField *passwordText = alertController.textFields.firstObject;
                    [self startConnectWithPassword:passwordText.text];
                    
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Other Network" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self pushOtherNetworkViewController];
                    
                }]];
                
                [self presentViewController:alertController animated:true completion:nil];
            });
        }else {
            NSLog(@"BLE connection failed");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (void)pushOtherNetworkViewController {
    LPOtherWiFiViewController *controller = [[LPOtherWiFiViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)startConnectWithPassword:(NSString *)password {
    NSString *SSID = [self getDeviceSSID];
    if (SSID.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please provide WiFi Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }]];
            [self presentViewController:alertController animated:true completion:nil];
        });
        return;
    }
    __block NSDictionary *infoDict = @{};
    [[LPBLEManager shareInstance] getWLANListWithCallback:^(id  _Nullable apList) {
        for (NSDictionary *dic in apList) {
            if ([dic[@"displaySSID"] isEqualToString:SSID]) {
                infoDict = dic;
                break;
            }
        }
        [[LPBLEManager shareInstance] connectWLAN:infoDict[@"ssid"] password:password auth:infoDict[@"auth"] encry:infoDict[@"encry"] callback:^(LP_CONNECT_AP_STATE code, id  _Nullable responseObj) {
            if (code == LP_CONNECT_AP_SUCCESS && responseObj) {
                     NSLog(@"[BLE] success = %@", responseObj);
                     NSDictionary * infoDic = responseObj;
                     self.UUID = infoDic[@"UUID"];
                     LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:infoDic[@"UUID"]];
                     if (device) {
                         [self success];
                     }else {
                         if (!self->searchTimer) {
                             self->checkDate = [NSDate date];
                             self->searchTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(waitForDeivceOnline) userInfo:nil repeats:YES];
                             [[NSRunLoop mainRunLoop] addTimer:self->searchTimer forMode:NSDefaultRunLoopMode];
                             [self->searchTimer fire];
                         }
                     }
                 }else if (code == LP_CONNECT_AP_START) {
                     NSLog(@"[BLE] connectWLAN start");
                 }else {
                     NSLog(@"[BLE] setup Failed = %@", responseObj);
                     [self setupFailed];
                 }
        }];
    }];
}

- (void)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.UUID];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"BLE Setup success" message:[NSString stringWithFormat:@"Device IP= %@ UUID = %@",device.deviceStatus.IP, self.UUID] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }]];
        [self presentViewController:alertController animated:true completion:nil];
    });
}
- (void)setupFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"BLE Setup failed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }]];
        [self presentViewController:alertController animated:true completion:nil];
    });
}

- (void)waitForDeivceOnline {
     if ([[NSDate date] timeIntervalSinceDate:checkDate] >= 60) {
         [searchTimer invalidate];
         searchTimer = nil;
         [self setupFailed];
     }else {
         LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.UUID];
         if (device) {
             [searchTimer invalidate];
             searchTimer = nil;
             [self success];
         }
     }
}


- (NSString *)getDeviceSSID {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [dctySSID objectForKey:@"SSID"];
    if ([ssid length] == 0)
    {
        ssid = @"";
    }
    return ssid;
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
