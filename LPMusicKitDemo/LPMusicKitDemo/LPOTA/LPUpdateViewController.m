//
//  LPUpdateViewController.m
//  upnpxTest
//
//  Created by sunyu on 2019/10/24.
//  Copyright © 2019 wiimu. All rights reserved.
//

#import "LPUpdateViewController.h"
#import <LPMusicKit/LPDeviceManager.h>
#import <LPMusicKit/LPDeviceOTA.h>

@interface LPUpdateViewController ()<LPOTAPercentObjDelegate>
{
    BOOL isHaveOTA;
}
@property (weak, nonatomic) IBOutlet UILabel *OTAStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *OTAResultLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkOTAButton;
@property (weak, nonatomic) IBOutlet UIButton *startOTAButton;

@end

@implementation LPUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.checkOTAButton.layer.cornerRadius = self.startOTAButton.layer.cornerRadius = 5;
    self.checkOTAButton.layer.masksToBounds = self.startOTAButton.layer.masksToBounds = YES;
    self.checkOTAButton.layer.borderColor = self.startOTAButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.checkOTAButton.layer.borderWidth = self.startOTAButton.layer.borderWidth = 1;


}
- (IBAction)checkOTAButtonPress:(id)sender {
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
    LPDeviceOTA *ota = [device getOTA];
    BOOL isHaveOTA = [ota checkUpdate];
    ota.delegate = self;
    NSLog(@"Firmware version = %@", device.deviceStatus.firmware);
    NSLog(@"Firmware  New version = %@", device.deviceStatus.firmwareNewVersion);
    BOOL isHaveInternet = [device.deviceInfo getDeviceInternetStatus];
    self.OTAResultLabel.text = @"";
    if (isHaveInternet) {
        if (isHaveOTA) {
            self.OTAStatusLabel.text = @"Prepare the OTA";
        }else {
            self.OTAStatusLabel.text = @"It's the latest version";
        }
    }else {
        NSLog(@"The current device has no network and cannot be upgraded");
    }
}
- (IBAction)startOTAButtonPress:(id)sender {
    if (isHaveOTA) {
        LPOTATimeoutObj *obj = [[LPOTATimeoutObj alloc] init];
        
        obj.DSPRebootTimeout = 0;
        obj.DSPDownloadTimeout = 120;
        obj.DSPWriteTimeout = 120;
        
        obj.FWDownloadTimeout = 120;
        obj.FWWriteTimeout = 120;
        obj.FWRebootTimeout = 120;
        
        obj.MCUDownloadTimeout = 120;
        obj.MCUWriteTimeout = 120;
        obj.MCURebootTimeout = 120;
        
        LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
        LPDeviceOTA *ota = [device getOTA];

        [ota firmwareStartUpdate:obj completionHandler:^(BOOL isSuccess, BOOL isTimeout) {
            if (isSuccess) {
                NSLog(@"Update successed");
                self.OTAResultLabel.text = @"Update successed";
            }else {
                if (isTimeout) {
                    NSLog(@"Timeout");
                    self.OTAResultLabel.text = @"Timeout";
                }else {
                    NSLog(@"Upgrade failed");
                    self.OTAResultLabel.text = @"Upgrade failed";
                }
            }
        }];
    }
}

- (void)LPOTAPercentUpdate:(LPOTAPercentObj *)percentObj
{
    dispatch_async(dispatch_get_main_queue(), ^{
        float downloadPrecent = percentObj.downloadPercent/100;
        float upgradePercent = percentObj.upgradePercent/100;
        float recatoryPercent = percentObj.recatoryPercent/100;
        
        if (percentObj.firmwareOTAStatus == 1) {
            NSLog(@"Download progress = %@",[NSString stringWithFormat:@"%f",downloadPrecent]);
        }else if (percentObj.firmwareOTAStatus == 3) {
            NSLog(@"Upgrade progress = %@",[NSString stringWithFormat:@"%f",upgradePercent]);
        }else if (percentObj.firmwareOTAStatus == 6) {
            NSLog(@"Recatory progress = %@",[NSString stringWithFormat:@"%f",recatoryPercent]);
        }

    });
    
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
