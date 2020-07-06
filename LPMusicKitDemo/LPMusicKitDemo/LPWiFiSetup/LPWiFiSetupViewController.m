//
//  LPWiFiSetupViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPWiFiSetupViewController.h"
#import <LPMusicKit/LPWiFiSetupManager.h>
#import "LPGetWiFiListViewController.h"

@interface LPWiFiSetupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation LPWiFiSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Wi-fi Setup prompt page";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.hintLabel.text = @"Please switch the Wi-Fi of the mobile phone to the SSID hotspot of the device, and then return to the App to continue the network configuration";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LPWiFiSetupManager sharedInstance] isLinkplayHotspotWithCheckTime:10 block:^(BOOL isDirect) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!isDirect) {
            self.statusLabel.text = @"Currently not directly connected to the network";
        }else {
            self.statusLabel.text = @"It is already a direct network";
            [self nextPage];
        }
    }];
}

- (void)nextPage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LPGetWiFiListViewController *controller = [[LPGetWiFiListViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    });
}

- (void)dealWithEnterForground:(NSNotification *)notificaiton {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LPWiFiSetupManager sharedInstance] isLinkplayHotspotWithCheckTime:10 block:^(BOOL isDirect) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (isDirect) {
            self.statusLabel.text = @"It is already a direct network";
            [self nextPage];
        }
    }];

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
