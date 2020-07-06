//
//  LPAlexaManagerViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPAlexaManagerViewController.h"
#import <LPAlexaKit/LPAlexaKit.h>
#import <LPMusicKit/LPDeviceManager.h>
#import "LPAlexaSplashViewController.h"

@interface LPAlexaManagerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *alexaLanguageButton;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *alexaLanguageLabel;
@property (weak, nonatomic) IBOutlet UIButton *setAlexaLanguageButton;

@property (nonatomic, strong) NSArray *alexaLanguageArray; /** alexa 语言数组 */
@property (nonatomic, strong) NSArray *alexaLanguageKeyArray; /** alexa 语言数组 */

@end

@implementation LPAlexaManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Alexa Manager";
    
    self.alexaLanguageArray = @[@"English (United States)",@"English(United Kingdom/Ireland)",@"Deutsch(Deutschland/Österreich)",@"Canada",@"Japanese",@"English (India)",@"English(Australia/New Zealand)",@"French"];
    self.alexaLanguageKeyArray = @[@"en-US",@"en-GB",@"de-DE",@"en-CA",@"ja-JP",@"en-IN",@"en-AU",@"fr-FR"];
    
    
    self.signInButton.layer.cornerRadius = self.setAlexaLanguageButton.layer.cornerRadius = self.signoutButton.layer.cornerRadius = self.alexaLanguageButton.layer.cornerRadius = 5;
    self.signInButton.layer.masksToBounds = self.setAlexaLanguageButton.layer.masksToBounds = self.signoutButton.layer.masksToBounds = self.alexaLanguageButton.layer.masksToBounds = YES;
    self.signInButton.layer.borderColor = self.setAlexaLanguageButton.layer.borderColor = self.signoutButton.layer.borderColor = self.alexaLanguageButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.signInButton.layer.borderWidth = self.setAlexaLanguageButton.layer.borderWidth = self.signoutButton.layer.borderWidth = self.alexaLanguageButton.layer.borderWidth = 1;

    // Do any additional setup after loading the view from its nib.
    [[LPAlexaManager sharedInstance] getAlexaStatus:self.device completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = responseObject[@"result"];
            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dictonary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            if ([dictonary[@"msg"] isEqualToString:@"not login"]) {
                self.hintLabel.text = @"You have not logged in to Alexa, please click the login button to log in";
                self.signoutButton.hidden = self.alexaLanguageButton.hidden = YES;
            }else {
                self.hintLabel.text = @"You are already logged in Alexa";
                self.signInButton.hidden = YES;
            }
        });
    }];
}


- (LPDevice *)device {
    return [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
}

- (IBAction)signoutButtonPress:(id)sender {
    [[LPAlexaManager sharedInstance] logoutWithDevice:self.device completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSString *result = responseObject[@"result"];
        if ([result isEqualToString:@"OK"]) {
            self.hintLabel.text = @"You have not logged in to Alexa, please click the login button to log in";
            self.signoutButton.hidden = self.alexaLanguageButton.hidden = YES;
            self.signInButton.hidden = NO;
        }
    }];
}
- (IBAction)getAlexaLanguage:(id)sender {
    [[LPAlexaManager sharedInstance] getLanguage:self.device completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@",responseObject);
        NSString *language = responseObject[@"result"];
        int index = (int)[self.alexaLanguageKeyArray indexOfObject:language];
        if (index >= 0) {
            self.alexaLanguageLabel.text = [NSString stringWithFormat:@"Your current Alexa language is %@", self.alexaLanguageArray[index]];
        }

    }];
}
- (IBAction)setAlexaLanguage:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    for (int i =0; i < self.alexaLanguageArray.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:self.alexaLanguageArray[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self sendAlexaLanguage:i];
        }];
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)sendAlexaLanguage:(int)index {
    if (index < self.alexaLanguageKeyArray.count) {
        NSString *languageKey = self.alexaLanguageKeyArray[index];
        [[LPAlexaManager sharedInstance] setLanguage:self.device selectLanguage:languageKey completionHandler:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSString *language = responseObject[@"result"];
            if ([language isEqualToString:@"OK"]) {
                [self getAlexaLanguage:nil];
            }
        }];
    }
}

- (IBAction)signInButtonPress:(id)sender {
    LPAlexaSplashViewController *controller = [[LPAlexaSplashViewController alloc] init];
    controller.uuid = self.uuid;
    [self.navigationController pushViewController:controller animated:YES];
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
