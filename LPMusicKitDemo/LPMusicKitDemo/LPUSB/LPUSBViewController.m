//
//  LPUSBViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/13.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPUSBViewController.h"
#import <LPMusicKit/LPUSBManager.h>
#import "LPPlayViewController.h"

@interface LPUSBViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LPPlayMusicList *musicListObj; /** 歌曲对象 */
@property (nonatomic, strong) NSArray *songList; /** 歌曲列表 */
@property (nonatomic, strong) LPDevicePlayer *devicePlayer; /** 播放器对象 */
@end

@implementation LPUSBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.segmentedControl
//    [[LPUSBManager sharedInstance] browseUSBWithID:self.uuid completionHandler:^(NSString * _Nullable result) {
//        LPPlayMusicList *musicList = [[LPMDPKitManager shared] getUSBPlaylistWithString:result];
//        self.musicListObj = musicList;
//        self.songList = musicList.list;
//        [self.tableView reloadData];
//    }];

}

- (LPDevicePlayer *)devicePlayer {
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
    if (!_devicePlayer) {
        _devicePlayer = [device getPlayer];
    }
    return _devicePlayer;
}


#pragma mark - tableview datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songList count];
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
    LPPlayItem *item = self.songList[indexPath.row];
    cell.textLabel.text = item.trackName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@",item.trackArtist, item.albumName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.musicListObj.index = (int)indexPath.row;
    [self.devicePlayer playUSBSongsWithIndex:(int)indexPath.row completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
        if (isSuccess) {
            LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
            
            LPPlayViewController *controller = [[LPPlayViewController alloc] init];
            controller.deviceId = self.uuid;
            controller.source = device.mediaInfo.trackSource;
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
    
    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
    device.deviceInfo.currentPlayIndex = (int)indexPath.row;
    
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
