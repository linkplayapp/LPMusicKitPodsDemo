//
//  LPOtherWiFiViewController.m
//  iMuzo
//
//  Created by sunyu on 2020/12/25.
//  Copyright © 2020 wiimu. All rights reserved.
//

#import "LPOtherWiFiViewController.h"

#import "LPWiFiSecuritySelectViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <LPBLESetupKit/LPBLESetupKit.h>

typedef NS_ENUM(NSInteger, LPOtherWiFiSecurityType)
{
    LPOtherWiFiSecurity_None,
    LPOtherWiFiSecurity_WEP,
    LPOtherWiFiSecurity_WPA,
    LPOtherWiFiSecurity_WPA2,
    LPOtherWiFiSecurity_WPA3,
    LPOtherWiFiSecurity_WPAEAP,
    LPOtherWiFiSecurity_WPAEAP2
};

@interface LPOtherWiFiViewController ()<WiFiSecuritySelectDelegate, UITextFieldDelegate> {
    CGFloat _baseButtonBottom;
    NSArray *securityArray;
    NSArray *authArray;
    NSInteger securitySelectIndex;
    
    NSTimer *searchTimer;
    NSDate *checkDate;
}
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *networkNamaLabel;
@property (weak, nonatomic) IBOutlet UILabel *securityLabel;
@property (weak, nonatomic) IBOutlet UITextField *wifiTextField;
@property (weak, nonatomic) IBOutlet UILabel *securityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *securityButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordLabelTop;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIView *networkBgView;
@property (weak, nonatomic) IBOutlet UIView *securityBgView;
@property (weak, nonatomic) IBOutlet UIView *usernameBgView;
@property (weak, nonatomic) IBOutlet UIView *passwordBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottom;

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, copy) NSString *UUID;

@end

@implementation LPOtherWiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Other Network";
    
    securityArray = @[@{@"title":@"None", @"type":@(LPOtherWiFiSecurity_None)},
                    @{@"title":@"WEP", @"type":@(LPOtherWiFiSecurity_WEP)},
                    @{@"title":@"WPA", @"type":@(LPOtherWiFiSecurity_WPA)},
                    @{@"title":@"WPA 2", @"type":@(LPOtherWiFiSecurity_WPA2)},
                    @{@"title":@"WPA 3", @"type":@(LPOtherWiFiSecurity_WPA3)},
                    @{@"title":@"WPA Enterprise", @"type":@(LPOtherWiFiSecurity_WPAEAP)},
                    @{@"title":@"WPA2 Enterprise", @"type":@(LPOtherWiFiSecurity_WPAEAP2)}];
    authArray = @[@"OPEN", @"WEP", @"WPAPSK", @"WPA2PSK", @"WPA3SAE", @"WPAEAP", @"WPA2EAP"];


    securitySelectIndex = 3;
    _viewTop.constant = [UIScreen mainScreen].bounds.size.height/667.f * 40;
    
    _networkNamaLabel.text = @"Network name:";
    _securityLabel.text = @"Security:";
    _usernameLabel.text = @"Username:";
    _passwordLabel.text = @"Password:";
    _securityNameLabel.text = @"WPA 2";
    _securityNameLabel.textColor = [UIColor blackColor];
    _securityNameLabel.font = [UIFont systemFontOfSize:16];
    
    _networkNamaLabel.font = _securityLabel.font = _usernameLabel.font = _passwordLabel.font = [UIFont systemFontOfSize:14];
    _networkNamaLabel.textColor = _securityLabel.textColor = _usernameLabel.textColor = _passwordLabel.textColor = [UIColor blackColor];
    
    // 默认不显示用户名，默认的加密类型是WPA
    _passwordLabelTop.constant = 15;
    _usernameLabel.hidden = _usernameBgView.hidden = YES;
    
    _networkBgView.layer.masksToBounds = _securityBgView.layer.masksToBounds = _usernameBgView.layer.masksToBounds = _passwordBgView.layer.masksToBounds = YES;
    _networkBgView.layer.cornerRadius = _securityBgView.layer.cornerRadius = _usernameBgView.layer.cornerRadius = _passwordBgView.layer.cornerRadius = 4;
    _networkBgView.backgroundColor = _securityBgView.backgroundColor = _usernameBgView.backgroundColor = _passwordBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];


    _passwordTextField.font = _wifiTextField.font = _userNameTextField.font = [UIFont systemFontOfSize:16];
    _passwordTextField.textColor = _wifiTextField.textColor = _userNameTextField.textColor = [UIColor blackColor];
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordTextField.secureTextEntry = YES;
    

    [_continueButton setTitle:@"Next" forState:UIControlStateNormal];
    [_continueButton setBackgroundColor:[UIColor blackColor]];
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 
    _continueButton.enabled = NO;
    _continueButtonBottom.constant += 35;
    _baseButtonBottom = _continueButtonBottom.constant;
    

    [_passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_wifiTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_userNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSString * currentSSID = [self getDeviceSSID];
    self.wifiTextField.text = currentSSID;
}

- (IBAction)touchDown:(id)sender {
    [self dismissKeyBoard];
}
- (IBAction)securityButtonPress:(id)sender {
    [_passwordTextField resignFirstResponder];
    [_wifiTextField resignFirstResponder];
    [_userNameTextField resignFirstResponder];
    LPWiFiSecuritySelectViewController *controller = [[LPWiFiSecuritySelectViewController alloc] init];
    controller.securityArray = securityArray;
    controller.currentRow = securitySelectIndex;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (IBAction)lockButtonPress:(id)sender {
  
}
- (IBAction)continueButtonPress:(id)sender {
    NSString *auth = authArray[securitySelectIndex];
    [_passwordTextField resignFirstResponder];
    [_wifiTextField resignFirstResponder];
    [_userNameTextField resignFirstResponder];
    
    if (securitySelectIndex == 0) {
        self.passwordTextField.text = @"";
    }
    
    NSString *ssid = [self hexStringFromString:_wifiTextField.text];
    NSDictionary *wifiDict = @{@"ssid":ssid, @"displaySSID":_wifiTextField.text?:@"", @"auth":auth?:@"", @"encry":@"", @"password":self.passwordTextField.text?:@"", @"username":self.userNameTextField.text?:@""};
   // 连接wifi
    
    [self startConnectWithPassword:wifiDict];
}

- (void)startConnectWithPassword:(NSDictionary *)infoDict {
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LPBLEManager shareInstance] connectWLAN:infoDict[@"ssid"] password:infoDict[@"password"] auth:infoDict[@"auth"] encry:infoDict[@"encry"] username:infoDict[@"username"] callback:^(LP_CONNECT_AP_STATE code, id  _Nullable responseObj) {
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
    
}

- (void)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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


#pragma mark —————WiFiSecuritySelectDelegate—————

- (void)selectWiFiSecurity:(NSInteger)selectIndex {
    if (selectIndex < securityArray.count) {
        securitySelectIndex = selectIndex;
        NSDictionary *dict = securityArray[selectIndex];
        _securityNameLabel.text = dict[@"title"];
        if (securitySelectIndex >= LPOtherWiFiSecurity_WPAEAP) {
            // WPA has username and password
            _usernameLabel.hidden = _usernameBgView.hidden = _passwordLabel.hidden = _passwordBgView.hidden = NO;
            _passwordLabelTop.constant = 96;
        }else if (securitySelectIndex == LPOtherWiFiSecurity_None) {
            // None no password, no username
            _usernameLabel.hidden = _usernameBgView.hidden = _passwordLabel.hidden = _passwordBgView.hidden = YES;
            _passwordLabelTop.constant = 15;
        }else {
            // WPA or WEP, No username, but a password
            _usernameLabel.hidden = _usernameBgView.hidden = YES;
            _passwordLabel.hidden = _passwordBgView.hidden = NO;
            _passwordLabelTop.constant = 15;
        }
        [self.view layoutIfNeeded];
    }
}

- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyBoard];
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _passwordTextField) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self->_continueButtonBottom.constant = self->_baseButtonBottom + 260;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        });
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self changeContinueButtonState];
}

- (void)dismissKeyBoard{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeContinueButtonState];
        [self->_passwordTextField resignFirstResponder];
        [self->_wifiTextField resignFirstResponder];
        [self->_userNameTextField resignFirstResponder];
        self->_continueButtonBottom.constant = self->_baseButtonBottom;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    });
}

- (void)changeContinueButtonState {
    if (securitySelectIndex >= LPOtherWiFiSecurity_WPAEAP) {
        // WPA has username and password
        if (_wifiTextField.text.length > 0 && _userNameTextField.text.length > 0 && _passwordTextField.text.length > 0)  {
            _continueButton.enabled = YES;
        }else {
            _continueButton.enabled = NO;
        }
    } else if (securitySelectIndex >= LPOtherWiFiSecurity_WPA) {
        // WPA the password length minimum 8
        if (_wifiTextField.text.length > 0 && _passwordTextField.text.length >= 8)  {
            _continueButton.enabled = YES;
        }else {
            _continueButton.enabled = NO;
        }
    }else if (securitySelectIndex == LPOtherWiFiSecurity_WEP) {
        // WEP Password length is not required
        if (_wifiTextField.text.length > 0 && _passwordTextField.text.length > 0)  {
            _continueButton.enabled = YES;
        }else {
            _continueButton.enabled = NO;
        }
    }else {
        // without password
        if (_wifiTextField.text.length > 0)  {
            _continueButton.enabled = YES;
        }else {
            _continueButton.enabled = NO;
        }
    }
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
