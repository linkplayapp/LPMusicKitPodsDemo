//
//  AmazonMusicSongListViewController.m
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicSongListViewController.h"
#import "AmazonSongsTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "AmazonMusicSearchViewController.h"
#import "AmazonMusicSettingViewController.h"
#import "AmazonMusicNavigationSet.h"
#import "AmazonMusicConfig.h"
#import "AmazonMusicErrorView.h"

@interface AmazonMusicSongListViewController ()<MJRefreshBaseViewDelegate,AmazonMusicNavigationBarDelegate>
{
    MJRefreshFooterView *footerView;
    MJRefreshHeaderView *headerView;
}

@property (nonatomic, strong) LPAmazonMusicNetwork *network;//网络请求
@property (nonatomic, strong) AmazonMusicNavigationSet *NavigationBar;//导航栏集合
@property (nonatomic, strong) AmazonMusicErrorView *errorView;//错误展示
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *playHeaderArray;//分页
@property (nonatomic, strong) NSMutableArray *playArray;//列表

@property (nonatomic, strong) NSString *playingTrackId; //正在播放的歌
@property (nonatomic, assign) BOOL isPlayng;// 是否正在播放

@end

@implementation AmazonMusicSongListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navigation button
    if (!self.isFromSearch) {
        float barViewHeight = self.navigationController.navigationBar.frame.size.height;
        NSArray *navButArr = [self.NavigationBar navigationButHeight:barViewHeight];
        self.navigationItem.rightBarButtonItems = navButArr;
    }
    
    UIImageView *tableHeader = [self getTableHeaderImageView:self.playItem.trackImage defaultImage:[AmazonMusicMethod imageNamed:@"list_default"] isPlayng:NO];
    self.tableView.tableHeaderView = tableHeader;
    self.tableView.tableFooterView = [self addFooterView];
    
    //request
    if (!self.searchDictionary) {
      [self p_getAlbumContent];
    }else{
        LPAmazonMusicPlayHeader *searchHeader = self.searchDictionary[@"header"];
        NSArray *searchList = self.searchDictionary[@"list"];
        
        //header
        [self.playHeaderArray addObject:searchHeader];
        
        //item
        [self.playArray removeAllObjects];
        [self.playArray addObjectsFromArray:searchList];
        [self addFooterRefresh];

        self.playingTrackId = @"";
        [self.tableView reloadData];
    }
    
    //refresh
    if (!self.isFromSearch) {
        headerView = [MJRefreshHeaderView header];
        headerView.scrollView = self.tableView;
        headerView.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)isNavgationClearColor
{
    return NO;
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(BOOL)needBlurBack
{
    return YES;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

- (NSString *)currentDeviceId
{
    return [AmazonMusicBoxManager shared].deviceId;
}

-(void)mediaInfoChanged
{
    [super mediaInfoChanged];
    
    if (![[[AmazonMusicBoxManager shared] mediaSource] isEqualToString:AMAZON_MUSIC_SOURCE]) {
        return;
    }
    
    for (LPAmazonMusicPlayItem *playItem in self.playArray) {
        
        if ([playItem.trackId isEqualToString:[[AmazonMusicBoxManager shared] songId]]) {
            
            [self updateHeaderPlayButton:playItem.trackId];
            return;
        }
    }
}

- (void)updateHeaderPlayButton:(NSString *)trackId
{
    BOOL isPlaying = [[AmazonMusicBoxManager shared] isPlaying];
    if (isPlaying == self.isPlayng) {
        
        if ([trackId isEqualToString:self.playingTrackId]) {
            return;
        }
        self.playingTrackId = @"";
        [self.tableView reloadData];
        return;
    }
    self.isPlayng = isPlaying;
    
    UIImageView *tableHeader = [self getTableHeaderImageView:self.playItem.trackImage defaultImage:[AmazonMusicMethod imageNamed:@"list_default"] isPlayng:isPlaying];
    self.tableView.tableHeaderView = tableHeader;
    self.playingTrackId = @"";
    [self.tableView reloadData];
}

- (void)addFooterRefresh
{
    LPAmazonMusicPlayHeader *header = self.playHeaderArray.lastObject;
    
    if (header.seeMoreUrl.length == 0)
    {
        [footerView removeFromSuperview];
        footerView = nil;
        return ;
    }
    
    if (![footerView isDescendantOfView:self.tableView])
    {
        footerView = [MJRefreshFooterView footer];
        footerView.scrollView = self.tableView;
        footerView.delegate = self;
    }
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == self->footerView)
        {
            LPAmazonMusicPlayItem *itemMode = self.playArray.lastObject;
            LPAmazonMusicPlayHeader *playHeader = self.playHeaderArray.lastObject;
            [self showHud:@""];
            [self.network seeMoreMusicSourcesList:playHeader playItem:itemMode success:^(LPAmazonMusicPlayHeader *header, NSArray<LPAmazonMusicPlayItem *> *list) {
                
                [self hideHud:@"" afterDelay:0 type:0];
                [self->footerView endRefreshing];
                
                //header
                [self.playHeaderArray addObject:header];
                
                //item
                [self.playArray addObjectsFromArray:list];
                [self addFooterRefresh];
                
                self.playingTrackId = @"";
                [self.tableView reloadData];
                
            } failure:^(LPAmazonMusicNetworkError *error) {
                
                [self->footerView endRefreshing];
                
                if (error.type == 1)
                {
                    [self hideHud:@"" afterDelay:0 type:0];
                    [[AmazonMusicMethod sharedInstance] showAlertRequestError:error.alertDict Block:^(int ret, NSDictionary * _Nonnull result) {
                        
                        if (ret == 1 && result[@"url"])
                        {
                            [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
                        }
                    }];
                }else{
                    [self hideHud:error.message afterDelay:1.5 type:0];
                }
                
                if (self.playArray.count == 0)
                {
                    [self.errorView show:error.message];
                }
            }];
        }
        else if (refreshView == self->headerView)
        {
            [self p_getAlbumContent];
        }
    });
}

#pragma mark -- amazonMusicNavigationBar delegate
- (void)selectMusicNavigationBar:(AmazonMusicNavButType)type
{
    if (type == NavBut_Search)
    {
        AmazonMusicSearchViewController *searchController = [[AmazonMusicSearchViewController alloc] init];
        [self.navigationController pushViewController:searchController animated:YES];
    }else{
        AmazonMusicSettingViewController *settingController = [[AmazonMusicSettingViewController alloc] init];
        [self.navigationController pushViewController:settingController animated:YES];
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPAmazonMusicPlayItem *playItem = self.playArray[indexPath.row];
    
    LPAmazonMusicPlayHeader *playHeader;
    int trackCount = 0;
    for (LPAmazonMusicPlayHeader *header in self.playHeaderArray) {
        trackCount = trackCount + header.perPage;
        if (indexPath.row < trackCount) {
            playHeader = header;
            break;
        }
    }
    
    static NSString *kCellIdentifier = @"amazonsongstableviewcell";
    AmazonSongsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AmazonSongsTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = THEME_DEFAULT_COLOR;
    [cell.selectBut setImage:[AmazonMusicMethod imageNamed:@"muzo_track_more_n"] forState:UIControlStateNormal];
    cell.selectBut.hidden = NO;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    
    [cell.cover sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[AmazonMusicMethod imageNamed:@"defaultArtwork"]];

    //是否过滤
    if ([AmazonMusicBoxManager shared].isExplicit)
    {
        if (playItem.isExplicit)
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:[UIColor grayColor] subLabColor:[UIColor grayColor]];
            return cell;
        }
    }
    
    //是否正在播放
    if ([[AmazonMusicBoxManager shared] trackIsPlaying:playHeader playItem:playItem])
    {
        self.playingTrackId = playItem.trackId;
        cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_HIGH_COLOR subLabColor:THEME_LIGHT_COLOR];
    }
    else
    {
        cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_DEFAULT_COLOR subLabColor:THEME_LIGHT_COLOR];
    }
    
    //more
    cell.block = ^(){
        [self moreActionHeader:playHeader playItem:playItem];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    LPAmazonMusicPlayItem *playItem = self.playArray[indexPath.row];
    
    LPAmazonMusicPlayHeader *playHeader;
    int trackCount = 0;
    for (LPAmazonMusicPlayHeader *header in self.playHeaderArray) {
        trackCount = trackCount + header.perPage;
        if (indexPath.row < trackCount) {
            playHeader = header;
            break;
        }
    }

    //是否过滤
    if ([AmazonMusicBoxManager shared].isExplicit)
    {
        if (playItem.isExplicit)
        {
            [[AmazonMusicMethod sharedInstance] showExplicitAlertView:0 isSetting:NO Block:^(int ret) {
                if(ret == 0)
                {
                    self.playingTrackId = @"";
                    [self.tableView reloadData];
                }
            }];
            return;
        }
    }
    
    //不能播放
    if (playItem.trackUrl.length == 0)
    {
        [[AmazonMusicMethod sharedInstance] showAlertRequestError:playItem.audioError Block:^(int ret, NSDictionary * _Nonnull result) {
            
            if (ret == 1 && result[@"url"])
            {
                [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
            }
        }];
        return;
    }
   
    //进行播放
    if ([[AmazonMusicBoxManager shared] trackIsPlaying:playHeader playItem:playItem]){
        [[AmazonMusicBoxManager shared] showPlayViewController];
        return;
    }

    [self showHud:@""];
    [[AmazonMusicBoxManager shared] startPlayHeader:playHeader playItem:playItem Block:^(int ret, NSString * _Nonnull message) {
       
        [self hideHud:@"" afterDelay:3 type:0];
        
        if (ret == 1)
        {
            [self.view makeToast:message];
        }
        else
        {
            self.playingTrackId = @"";
            self.selectTrackId = playItem.trackId;
            [self.tableView reloadData];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76*WSCALE;
}

- (void)controllerMoreBtn
{
    
}

- (void)controllerPlayBtn
{
    [super controllerPlayBtn];
    
    if (!(self.playingTrackId.length > 0))
    {
        if([self.playArray count] == 0)
        {
            return;
        }
        else
        {
            LPAmazonMusicPlayItem *playItem = self.playArray[0];
            LPAmazonMusicPlayHeader *playHeader = self.playHeaderArray.firstObject;
            
            //是否过滤
             if ([AmazonMusicBoxManager shared].isExplicit)
             {
                 if (playItem.isExplicit)
                 {
                     [[AmazonMusicMethod sharedInstance] showExplicitAlertView:0 isSetting:NO Block:^(int ret) {
                         if(ret == 0)
                         {
                             self.playingTrackId = @"";
                             [self.tableView reloadData];
                         }
                     }];
                     return;
                 }
             }
             
             //是否不能播放
             if (playItem.trackUrl.length == 0)
             {
                 [[AmazonMusicMethod sharedInstance] showAlertRequestError:playItem.audioError Block:^(int ret, NSDictionary * _Nonnull result) {
                     
                     if (ret == 1 && result[@"url"])
                     {
                         [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
                     }
                 }];
                 return;
             }
            
             //进行播放
             [self showHud:@""];
             [[AmazonMusicBoxManager shared] startPlayHeader:playHeader playItem:playItem Block:^(int ret, NSString * _Nonnull message) {
                
                 [self hideHud:@"" afterDelay:2 type:0];
                 
                 if (ret == 1)
                 {
                     [self.view makeToast:message];
                 }
                 else
                 {
                     self.playingTrackId = @"";
                     [self.tableView reloadData];
                 }
             }];
        }
    }
    else
    {
        BOOL isPlaying = [[AmazonMusicBoxManager shared] isPlaying];
        if (isPlaying){
            
            [[AmazonMusicBoxManager shared] sendPause];
        }else{
            
            [[AmazonMusicBoxManager shared] sendPlay];
        }
        self.isPlayng = !isPlaying;
    
        UIImageView *tableHeader = [self getTableHeaderImageView:self.playItem.trackImage defaultImage:[AmazonMusicMethod imageNamed:@"list_default"] isPlayng:self.isPlayng];
        self.tableView.tableHeaderView = tableHeader;
        
        self.playingTrackId = @"";
        [self.tableView reloadData];
    }
}

#pragma mark -- private methods
- (void)p_getAlbumContent
{
    [self showHud:@""];
    [self.errorView dismiss];
    [self.network getMusicSourcesList:self.playHeader playItem:self.playItem success:^(LPAmazonMusicPlayHeader *header, NSArray<LPAmazonMusicPlayItem *> *list) {
        
        [self hideHud:@"" afterDelay:0 type:0];
        if (self->headerView.isRefreshing)
        {
            [self->headerView endRefreshing];
            [self.playHeaderArray removeAllObjects];
        }
 
        //header
        [self.playHeaderArray addObject:header];
        
        //item
        [self.playArray removeAllObjects];
        [self.playArray addObjectsFromArray:list];
        [self addFooterRefresh];

        self.playingTrackId = @"";
        [self.tableView reloadData];
        
    } failure:^(LPAmazonMusicNetworkError *error) {
       
        if (self->headerView.isRefreshing)
        {
            [self->headerView endRefreshing];
        }
        
        if (error.type == 1)
        {
            [self hideHud:@"" afterDelay:0 type:0];
            [[AmazonMusicMethod sharedInstance] showAlertRequestError:error.alertDict Block:^(int ret, NSDictionary * _Nonnull result) {
                
                if (ret == 1 && result[@"url"])
                {
                    [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
                }
            }];
        }
        else
        {
            [self hideHud:error.message afterDelay:1.5 type:0];
        }
        
        if (self.playArray.count == 0)
        {
            [self.errorView show:error.message];
        }
    }];
}

//more action
- (void)moreActionHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem
{
    //是否过滤
   if ([AmazonMusicBoxManager shared].isExplicit)
   {
       if (playItem.isExplicit)
       {
           [[AmazonMusicMethod sharedInstance] showExplicitAlertView:0 isSetting:NO Block:^(int ret) {
               if(ret == 0)
               {
                   self.playingTrackId = @"";
                   [self.tableView reloadData];
               }
           }];
           return;
       }
   }
   
   //不能播放
   if (playItem.trackUrl.length == 0)
   {
       [[AmazonMusicMethod sharedInstance] showAlertRequestError:playItem.audioError Block:^(int ret, NSDictionary * _Nonnull result) {
           
           if (ret == 1 && result[@"url"])
           {
               [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
           }
       }];
       return;
   }

   [[AmazonMusicBoxManager shared] openMoreViewWithPlayHeader:playHeader playItem:playItem headerType:LP_HEADER_TYPE_SONG];
}

- (NSMutableArray *)playHeaderArray
{
    if (!_playHeaderArray) {
        _playHeaderArray = [[NSMutableArray alloc] init];
    }
    return _playHeaderArray;
}

- (NSMutableArray *)playArray
{
    if (!_playArray) {
        _playArray = [[NSMutableArray alloc] init];
    }
    return _playArray;
}

- (AmazonMusicNavigationSet *)NavigationBar
{
    if (!_NavigationBar) {
        _NavigationBar = [[AmazonMusicNavigationSet alloc] init];
        _NavigationBar.delegate = self;
    }
    return _NavigationBar;
}

- (AmazonMusicErrorView *)errorView
{
    if (!_errorView) {
        _errorView = [[AmazonMusicErrorView alloc] initWithFrame:CGRectMake(10, (SCREENHEIGHT - 64 - 200)/2.0, SCREENWIDTH - 20, 200)];
        [self.view insertSubview:_errorView aboveSubview:self.tableView];
    }
    return _errorView;
}

- (LPAmazonMusicNetwork *)network
{
    if (!_network) {
        _network = [[LPAmazonMusicNetwork alloc] init];
    }
    return _network;
}

- (NSString *)playingTrackId
{
    if (!_playingTrackId) {
        _playingTrackId = [[NSString alloc] init];
    }
    
    return _playingTrackId;
}

@end
