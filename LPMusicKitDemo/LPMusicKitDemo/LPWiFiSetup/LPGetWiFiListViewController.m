//
//  LPGetWiFiListViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPGetWiFiListViewController.h"
#import <LPMusicKit/LPWiFiSetupManager.h>

@interface LPGetWiFiListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableArray * wlanDetailsArray;
@property (nonatomic, strong) LPApItem *APDic;

@end

@implementation LPGetWiFiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Wi-Fi List";
    _wlanDetailsArray = [NSMutableArray array];
    _APDic = [NSDictionary dictionary];
    UIButton * refreshButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    refreshButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton * backButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self refreshWlan];
}

- (void)refreshButtonPressed:(id)sender {
    [self refreshWlan];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshWlan {
    __weak __typeof(self)weakSelf = self;
    [[LPWiFiSetupManager sharedInstance] getApList:^(NSMutableArray * _Nonnull LPApList) {
        weakSelf.wlanDetailsArray = LPApList;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - tableview datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_wlanDetailsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    else
    {
        for (UIView *subView in cell.contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    
    
    LPApItem * apItem = [_wlanDetailsArray objectAtIndex:indexPath.row];
    
    NSString *ssid = [self SSIDHexStrToStr:apItem.ssid];
    
    NSString *encry = apItem.encry;
    
    int rssi = [apItem.rssi intValue];

    UILabel * ssidLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, self.view.bounds.size.width - 160, 50)];
    ssidLabel.text = ssid;
    
    UILabel * encryLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 160, 0, 100, 50)];
    encryLabel.text = [NSString stringWithFormat:@"encry=%@",encry];
    
    UILabel * rssiLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 0, 60, 50)];
    rssiLabel.text = [NSString stringWithFormat:@"rssi=%d",rssi];
    
    ssidLabel.font = encryLabel.font = rssiLabel.font = [UIFont systemFontOfSize:15];
    
    [cell.contentView addSubview:ssidLabel];
    [cell.contentView addSubview:encryLabel];
    [cell.contentView addSubview:rssiLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _APDic = [_wlanDetailsArray objectAtIndex:indexPath.row];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please enter the password" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Please enter the password";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *passwordText = alertController.textFields.firstObject;
        if([passwordText.text length] < 5)
        {
            NSLog(@"Password length needs to be at least 5 characters");
            return;
        }
        NSLog(@"Connecting to your network, this may take one to three minutes");
        LPApItem *apItem = [_wlanDetailsArray objectAtIndex:indexPath.row];
        [[LPWiFiSetupManager sharedInstance] connectToWiFi:apItem pass:passwordText.text success:^(LPDevice * _Nonnull device) {
            NSLog(@"LPWiFiConnect success");
        } failed:^(int errorCode) {
            NSLog(@"LPWiFiConnect failed");
            if (errorCode == 1001) {
                [[LPWiFiSetupManager sharedInstance] retryCheckWithTime:30 success:^(LPDevice * _Nonnull device) {
                    NSLog(@"LPWiFiConnect success");
                } failed:^(int errorCode) {
                    NSLog(@"LPWiFiConnect failed");
                }];
            }
        }];
    }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

-(NSString *)SSIDHexStrToStr:(NSString*)hexStr
{
    if([hexStr length] == 0 || ([hexStr length])%2 != 0 )
    {
        return nil;
    }
    
    //先转成UTF8，如果结果为空，则转成gbk
    
    //针对可能出现类似€的特殊字符
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([hexStr length] % 2 == 0)
    {
        range = NSMakeRange(0, 2);
    }
    else
    {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [hexStr length]; i += 2)
    {
        unsigned int anInt;
        NSString *hexCharStr = [hexStr substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    NSString *string = [[NSString alloc]initWithData:hexData encoding:NSUTF8StringEncoding];
    
    
    if (string.length == 0 || string == nil || string == NULL || [string isKindOfClass:[NSNull class]])
    {
        //转UTF8为空，则转gbk
        int byteLength = (int)[hexStr length] /2;
        char * bytes = malloc(byteLength);
        
        int temp=0;
        for(int i=0;i<byteLength;i++)
        {
            temp = [self hex2Dec:[hexStr characterAtIndex:2*i]*16+[hexStr characterAtIndex:2*i+1]];
            temp = [self hex2Dec:[hexStr characterAtIndex:2*i]]*16+[self hex2Dec:[hexStr characterAtIndex:2*i+1]];
            bytes[i]=(char)( temp<128 ? temp : temp-256 ) ;
        }
        
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString*pageSource = [[NSString alloc] initWithBytes:bytes length:byteLength encoding:gbkEncoding];
        
        return pageSource;
    }
    else
    {
        return string;
    }
}

- (int)hex2Dec:(char)ch
{
    if(ch == '0') return 0;
    if(ch == '1') return 1;
    if(ch == '2') return 2;
    if(ch == '3') return 3;
    if(ch == '4') return 4;
    if(ch == '5') return 5;
    if(ch == '6') return 6;
    if(ch == '7') return 7;
    if(ch == '8') return 8;
    if(ch == '9') return 9;
    if(ch == 'a') return 10;
    if(ch == 'A') return 10;
    if(ch == 'B') return 11;
    if(ch == 'b') return 11;
    if(ch == 'C') return 12;
    if(ch == 'c') return 12;
    if(ch == 'D') return 13;
    if(ch == 'd') return 13;
    if(ch == 'E') return 14;
    if(ch == 'e') return 14;
    if(ch == 'F') return 15;
    if(ch == 'f') return 15;
    else return -1;
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
