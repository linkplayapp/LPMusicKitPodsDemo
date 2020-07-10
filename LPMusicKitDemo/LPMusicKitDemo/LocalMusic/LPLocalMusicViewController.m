//
//  LPLocalMusicViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/13.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPLocalMusicViewController.h"
#import <LPMSMediaLibrary/LPMSMediaLibrary.h>
#import <LPMusicKit/LPDevicePlayer.h>
#import <LPMusicKit/LPDeviceManager.h>
#import <LPMusicKit/LPDeviceInfo.h>
#import <LPMDPKit/LPMDPKitManager.h>
#import <LPMDPKit/LPPlayItem.h>
#import <LPMDPKit/LPPlayHeader.h>
#import <LPMDPKit/LPPlayMusicList.h>
#import "LPPlayViewController.h"

@interface LPLocalMusicViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LPPlayMusicList *musicListObj; /** Song Obj */
@property (nonatomic, strong) NSArray *songList; /** Song List */
@property (nonatomic, strong) LPDevicePlayer *devicePlayer; /** Player Obj */
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation LPLocalMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // start Http Server
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[LPMSLibraryManager sharedInstance] stopHTTPServer];
        [[LPMSLibraryManager sharedInstance] startHTTPServer];
    });

    //  self.segmentedControl
    self.navigationController.navigationBar.translucent = YES;
    [self.segmentedControl setTitle:@"Song" forSegmentAtIndex:0];
    [self.segmentedControl setTitle:@"Artist" forSegmentAtIndex:1];
    [self.segmentedControl setTitle:@"Album" forSegmentAtIndex:2];
    [self.segmentedControl setTitle:@"Playlist" forSegmentAtIndex:3];
    [self getSongs];
    

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
    LPMSLibraryPlayItem *item = self.songList[indexPath.row];
    if (self.musicType == LPLocalMusic_song) {
        cell.textLabel.text = item.trackName;
    }else if (self.musicType == LPLocalMusic_artist) {
        cell.textLabel.text = item.trackArtist;
        
    }else if (self.musicType == LPLocalMusic_album) {
        cell.textLabel.text = item.albumName;
    }else {
        cell.textLabel.text = item.listName;
    }
    UIImage * itunesImage = [[item.mediaItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(500, 500)];
    if (itunesImage) {
        cell.imageView.image = itunesImage;
    }else {
        cell.imageView.image = [UIImage imageNamed:@"song"];
    }
    cell.imageView.transform = CGAffineTransformMakeScale(0.8,0.8);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.musicType == 0) {
        self.musicListObj.index = (int)indexPath.row;
        NSDictionary *info = [[LPMDPKitManager shared] playMusicSingleSource:self.musicListObj];
        [self.devicePlayer playAudioWithMusicDictionary:info completionHandler:^(BOOL isSuccess, NSString * _Nullable result) {
            NSLog(@"");
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
    }else if (self.musicType == 1) {
        // The album corresponding to the singer
        LPMSLibraryPlayItem *item = self.songList[indexPath.row];
        [[LPMSLibraryManager sharedInstance] searchAlbumWithItem:item header:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
            self.musicListObj = musicListObj;
            self.songList = musicListObj.list;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        self.musicType = 2;
    }else if (self.musicType == 2) {
        // Songs corresponding to the album
        LPMSLibraryPlayItem *item = self.songList[indexPath.row];
        [[LPMSLibraryManager sharedInstance] searchAlbumSongsWithItem:item header:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
            self.musicListObj = musicListObj;
            self.songList = musicListObj.list;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        self.musicType = 0;
    }else {
        //Playlist
        LPMSLibraryPlayItem *item = self.songList[indexPath.row];
        [[LPMSLibraryManager sharedInstance] searchListSongsWithItem:item header:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
            self.musicListObj = musicListObj;
            self.songList = musicListObj.list;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        self.musicType = 0;
    }

    
}
- (IBAction)segmentedControlPress:(id)sender {
    NSInteger index = [sender selectedSegmentIndex];
    self.musicType = index;
    switch (index) {
        case 0:
            // Get song list
            [self getSongs];
            break;
        case 1:
            // Get artist list
            [self getArtists];
            break;
        case 2:
            // Get album list
            [self getAlbums];
            break;
        case 3:
            // Get playlist list
            [self getSonglists];
            break;
            
        default:
            break;
    }
}

- (void)getSongs {
    [[LPMSLibraryManager sharedInstance] searchSongs:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
        self.musicListObj = musicListObj;
        self.songList = musicListObj.list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)getArtists {
    [[LPMSLibraryManager sharedInstance] searchArtists:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
        self.musicListObj = musicListObj;
        self.songList = musicListObj.list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)getAlbums {
    [[LPMSLibraryManager sharedInstance] searchAlbums:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
        self.musicListObj = musicListObj;
        self.songList = musicListObj.list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)getSonglists {
    [[LPMSLibraryManager sharedInstance] searchSonglists:nil completionHandler:^(LPPlayMusicList * _Nonnull musicListObj) {
        self.musicListObj = musicListObj;
        self.songList = musicListObj.list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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
