//
//  LPNASViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/26.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPNASViewController.h"
#import <LPMSNAS/LPNASManager.h>
#import <LPMusicKit/LPDevicePlayer.h>
#import <LPMusicKit/LPDeviceManager.h>
#import <LPMDPKit/LPMDPKit.h>
#import "LPDefaultPlayViewController.h"

@interface LPNASViewController ()
{

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *NASDeviceArray; /** NAS设备列表 */
@property (nonatomic, strong) NSArray *dataArray; /** 设备内容列表 */
@property (nonatomic, strong) LPNASItem *currentItem; /** 选中的NAS设备 */
@property (nonatomic, strong) LPPlayMusicList *currentMusicList; /** 当前返回的MusicList */

@end

@implementation LPNASViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"NAS";
    // 获取NAS设备列表
    self.NASDeviceArray = [[LPNASManager sharedInstance] getList];
    [self.tableView reloadData];
    
}

#pragma mark - tableview datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count == 0?self.NASDeviceArray.count:self.dataArray.count;
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
    if (self.dataArray.count > 0) {
        LPNASPlayItem *item = self.dataArray[indexPath.row];
        if (item.isDirectory) {
            // 表明是文件夹
            cell.textLabel.text = item.trackName;
        }else {
            // 表明是歌曲
            cell.textLabel.text = item.trackName;
            NSLog(@"-----%@", item.trackImage);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@",item.trackArtist, item.albumName];
        }
    }else {
        LPNASItem *item = self.NASDeviceArray[indexPath.row];
        cell.textLabel.text = item.title;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > 0) {
        // NAS 设备内部
        LPNASPlayItem *play = self.dataArray[indexPath.row];
        if (play.isDirectory) {
            // 是文件夹
            [[LPNASManager sharedInstance] searchMusic:self.currentItem playItem:play completionHandler:^(BOOL isSuccess, LPPlayMusicList * _Nullable musicListObj) {
                if (musicListObj.list > 0) {
                    self.dataArray = musicListObj.list;
                    self.currentMusicList = musicListObj;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }];
        }else {
           // 是歌曲, 点击播放歌曲
            LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:self.uuid];
            self.currentMusicList.index = (int)indexPath.row;
            NSDictionary *info = [[LPMDPKitManager shared] playMusicSingleSource:self.currentMusicList];
            [[device getPlayer] playAudioWithMusicDictionary:info completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
                NSLog(@"");
                if (isSuccess) {
                    LPDefaultPlayViewController *controller = [[LPDefaultPlayViewController alloc] init];
                    controller.deviceId = self.uuid;
                    controller.modalPresentationStyle = UIModalPresentationFullScreen;
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    [self presentViewController:controller animated:YES completion:nil];
                }
            }];
        }
    }else {
        // 选择NAS设备
        self.currentItem = self.NASDeviceArray[indexPath.row];
        LPNASPlayItem *play = [[LPNASPlayItem alloc] init];
        self.currentItem.currentPage = 0;
        self.currentItem.perPage = 50;
        [[LPNASManager sharedInstance] searchMusic:self.currentItem playItem:play completionHandler:^(BOOL isSuccess, LPPlayMusicList * _Nullable musicListObj) {
            if (musicListObj.list > 0) {
                self.dataArray = musicListObj.list;
                self.currentMusicList = musicListObj;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
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
