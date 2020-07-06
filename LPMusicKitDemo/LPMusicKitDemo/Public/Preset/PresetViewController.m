//  category: preset
//
//  PresetViewController.m
//  iMuzo
//
//  Created by Ning on 16/1/4.
//  Copyright © 2016年 wiimu. All rights reserved.
//

#import "PresetViewController.h"
#import "UIImageView+WebCache.h"

@interface PresetViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *keyArray;//设备的预置列表

@end

@implementation PresetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPresetStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(NSString *)navigationBarTitle
{
    return [@"preset" uppercaseString];
}

-(BOOL)needBlurBack
{
    return YES;
}

#pragma mark - UITableViewDelegate && UITabelViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.keyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *kCellIdentifier = @"kCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }else{
        for(UIView * subview in [cell.contentView subviews]){
            [subview removeFromSuperview];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    LPPlayMusicList *musicList = self.keyArray[indexPath.row];
    LPPlayHeader *header = musicList.header;
    
    //封面
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 0, [UIScreen mainScreen].bounds.size.width-108, 60)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];;
    nameLabel.text = [header.headTitle length] == 0?@"preset_Content_is_empty":header.headTitle;
    nameLabel.font = [UIFont systemFontOfSize:16];

    //去除后缀
    if ([header.headTitle isEqualToString:RECENTLY_QUEUE])
    {
        nameLabel.text = @"preset_Recently_Played";
    }
    if ([header.headTitle hasPrefix:RECENTLY_QUEUE])
    {
        nameLabel.text = @"preset_Recently_Played";
    }
    else if ([header.headTitle hasPrefix:MyFavoriteQueueName])
    {
        nameLabel.text = @"preset_Favorites";
    }
    else if([header.headTitle hasPrefix:@"WiimuCustomList"])
    {
        NSArray *array = [header.headTitle componentsSeparatedByString:@"WiimuCustomList_"];
        nameLabel.text = [array lastObject];
    }
    else if ([header.mediaSource isEqualToString:SPOTIFY_SOURCE])
    {
        CGFloat labelw = self.view.frame.size.width-80;
        NSArray *array = [header.headTitle componentsSeparatedByString:@"_#~"];
        nameLabel.text = [array firstObject];
        nameLabel.frame = CGRectMake(58, 10, labelw, 25);
        UILabel * sublabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 30, 150, 20)];
        sublabel.text = @"Spotify";
        sublabel.font = [UIFont systemFontOfSize:15];
        sublabel.textColor = [UIColor lightGrayColor];;
        [cell.contentView addSubview:sublabel];
    }
    else if ([header.headTitle rangeOfString:@"_#~"].location != NSNotFound && [header.headTitle length] > 0)
    {
        NSArray *array = [header.headTitle componentsSeparatedByString:@"_#~"];
        nameLabel.text = [array firstObject];
    }

    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:nameLabel];

    if ([header.headTitle length] > 0){
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"devicemanage_devicecontents_0%02d_on",(int)indexPath.row+1]];
    }else{
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"devicemanage_devicecontents_0%02d",(int)indexPath.row+1]];
    }
    
    if ([header.headTitle length] > 0 && !self.isAddPreset && !self.isAddAlarmClock) {
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 74, 8, 64, 44)];
        [cell.contentView addSubview:deleteButton];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = 1000 + indexPath.row;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isAddPreset) {
        LPPlayMusicList *musicList = [[LPPlayMusicList alloc] init];
        musicList.header = self.header;
        musicList.list = @[self.item];
        musicList.index = (int)indexPath.row;
        musicList.account = self.account;
        
        NSDictionary *presetDict = [[LPMDPKitManager shared] updataPresetDataWithPlayMusicList:musicList devicePresetList:self.keyArray];
        LPDevice *device =[[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
        LPDevicePreset *devicePreset = device.getPreset;
        
        [self showHud:@""];
        [devicePreset setPresetWithInfomation:presetDict completionHandler:^(BOOL isSuccess) {
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self hideHud:isSuccess ? @"Success":@"Fail" afterDelay:2 type:MBProgressHUDModeIndeterminate];
                 
                 if (isSuccess) {
                     [self getPresetStatus];
                 }
             });
        }];
    }else if (self.isAddAlarmClock){
        
        LPPlayMusicList *musicList = self.keyArray[indexPath.row];
        LPPlayHeader *header = musicList.header;
        if ([header.headTitle length] == 0) {
            
            [self.view makeToast:@"Preset content cannot be empty"];
            return;
        }
        
        if ([GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource) {
        
            if ([[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController respondsToSelector:@selector(alarmPresetIndex:presetName:)])
            {
                [[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController alarmPresetIndex:(int)indexPath.row presetName:header.headTitle];
            }

            [[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController.navigationController popToViewController:[GlobalUI sharedInstance].alarmSourceObj.alarmRootViewController animated:YES];
            return;
        }
        
    }else{
        LPPlayMusicList *musicList = self.keyArray[indexPath.row];
        LPPlayHeader *header = musicList.header;
        if ([header.headTitle length] == 0) {
            return;
        }
        
        [self showHud:@""];
        LPDevice *device =[[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
        LPDevicePreset *devicePreset = device.getPreset;
        [devicePreset playPresetWithIndex:indexPath.row + 1 completionHandler:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self hideHud:isSuccess ? @"Success":@"Fail" afterDelay:2 type:MBProgressHUDModeIndeterminate];
             });
        }];
    }
}

- (void)deleteButtonAction:(UIButton *)action
{
    int index = (int)action.tag - 1000;
    NSDictionary *presetDict = [[LPMDPKitManager shared] deletePresetDataWithIndex:index devicePresetList:self.keyArray];
    
    [self showHud:@""];
    LPDevice *device =[[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
    LPDevicePreset *devicePreset = device.getPreset;
    [devicePreset deletePresetWithInfomation:presetDict completionHandler:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud:isSuccess ? @"Success":@"Fail" afterDelay:2 type:MBProgressHUDModeIndeterminate];
            if (isSuccess) {
                [self getPresetStatus];
            }
        });
    }];
}

#pragma mark -privateMethods
- (void)getPresetStatus
{
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.deviceId];
    LPDevicePreset *devicePreset = device.getPreset;
    [self showHud:@""];
    [devicePreset getPresets:^(int presetNumber, NSString * _Nullable presetString) {
       dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud:@"" type:0];
            NSArray *list = [[LPMDPKitManager shared] getPresetListDataWithNumber:presetNumber presetString:presetString];
            self.keyArray = [[NSArray alloc] initWithArray:list];
            [self.tableView reloadData];
        });
    }];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

@end
