//
//  AmazonMusicSourceViewController.m
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicSourceViewController.h"
#import "AmazonSongsCollectionViewCell.h"
#import "AmazonAlbumCollectionViewCell.h"
#import "AmazonPlaylistsCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "AmazonMusicSongListViewController.h"
#import "AmazonMusicErrorView.h"
#import "AmazonMusicConfig.h"
#import "MJRefresh.h"
#import "AmazonMusicSearchViewController.h"
#import "AmazonMusicSettingViewController.h"
#import "AmazonMusicNavigationSet.h"
#import "AmazonMusicSongListViewController.h"

@interface AmazonMusicSourceViewController ()< UICollectionViewDelegateFlowLayout,MJRefreshBaseViewDelegate,AmazonMusicNavigationBarDelegate>
{
    MJRefreshFooterView *footerView;
    MJRefreshHeaderView *headerView;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) LPAmazonMusicNetwork *network; //网络请求
@property (nonatomic, strong) AmazonMusicNavigationSet *navBarMethod;//导航栏集合
@property (nonatomic, strong) AmazonMusicErrorView *errorView;//展示错误

@property (nonatomic, strong) NSMutableArray *playHeaderArray;//分页
@property (nonatomic, strong) NSMutableArray *playArray;//播放列表

@end

@implementation AmazonMusicSourceViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //navigation button
    if (!self.isFromSearch) {
        float barViewHeight = self.navigationController.navigationBar.frame.size.height;
        NSArray *navButArr = [self.navBarMethod navigationButHeight:barViewHeight];
        self.navigationItem.rightBarButtonItems = navButArr;
    }
    
    //request
    if (!self.searchDictionary) {
        [self requestData];
    }else{
        LPAmazonMusicPlayHeader *searchHeader = self.searchDictionary[@"header"];
        NSArray *searchList = self.searchDictionary[@"list"];
        
        //header
        [self.playHeaderArray addObject:searchHeader];
        
        //item
        [self.playArray removeAllObjects];
        [self.playArray addObjectsFromArray:searchList];
        [self.collectionView reloadData];
        
        if (searchList.count == 0)
        {
            [self.errorView show:AMAZONLOCALSTRING(@"primemusic_NO_Result")];
        }
        
        //seeMore
        [self addFooterRefresh];
    }

    //UI init
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2.f;
    float scale = [UIScreen mainScreen].bounds.size.width/375.f;
    layout.minimumInteritemSpacing =2.f;
    float inset = ([UIScreen mainScreen].bounds.size.width - 2*180*scale)/3.f;
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FootersView"];
    layout.footerReferenceSize = CGSizeMake(0, BOTTOM_PLAYVIEW_HEIGHT);
    
    if (self.cellType == AmazonMusic_Songs_Type)
    {
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2 * inset,76 * scale);
        layout.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
        [self.collectionView registerClass:[AmazonSongsCollectionViewCell class] forCellWithReuseIdentifier:@"amazonmusicsongscollectioncell"];
    }
    else if (self.cellType == AmazonMusic_PlayList_Type)
    {
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2 * inset,76 * scale);
        layout.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
        [self.collectionView registerClass:[AmazonPlaylistsCollectionViewCell class] forCellWithReuseIdentifier:@"amazonplaylistscollectionviewcell"];
    }
    else
    {
        layout.itemSize = CGSizeMake(180.f*scale, 180*scale+55);
        layout.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
        [self.collectionView registerClass:[AmazonAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"amazonmusicalbumcollectioncell"];
    }
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.alwaysBounceVertical = YES;
    
    //refresh
    if (!self.isFromSearch) {
        headerView = [MJRefreshHeaderView header];
        headerView.scrollView = self.collectionView;
        headerView.delegate = self;
    }
}


- (void)requestData
{
    [self showHud:@""];
    [self.errorView dismiss];
    
    [self.network getMusicSourcesList:self.playHeader playItem:self.playItem success:^(LPAmazonMusicPlayHeader *header, NSArray<LPAmazonMusicPlayItem *> *list) {
        
        [self hideHud:@"" afterDelay:0 type:0 ];
        if (self->headerView.isRefreshing)
        {
            [self->headerView endRefreshing];
        }
        
        if (list.count == 1)
        {
            LPAmazonMusicPlayItem *itemMode = list[0];
            if (!itemMode.navigation && !itemMode.playable)
            {
                NSString *errorStr = AMAZONLOCALSTRING(@"primemusic_We_re_sorry__this_content_is_no_longer_available");
                if (itemMode.trackName.length > 0)
                {
                    errorStr = itemMode.trackName;
                }
                [self.errorView show:errorStr];
                return ;
            }
        }
        
        //header
        [self.playHeaderArray removeAllObjects];
        [self.playHeaderArray addObject:header];
        
        //item
        [self.playArray removeAllObjects];
        [self.playArray addObjectsFromArray:list];
        [self.collectionView reloadData];
        
        if (list.count == 0)
        {
            [self.errorView show:AMAZONLOCALSTRING(@"primemusic_NO_Result")];
        }
        
        //seeMore
        [self addFooterRefresh];
        
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

- (void)addFooterRefresh
{
    LPAmazonMusicPlayHeader *header = self.playHeaderArray.lastObject;
    
    if (header.seeMoreUrl.length == 0)
    {
        [footerView removeFromSuperview];
        footerView = nil;
        return ;
    }
    
    if (![footerView isDescendantOfView:self.collectionView])
    {
        footerView = [MJRefreshFooterView footer];
        footerView.scrollView = self.collectionView;
        footerView.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(NSString *)navigationBarTitle
{
    if (self.isFromSearch) {
        return self.searchDictionary[@"title"];
    }
    return self.playItem.trackName;
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
            
            [self.collectionView reloadData];
            return;
        }
        if ([[[AmazonMusicBoxManager shared] currentQueue] isEqualToString:playItem.trackName]) {
            [self.collectionView reloadData];
            return;
        }
    }
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == self->footerView)
        {
            LPAmazonMusicPlayItem *itemMode = self.playArray.lastObject;
            LPAmazonMusicPlayHeader *playHeader = self.playHeaderArray.lastObject;
            if (playHeader.seeMoreUrl.length == 0)
            {
                [self->footerView endRefreshing];
                return ;
            }
            
            [self showHud:@""];
            [self.network seeMoreMusicSourcesList:playHeader playItem:itemMode success:^(LPAmazonMusicPlayHeader *header, NSArray<LPAmazonMusicPlayItem *> *list) {
                
                [self hideHud:@"" afterDelay:0 type:0];
                [self->footerView endRefreshing];
                
                //header
                [self.playHeaderArray addObject:header];
                
                //item
                [self.playArray addObjectsFromArray:list];
                [self addFooterRefresh];
                //
                //        [self dealListSongArr:resultArr];
                [self.collectionView reloadData];
                
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
        else if (refreshView == self->headerView)
        {
            if (self.playItem.navigationPath.length == 0)
            {
                [self->headerView endRefreshing];
                return;
            }
            [self requestData];
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
    }
    else
    {
        AmazonMusicSettingViewController *settingController = [[AmazonMusicSettingViewController alloc] init];
        [self.navigationController pushViewController:settingController animated:YES];
    }
}

#pragma mark -- UICollectionViewDelegate && UICollectionDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.playArray.count ;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LPAmazonMusicPlayItem *playItem  = self.playArray[indexPath.row];
    
    LPAmazonMusicPlayHeader *playHeader;
    int trackCount = 0;
    for (LPAmazonMusicPlayHeader *header in self.playHeaderArray) {
        trackCount = trackCount + header.perPage;
        if (indexPath.row < trackCount) {
            playHeader = header;
            break;
        }
    }
    
    BOOL isShowMore = [[AmazonMusicBoxManager shared] isShowMoreWithPlayItem:playItem playHeader:playHeader];
    
    if (self.cellType == AmazonMusic_Songs_Type)
    {
        AmazonSongsCollectionViewCell *cell =
        (AmazonSongsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"amazonmusicsongscollectioncell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
        [cell.cover sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[AmazonMusicMethod imageNamed:@"defaultArtwork"]];
        
        //是否显示更多
        if (isShowMore) {
            [cell.addButton setImage:[AmazonMusicMethod imageNamed:@"muzo_track_more_n"] forState:UIControlStateNormal];
            cell.addButton.userInteractionEnabled = YES;
            cell.block = ^(){
                
                [self moreActionHeader:playHeader playItem:playItem];
            };
        }else{
            cell.addButton.userInteractionEnabled = NO;
            [cell.addButton setImage:[AmazonMusicMethod imageNamed:@"am_devicelist_continue_n"] forState:UIControlStateNormal];
        }
        
        //是否过滤
        if ([AmazonMusicBoxManager shared].isExplicit)
        {
            if (playItem.isExplicit)
            {
                cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:[UIColor grayColor] subLabColor:[UIColor grayColor]];
                return cell;
            }
        }
        
        if ([[AmazonMusicBoxManager shared] trackIsPlaying:playHeader playItem:playItem])
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_HIGH_COLOR subLabColor:THEME_LIGHT_COLOR];
        }
        else
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_DEFAULT_COLOR subLabColor:THEME_LIGHT_COLOR];
        }
        return cell;
    }
    else if (self.cellType == AmazonMusic_PlayList_Type)
    {
        AmazonPlaylistsCollectionViewCell *cell =
        (AmazonPlaylistsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"amazonplaylistscollectionviewcell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
        [cell.cover sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[AmazonMusicMethod imageNamed:@"defaultArtwork"]];
        
        //是否显示更多
        if (isShowMore) {
            cell.selectBut.userInteractionEnabled = YES;
            [cell.selectBut setImage:[AmazonMusicMethod imageNamed:@"muzo_track_more_n"] forState:UIControlStateNormal];
            cell.block = ^(){
                [self moreActionHeader:playHeader playItem:playItem];
            };
        }else{
            cell.selectBut.userInteractionEnabled = NO;
            [cell.selectBut setImage:[AmazonMusicMethod imageNamed:@"am_devicelist_continue_n"] forState:UIControlStateNormal];
        }
        
        //是否正在播放
        if ([[AmazonMusicBoxManager shared] trackIsPlaying:playHeader playItem:playItem])
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_HIGH_COLOR subLabColor:THEME_LIGHT_COLOR];
        }
        else
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_DEFAULT_COLOR subLabColor:THEME_LIGHT_COLOR];
        }
        return cell;
    }
    else
    {
        AmazonAlbumCollectionViewCell* cell = (AmazonAlbumCollectionViewCell* )[collectionView dequeueReusableCellWithReuseIdentifier:@"amazonmusicalbumcollectioncell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
        [cell.cover sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[AmazonMusicMethod imageNamed:@"defaultArtwork"]];
        
        //是否显示更多
        if (isShowMore) {
            cell.SelectBUt.hidden = NO;
            [cell.SelectBUt setImage:[AmazonMusicMethod imageNamed:@"muzo_track_more_n"] forState:UIControlStateNormal];
            cell.block = ^(){
                [self moreActionHeader:playHeader playItem:playItem];
            };
        }else{
            cell.SelectBUt.hidden = YES;
        }
        
        //是否正在播放
        if ([[AmazonMusicBoxManager shared] trackIsPlaying:playHeader playItem:playItem])
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_HIGH_COLOR subLabColor:THEME_LIGHT_COLOR];
        }
        else
        {
            cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:THEME_DEFAULT_COLOR subLabColor:THEME_LIGHT_COLOR];
        }
        
        //是否过滤
        if ([AmazonMusicBoxManager shared].isExplicit)
        {
            if (playItem.isExplicit)
            {
                cell.descriptionLabel.attributedText = [AmazonMusicMethod attributedStrLab:playItem.trackName SubLab:playItem.subTitle itemLabColor:[UIColor grayColor] subLabColor:[UIColor grayColor]];
                return cell;
            }
        }
        return cell;
    }
    return nil;
}


//headerView和footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter)
    {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FootersView" forIndexPath:indexPath];
        reusableView = footerview;
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    LPAmazonMusicPlayItem *playMode = self.playArray[indexPath.row];
    
    LPAmazonMusicPlayHeader *playHeader;
    int trackCount = 0;
    for (LPAmazonMusicPlayHeader *header in self.playHeaderArray) {
        trackCount = trackCount + header.perPage;
        if (indexPath.row < trackCount) {
            playHeader = header;
            break;
        }
    }
    NSLog(@"%@", [NSString stringWithFormat:@"amazonMusic : nextpath: %@",playMode.navigationPath]);
    
    //需要导航到下一页，下一页依然是展示页不可以播放
    if (playMode.navigation && !playMode.playable)
    {
        AmazonMusicSourceViewController *controller = [[AmazonMusicSourceViewController alloc] init];
        controller.playItem = playMode;
        controller.playHeader = playHeader;
        
        //要显示的类型
        NSString *nextNavTag = [playMode.contentType ? playMode.contentType : playMode.trackName uppercaseString];
        if ([nextNavTag rangeOfString:@"STATION"].location != NSNotFound || [nextNavTag rangeOfString:@"ALBUM"].location != NSNotFound)
        {
            controller.cellType = AmazonMusic_Ablum_Type;
        }
        else if ([nextNavTag rangeOfString:@"PLAYLIST"].location != NSNotFound )
        {
            controller.cellType = AmazonMusic_PlayList_Type;
        }
        else
        {
            controller.cellType = AmazonMusic_Songs_Type;
        }
        [self.navigationController pushViewController:controller animated:YES];
        
    //需要导航到下一页，下一页是歌曲列表，直接播放
    }
    else if (playMode.navigation && playMode.playable)
    {
        AmazonMusicSongListViewController * vc = [[AmazonMusicSongListViewController alloc]init];
        vc.playItem = playMode;
        vc.playHeader = playHeader;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    //不可以导航下一页，当前为歌曲，直接播放
    }
    else if (playMode.playable && !playMode.navigation)
    {
        //检查过滤功能
        if ([AmazonMusicBoxManager shared].isExplicit)
        {
            if (playMode.isExplicit)
            {
                [[AmazonMusicMethod sharedInstance] showExplicitAlertView:0 isSetting:NO Block:^(int ret) {
                    if(ret == 0)
                    {
                        [self.collectionView reloadData];
                    }
                }];
                return;
            }
        }
        //检查播放链接
        if (playMode.trackUrl.length == 0)
        {
            if (playMode.audioError) {
                [[AmazonMusicMethod sharedInstance] showAlertRequestError:playMode.audioError Block:^(int ret, NSDictionary * _Nonnull result) {
                    
                    if (ret == 1 && result[@"url"])
                    {
                        [[AmazonMusicMethod sharedInstance] openWebView:result[@"url"]];
                    }
                }];
                return;
            }
        }
        //直接播放
        [self showHud:@""];
        [[AmazonMusicBoxManager shared] startPlayHeader:playHeader playItem:playMode Block:^(int ret, NSString * _Nonnull message) {
            
            [self hideHud:@"" afterDelay:6 type:0];
            
            if (ret == 1)
            {
                [self.view makeToast:message];
            }
            else
            {
                [self.collectionView reloadData];
            }
        }];
    }
    else
    {
        //歌曲出问题了，展示错误提示
        NSString *errorStr = AMAZONLOCALSTRING(@"primemusic_We_re_sorry__this_content_is_no_longer_available");
        if (playMode.audioError)
        {
            NSString *error = playMode.audioError[@"explanation"];
            if (error.length > 0)
            {
                errorStr = error;
            }
        }
        [self.view makeToast:errorStr duration:2 position:@"CSToastPositionCenter"];
    }
}


///more
- (void)moreActionHeader:(LPAmazonMusicPlayHeader *)playHeader playItem:(LPAmazonMusicPlayItem *)playItem{
    
    //是否过滤
    if ([AmazonMusicBoxManager shared].isExplicit)
    {
        if (playItem.isExplicit)
        {
            [[AmazonMusicMethod sharedInstance] showExplicitAlertView:0 isSetting:NO Block:^(int ret) {
                if(ret == 0)
                {
                    [self.collectionView reloadData];
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

- (AmazonMusicErrorView *)errorView
{
    if (!_errorView) {
        _errorView = [[AmazonMusicErrorView alloc] initWithFrame:CGRectMake(10, (SCREENHEIGHT - 64 - 200)/2.0, SCREENWIDTH - 20, 200)];
        [self.view insertSubview:_errorView aboveSubview:self.collectionView];
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

- (NSMutableArray *)playArray
{
    if (!_playArray){
        _playArray = [[NSMutableArray alloc] init];
    }
    return _playArray;
}

- (NSMutableArray *)playHeaderArray
{
    if (!_playHeaderArray) {
        _playHeaderArray = [[NSMutableArray alloc] init];
    }
    return _playHeaderArray;
}

- (AmazonMusicNavigationSet *)navBarMethod
{
    if (!_navBarMethod) {
        _navBarMethod = [[AmazonMusicNavigationSet alloc] init];
        _navBarMethod.delegate = self;
    }
    return _navBarMethod;
}

@end
