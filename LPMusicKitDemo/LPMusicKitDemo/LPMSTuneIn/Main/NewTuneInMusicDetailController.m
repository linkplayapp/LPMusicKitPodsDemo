//
//  NewTuneInMusicDetailController.m
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMusicDetailController.h"
#import "NewTuneInMusicDetailHead.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInMainTableListCell.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"
#import "PresetViewController.h"
#import "NewTuneInPublicMethod.h"
#import "NewTuneInConfig.h"
#import "MJRefresh.h"

@interface NewTuneInMusicDetailController () <MJRefreshBaseViewDelegate,NewTuneInMusicDetailHeadDelegate,NewTuneInPremiumControllerDelegate>
{
    MJRefreshHeaderView *headerView;
    NSString *_selectId;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) LPTuneInRequest *request;

//头部
@property (nonatomic, strong) LPTuneInPlayHeader *playHeader;
@property (nonatomic, strong) NSMutableDictionary *headerDict;
@property (strong, nonatomic) NewTuneInMusicDetailHead *detailHeader;

//节目列表
@property (nonatomic, strong) NSMutableArray *programeArray;
//列表详情
@property (nonatomic, strong) NSMutableDictionary *itemCellDict;

@property (strong, nonatomic) UILabel *statuLab;

@end

@implementation NewTuneInMusicDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //request
    [self requestData];
    
    //navgation
    [self setNavagtion];
}

- (void)setNavagtion
{
    //footer
    self.tableView.tableFooterView = [self addFooterView];
   
    //标题
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 18)];
    titleImage.image = [UIImage imageNamed:@"tunein_logo_title"];
    
    self.navigationItem.titleView = titleImage;
    
    //refresh
    headerView = [MJRefreshHeaderView header];
    headerView.scrollView = self.tableView;
    headerView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == headerView)
        {
            [headerView endRefreshing];
            [self requestData];
        }
    });
}

#pragma mark -- request data
- (void)requestData
{
    self.statuLab.hidden = YES;
    if (self.url.length > 0)
    {
        [self showHud:nil];
        __weak typeof(self) weakSelf = self;
        [self.request lpTuneInGetSubItemSingleContentDetails:self.url success:^(NSArray * _Nonnull list) {
            
            [weakSelf hideHud:@"" afterDelay:0 type:0];
            [weakSelf updataHeaderViewAndCell:list.firstObject];
        } failure:^(NSError * _Nonnull error) {
            
            NSString *message = [NewTuneInPublicMethod failureResultError:error];
            [weakSelf hideHud:message afterDelay:2.0 type:0];
            if (weakSelf.playHeader.children.count == 0)
            {
                [weakSelf showStatuLab:YES Text:message Delay:2.0];
            }
        }];
    }
}

- (void)showStatuLab:(BOOL)show Text:(NSString *)text Delay:(NSTimeInterval)delay
{
    if (show)
    {
        if (delay > 0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.statuLab.hidden = NO;
                self.statuLab.text = text;
            });
        }
        else
        {
            self.statuLab.hidden = NO;
            self.statuLab.text = text;
        }
    }
    else
    {
        self.statuLab.hidden = YES;
    }
}

- (void)requestPrograme:(NSString *)url
{
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInGetDifferentTypesContentList:url success:^(NSArray * _Nonnull list) {
        weakSelf.itemCellDict = [[NSMutableDictionary alloc] init];
        for (LPTuneInPlayHeader *playHeader in list) {
            
            NSArray *children = playHeader.children;
            for (LPTuneInPlayItem *playItem in children) {
                
               NSDictionary *cellHeightDict = [NewTuneInPublicMethod dealDescriptionHeightWithPlayItem:playItem isOpenMore:NO];
               
               [weakSelf.itemCellDict setValue:@{
                   @"openMore":@(NO),
                   @"cellDict":cellHeightDict
               } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];
            }
        }
        
        [weakSelf.programeArray removeAllObjects];
        [weakSelf.programeArray addObjectsFromArray:list];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        [weakSelf hideHud:message afterDelay:2.0 type:0];
    }];
}

- (void)updataHeaderViewAndCell:(LPTuneInPlayHeader *)playHeader
{
    //请求programe
    LPTuneInPlayItem *playItem = playHeader.children.firstObject;
    NSDictionary *programe = playItem.Pivots;
    NSString *url = programe[@"Contents"] ? programe[@"Contents"][@"Url"]: @"";
    [self requestPrograme:url];

    //header
    self.playHeader = playHeader;
    if (self.playHeader.children.count > 0){
        [self showStatuLab:NO Text:@"" Delay:0];
    }else{
        [self showStatuLab:YES Text:LOCALSTRING(@"newtuneIn_No_results") Delay:0];
    }
   
    NSMutableDictionary *dict = [self setHeadViewMiddleHide:NO DetailHide:NO];
    BOOL currentPlay = [self isCurrentPlaying];
   
    //更新header dict
    [self.headerDict removeAllObjects];
    [self.headerDict setValue:dict forKey:@"dict"];
    [self.headerDict setValue:@(NO) forKey:@"infoOpen"];
    [self.headerDict setValue:@(NO) forKey:@"detailOpen"];
    [self.headerDict setValue:@(currentPlay) forKey:@"currentPlay"];
    [self setTableViewHeader:playItem localPlayState:@""];
    
    //更新Favorite缓存
    NSString *songId = playItem.trackId;
    NSDictionary *actions = playItem.Follow;
    BOOL favorite = actions ? [actions[@"IsFollowing"] boolValue]:NO;
    [self sendDeviceFavoriteStateWithId:songId follow:favorite];
}

- (void)setTableViewHeader:(LPTuneInPlayItem *)playItem localPlayState:(NSString *)localPlayState
{
    NSMutableDictionary *dict = self.headerDict[@"dict"];
    BOOL infoOpen = [self.headerDict[@"infoOpen"] intValue];
    BOOL detailOpen = [self.headerDict[@"detailOpen"] intValue];
    BOOL currentPlay = [self.headerDict[@"currentPlay"] intValue];
    
    CGFloat currentHeight = [dict[@"headerHeight"] intValue] + 1;
    CGFloat height = self.detailHeader.frame.size.height;
    
    if (currentHeight != height)
    {
        self.detailHeader.frame = CGRectMake(0, 0, SCREENWIDTH, currentHeight);
    }
    self.detailHeader.localPlayState = localPlayState;
    self.detailHeader.infoMoreOpen = infoOpen;
    self.detailHeader.detailMoreOpen = detailOpen;
    self.detailHeader.currentPlay = currentPlay;
    self.detailHeader.dict = dict;
    self.detailHeader.playItem = playItem;
    self.tableView.tableHeaderView = self.detailHeader;
    [self.tableView reloadData];
}

- (NSMutableDictionary *)setHeadViewMiddleHide:(BOOL)middle DetailHide:(BOOL)detail
{
    LPTuneInPlayItem *playItem = self.playHeader.children.firstObject;
    NSMutableDictionary *detailDict = [[NSMutableDictionary alloc] init];
    CGFloat headHeight = 196;
    NSString *str = playItem.Description;
   
    CGSize detailSize;
    if (str.length > 0)
    {
        CGSize newSize = [self sizeWithText:str font:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(MAXFLOAT, 20)];
        
        detailSize = [self sizeWithText:str font:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(SCREENWIDTH - 26, (newSize.height + 1) * 4)];
        headHeight = headHeight + 18 + detailSize.height + 1;
        [detailDict setObject:@(detailSize.height) forKey:@"detailHeight"];
    }
    
    //加入中间的点击
    if (middle)
    {
        if (str.length > 0)
        {
            headHeight = headHeight + (48 + 20) - 18;
        }
        else
        {
            headHeight = headHeight + (48 + 20) - 24;
        }
        
        [detailDict setObject:@(48 + 20) forKey:@"infoHeight"];
    }
    
    //文字更过
    if (detail && str.length > 0)
    {
        CGSize newSize = [self sizeWithText:str font:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(SCREENWIDTH - 26, SCREENHEIGHT)];
        headHeight = headHeight + newSize.height - detailSize.height;
        [detailDict setObject:@(newSize.height) forKey:@"detailHeight"];
    }
    [detailDict setObject:str.length > 0 ?str:@"" forKey:@"detail"];
    [detailDict setObject:@(headHeight + 5) forKey:@"headerHeight"];
    
    return detailDict;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return  [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (CGSize)sizeLineWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return  [text boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine attributes:attrs context:nil].size;
}


#pragma mark --- NewTuneInMusicDetailHeadDelegate
- (void)userInfoMoreOpen:(BOOL)infoOpen DetailMoreOpen:(BOOL)detailOpen
{
    NSMutableDictionary *dict = [self setHeadViewMiddleHide:infoOpen DetailHide:detailOpen];
    BOOL currentPlay = [self isCurrentPlaying];
    //更新header dict
    [self.headerDict removeAllObjects];
    [self.headerDict setValue:dict forKey:@"dict"];
    [self.headerDict setValue:@(infoOpen) forKey:@"infoOpen"];
    [self.headerDict setValue:@(detailOpen) forKey:@"detailOpen"];
    [self.headerDict setValue:@(currentPlay) forKey:@"currentPlay"];
    
    [self setTableViewHeader:self.playHeader.children.firstObject localPlayState:@""];
}

- (void)playButtonActionIsCurrentPlay:(BOOL)currentPlay
{
    if (self.programeArray.count > 0) {
        LPTuneInPlayHeader *playHeader = self.programeArray[0];
        NSMutableArray *list = playHeader.children;
        if (list.count == 0) {
            [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_This_content_cannot_be_played_")];
            return;
        }
        LPTuneInPlayItem *playItem = list[0];
        NSString *nextAction = playItem.nextAction;
        
        //browse
        if ([nextAction isEqualToString:@"3"]) {
            if (currentPlay){
                
                BOOL playStatu;
                if (CURBOX.deviceInfo.playStatus == LP_PLAYER_STATE_PLAYING){
                    playStatu = NO;
                    CURBOX.deviceInfo.playStatus = LP_PLAYER_STATE_PAUSED_PLAYBACK;
                    [CURBOX.getPlayer pause:nil];
                }else{
                    playStatu = YES;
                    CURBOX.deviceInfo.playStatus = LP_PLAYER_STATE_PLAYING;
                    [CURBOX.getPlayer play:nil];
                }
                [self setTableViewHeader:self.playHeader.children.firstObject localPlayState:[NSString stringWithFormat:@"%@", playStatu?@"play":@"stop"]];
            }else{
                
                if (self.programeArray.count > 0) {
                    LPTuneInPlayHeader *playHeader = self.programeArray[0];
                    [self playMusicWithPlayHeader:playHeader index:0];
                }
            }
            return;
        }
    }
    [[UIApplication sharedApplication].windows.firstObject makeToast:LOCALSTRING(@"newtuneIn_This_content_cannot_be_played_")];
}

- (void)favoriteButtonAction:(BOOL)favorite GuideId:(nonnull NSString *)guideId
{
    __weak typeof(self) weakSelf = self;
    if (favorite)
    {
        [self showHud:@""];
        [self.request lpTuneInDeleteFavoritesWithTrackId:guideId success:^(NSArray * _Nonnull list) {
            
            [weakSelf hideHud:@"" afterDelay:0 type:0];
            LPTuneInPlayItem *playItem = weakSelf.playHeader.children.firstObject;
            NSMutableDictionary *follow = [playItem.Follow mutableCopy];
            [follow setValue:@(NO) forKey:@"IsFollowing"];
            playItem.Follow = follow;
            weakSelf.playHeader.children = [@[playItem] mutableCopy];
            [weakSelf setTableViewHeader: playItem localPlayState:@""];
            [weakSelf sendDeviceFavoriteStateWithId:guideId follow:YES];
            
        } failure:^(NSError * _Nonnull error) {
        
            NSString *message = [NewTuneInPublicMethod failureResultError:error];
            [weakSelf hideHud:message afterDelay:2.0 type:0];
        }];
    }
    else
    {
        [self showHud:@""];
        [self.request lpTuneInAddFavoritesWithTrackId:guideId success:^(NSArray * _Nonnull list) {
            
            [weakSelf hideHud:@"" afterDelay:0 type:0];
            LPTuneInPlayItem *playItem = weakSelf.playHeader.children.firstObject;
            NSMutableDictionary *follow = [playItem.Follow mutableCopy];
            [follow setValue:@(YES) forKey:@"IsFollowing"];
            playItem.Follow = follow;
            weakSelf.playHeader.children = [@[playItem] mutableCopy];
            [weakSelf setTableViewHeader:playItem localPlayState:@""];
            [weakSelf sendDeviceFavoriteStateWithId:guideId follow:YES];
        } failure:^(NSError * _Nonnull error) {
            
            NSString *message = [NewTuneInPublicMethod failureResultError:error];
            [weakSelf hideHud:message afterDelay:2.0 type:0];
        }];
    }
}

- (void)sendDeviceFavoriteStateWithId:(NSString *)Id follow:(BOOL)follow
{
    if (follow) {
        [[NewTuneInPublicMethod shared] addFavoriteWithId:Id];
    }else{
        [[NewTuneInPublicMethod shared] removeFavoriteWithId:Id];
    }
    [self refreshUI:YES];
}

#pragma mark -- playView changed
-(BOOL)isNeedKVOPlayingState
{
    return YES;
}

-(void)playingStateChanged
{
    [self playStatuChanged];
}

- (void)playViewDismiss
{
    [super playViewDismiss];

    LPTuneInPlayItem *playItem = self.playHeader.children.firstObject;
    NSString *state = [[NewTuneInPublicMethod shared] selectFavoriteWithId:playItem.trackId];

    NSDictionary *action = playItem.Follow;
    BOOL currentFavorite = action ? [action[@"IsFollowing"] boolValue]: NO;

    if (![state isEqualToString:@"2"]) {
        BOOL cacheFavorite = [state isEqualToString:@"1"] ? YES:NO;
        if (cacheFavorite != currentFavorite) {
            [headerView beginRefreshing];
            return;
        }
    }
}

- (void)playStatuChanged
{
    if (self.programeArray.count == 0) {
        return;
    }

    int playState = CURBOX.deviceInfo.playStatus;
    BOOL currentPlay = [self isCurrentPlaying];

    // transition时不受影响，优化UI
    if (currentPlay){
        if (self.detailHeader.playing_State == LP_PLAYER_STATE_TRANSITIONING && (playState == LP_PLAYER_STATE_PAUSED_PLAYBACK || playState == LP_PLAYER_STATE_STOPPED)) {
            return;
        }
    }

    [self.headerDict setValue:@(currentPlay) forKey:@"currentPlay"];
    [self setTableViewHeader:self.playHeader.children.firstObject localPlayState:@"play"];
}

#pragma mark - UITableViewDelegate && UITabelViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.programeArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LPTuneInPlayHeader *playHeader = self.programeArray[section];
    NSMutableArray *list = playHeader.children;
    if (list)
    {
        return list.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.programeArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
   
    NSDictionary *dict = playItem.Presentation;
    if ([dict[@"Layout"] isEqualToString:@"OnDemandTile"])
    {
        NSString *kCellIdentifier = @"NewTuneInMainTableListCell";
        NewTuneInMainTableListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInMainTableListCell" owner:self options:nil] lastObject];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        NSMutableDictionary *itemCellDict = [self.itemCellDict objectForKey:[NSString stringWithFormat:@"%@%@",playItem.trackId,playItem.trackName]];
        NSMutableDictionary *cellDict = itemCellDict[@"cellDict"] ? itemCellDict[@"cellDict"] :@{};
        
        cell.titleHeightCon.constant = [cellDict[@"titleHeight"] integerValue];
        cell.title.text = playItem.trackName;
        cell.time.text = cellDict[@"startTime"];
       
        if ([NewTuneInPublicMethod isCurrentPlayingPlayItem:playItem])
        {
            cell.title.textColor = [UIColor lightGrayColor];
        }
        else
        {
            cell.title.textColor = [UIColor whiteColor];
        }
        
        BOOL isOpenMore = [itemCellDict[@"openMore"] boolValue];
        if (isOpenMore)
        {
            [cell.moreButton setImage:[UIImage imageNamed:@"tunein_tital_more_s_n"] forState:UIControlStateNormal];
            cell.duration.hidden = NO;
            cell.duration.text = cellDict[@"time"];
            cell.curationHeightCon.constant = [cellDict[@"durationHeight"] intValue];
        }
        else
        {
            [cell.moreButton setImage:[UIImage imageNamed:@"tunein_tital_more_s_d"] forState:UIControlStateNormal];
            cell.duration.hidden = YES;
        }
        
        cell.presentButton.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        cell.block = ^(int type){
            
            if (type == 0) {
                //改变open
                BOOL newOpenMore = !isOpenMore;
            
                //计算高度
                NSDictionary *cellHeightDict = [NewTuneInPublicMethod dealDescriptionHeightWithPlayItem:playItem isOpenMore:newOpenMore];
                
                [weakSelf.itemCellDict setValue:@{
                    @"openMore":@(newOpenMore),
                    @"cellDict":cellHeightDict
                } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];
              
                [weakSelf.tableView reloadData];
            }
            else
            {
                [self presetMusicWithModel:playHeader index:indexPath.row];
            }
        };
        return cell;
    }
    else if (playItem.trackImage.length > 0)
    {
        NSString *kCellIdentifier = @"NewTuneInBrowseDetailTableViewCell";
        NewTuneInBrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInBrowseDetailTableViewCell" owner:self options:nil] lastObject];
        }
        cell.backgroundColor = [UIColor clearColor];
        [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[UIImage imageNamed:@"tunein_album_logo"]];
        
        if ([NewTuneInPublicMethod isCurrentPlayingPlayItem:playItem])
        {
            cell.titleLab.attributedText = [NewTuneInPublicMethod attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor lightGrayColor] subLabColor:[UIColor lightGrayColor]];
        }
        else
        {
            cell.titleLab.attributedText = [NewTuneInPublicMethod attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor whiteColor] subLabColor:[UIColor lightGrayColor]];
        }
        
        cell.presentButton.hidden = YES;
        
        return cell;
    }
    else
    {
        NSString *kCellIdentifier = @"NewTuneInBrowseTableViewCell";
        NewTuneInBrowseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInBrowseTableViewCell" owner:self options:nil] lastObject];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.titleLab.text = playItem.trackName;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.programeArray[indexPath.section];
    [self playMusicWithPlayHeader:playHeader index:indexPath.row];
    [self.tableView reloadData];
}

- (void)playMusicWithPlayHeader:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    NSMutableArray *list = playHeader.children;
    if (list.count <= index) {
        return;
    }
    
    LPTuneInPlayItem *playItem = list[index];
    NSString *nextAction = playItem.nextAction;
    
    //browse
    if ([nextAction isEqualToString:@"1"]) {
       
        NewTuneInBrowseDetailController *controller = [[NewTuneInBrowseDetailController alloc] init];
        controller.name = playItem.trackName;
        controller.url = playItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //detail
    }else if ([nextAction isEqualToString:@"2"]){
    
        NewTuneInMusicDetailController *controller = [[NewTuneInMusicDetailController alloc] init];
        controller.url = playItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //play
    }else if ([nextAction isEqualToString:@"3"]){
        
       [NewTuneInPublicMethod startPlayMusicWithPlayItem:playItem header:playHeader];
    //premium
    }else if ([nextAction isEqualToString:@"4"]){
        
        [self premiumAction];
    //error
    }else if ([nextAction isEqualToString:@"5"]){

        [self.view makeToast:LOCALSTRING(@"newtuneIn_This_show_will_be_available_later__Please_come_back_then_")];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.programeArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    
    NSMutableDictionary *itemCellDict = [self.itemCellDict objectForKey:[NSString stringWithFormat:@"%@%@",playItem.trackId,playItem.trackName]];
    NSMutableDictionary *cellDict = itemCellDict[@"cellDict"] ? itemCellDict[@"cellDict"] :@{};
    return [cellDict[@"height"] floatValue];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    headView.backgroundColor = [UIColor clearColor];
    
    if (self.playHeader.children.count == 0)
    {
        return headView;
    }

    //不能播放内容
    LPTuneInPlayHeader *playHeader = self.programeArray[section];
    NSMutableArray *list = playHeader.children;
    if (list.count == 0)
    {
        UILabel *noCanPlayLab = [[UILabel alloc] init];
        
        noCanPlayLab.textColor = HWCOLORA(80, 227, 194, 1);
        noCanPlayLab.layer.borderColor = HWCOLORA(80, 227, 194, 1).CGColor;
        noCanPlayLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        noCanPlayLab.textAlignment = NSTextAlignmentCenter;
        
        NSString *titleStr = [NSString stringWithFormat:@" %@ ",playHeader.headTitle.length > 0 ? playHeader.headTitle:LOCALSTRING(@"newtuneIn_This_show_will_be_available_later__Please_come_back_then_")];
        noCanPlayLab.text = titleStr;
        noCanPlayLab.layer.borderWidth = 1;
        noCanPlayLab.layer.cornerRadius = 6;
        noCanPlayLab.layer.masksToBounds = YES;
        noCanPlayLab.numberOfLines = 0;
        
        CGFloat headHeight = [self calculateRowWidth:titleStr font:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        noCanPlayLab.frame = CGRectMake(8, 24, SCREENWIDTH - 16, headHeight > 82 ? headHeight: 82);
        headView.frame = CGRectMake(0, 0, SCREENWIDTH,headHeight > 82 ? headHeight + 24 : 106);
        [headView addSubview:noCanPlayLab];
        return headView;
    }
  
    if (!(playHeader.headTitle.length > 0))
    {
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return headView;
    }
    
    //premiium
    headView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeSystem];
    headBut.frame = CGRectMake(16, 0, SCREENWIDTH - 16, 50);
    
    if ([playHeader.Premium isEqualToString:@"1"])
    {
        UIButton *premiumButton = [self createPremiumButton];
        [headView addSubview:premiumButton];
        headBut.frame = CGRectMake(16, 0, SCREENWIDTH - 98 - 37, 50);
    }
    
    //title
    headBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headBut.tag = section + 100;
    headBut.backgroundColor = [UIColor clearColor];
    [headBut setTitle:playHeader.headTitle forState:UIControlStateNormal];
    
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    
    if (navigationStr.length > 0 || moreUrl.length > 0)
    {
        [headBut setImage:[UIImage imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
        [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        headBut.userInteractionEnabled = YES;
    }
    else
    {
        headBut.userInteractionEnabled = NO;
    }
    [headBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    headBut.tintColor = [UIColor whiteColor];
    headBut.titleLabel.font = [UIFont systemFontOfSize:18];
    [headBut setbuttonType:LZCategoryTypeLeft];
    [headView addSubview:headBut];
    return headView;
}

- (UIButton *)createPremiumButton
{
    UIButton *premiumButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 98 - 20, 13, 98, 24)];
    premiumButton.backgroundColor = [UIColor clearColor];
    [premiumButton setImage:[UIImage imageNamed:@"tuneinPremiumBadge"] forState:UIControlStateNormal];
    [premiumButton addTarget:self action:@selector(premiumAction) forControlEvents:UIControlEventTouchUpInside];
    return premiumButton;
}

- (void)premiumAction
{
    NewTuneInPremiumController *premiumController = [[NewTuneInPremiumController alloc] init];
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:premiumController];
    navcontroller.modalPresentationStyle = UIModalPresentationFullScreen;
    premiumController.delegate = self;
    [self presentViewController:navcontroller animated:YES completion:nil];
}

- (void)newTuneInPremiumControllerResult:(BOOL)result
{
    if (result)
    {
        [self requestData];
    }
}

- (CGFloat)calculateRowWidth:(NSString *)string font:(UIFont *)font{
    NSDictionary *dic = @{NSFontAttributeName:font}; //指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREENWIDTH, 200) options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    LPTuneInPlayHeader *playHeader = self.programeArray[section];
    NSMutableArray *list = playHeader.children;
    
    if (list.count == 0)
    {
        NSString *titleStr = [NSString stringWithFormat:@" %@ ",playHeader.headTitle.length > 0 ? playHeader.headTitle:LOCALSTRING(@"newtuneIn_This_show_will_be_available_later__Please_come_back_then_")];
        CGFloat headHeight = [self calculateRowWidth:titleStr font:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        return headHeight > 82 ? headHeight + 24 : 106;
    }
    return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    LPTuneInPlayHeader *playHeader = self.programeArray[section];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";

    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    if (navigationStr.length > 0 || moreUrl.length > 0)
    {
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
        NSString *butTitle = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Title"] :@"";
        if (butTitle.length == 0)
        {
            butTitle = more[@"DisplayName"] ? more[@"DisplayName"] : @"";
        }
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
        if (butTitle.length > 0)
        {
            UIButton *headBut = [UIButton buttonWithType:UIButtonTypeSystem];
            headBut.backgroundColor = [UIColor clearColor];
            headBut.frame = CGRectMake(16, 10, SCREENWIDTH - 32, 40);
            [headBut setTitle:[NSString stringWithFormat:@"%@",more[@"DisplayName"] ? more[@"DisplayName"] : @""] forState:UIControlStateNormal];
            [headBut setImage:[UIImage imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
            [headBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            headBut.tintColor = [UIColor whiteColor];
            headBut.titleLabel.font = [UIFont systemFontOfSize:18];
            [headBut setbuttonType:LZCategoryTypeLeft];
            [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
            headBut.tag = section + 100;
            [footView addSubview:headBut];
        }
        return footView;
    }
    else
    {
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return footView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    LPTuneInPlayHeader *playHeader = self.programeArray[section];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    if (navigationStr.length > 0 || moreUrl.length > 0)
    {
        return 50;
    }
    return 0;
}

- (void)moreAction:(UIButton *)sender
{
    LPTuneInPlayHeader *playHeader = self.programeArray[sender.tag - 100];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more[@"Url"];
    
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    
    if (navigationStr.length > 0)
    {
        NewTuneInBrowseDetailController *controller = [[NewTuneInBrowseDetailController alloc] init];
        controller.name = playHeader.headTitle;
        controller.url = navigationStr;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (moreUrl.length > 0)
    {
        NewTuneInMoreViewController *controller = [[NewTuneInMoreViewController alloc] init];
        controller.name = playHeader.headTitle;
        controller.url = moreUrl;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    NSMutableArray *array = playHeader.children;
    LPTuneInPlayItem *playItem = array[index];
    
}

- (BOOL)isCurrentPlaying
{
    NSString *songId = CURBOX.mediaInfo.songId;
    for (LPTuneInPlayHeader *playHeader in self.programeArray) {
        for (LPTuneInPlayItem *playItem in playHeader.children) {
           if ([[songId uppercaseString] isEqualToString:[playItem.trackId uppercaseString]])
           {
               return YES;
           }
        }
    }
    return NO;
}

- (LPTuneInPlayHeader *)playHeader
{
    if (!_playHeader) {
        _playHeader = [[LPTuneInPlayHeader alloc] init];
    }
    return _playHeader;
}

- (LPTuneInRequest *)request
{
    if (!_request) {
        _request = [[LPTuneInRequest alloc] init];
    }
    return _request;
}

- (NSMutableDictionary *)headerDict
{
    if (!_headerDict) {
        _headerDict = [[NSMutableDictionary alloc] init];
    }
    return _headerDict;
}

- (UILabel *)statuLab
{
    if (!_statuLab) {
        _statuLab = [[UILabel alloc] initWithFrame:CGRectMake(10, (SCREENHEIGHT - 60 - 196)/2.0 - 20, SCREENWIDTH - 20, 60)];
        _statuLab.font = [UIFont systemFontOfSize:16];
        _statuLab.textColor = [UIColor whiteColor];
        _statuLab.numberOfLines = 0;
        _statuLab.hidden = YES;
        _statuLab.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:_statuLab];
    }
    return _statuLab;
}

- (NewTuneInMusicDetailHead *)detailHeader
{
    if (!_detailHeader) {
        _detailHeader = [[NewTuneInMusicDetailHead alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0)];
        _detailHeader.delegate = self;
    }
    return _detailHeader;
}

- (NSMutableArray *)programeArray
{
    if (!_programeArray) {
        _programeArray = [[NSMutableArray alloc]  init];
    }
    return _programeArray;
}

@end
