//
//  NewTuneInMoreViewController.m
//  iMuzo
//
//  Created by lyr on 2019/5/22.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMoreViewController.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInConfig.h"
#import "UIImageView+WebCache.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInBrowseDetailController.h"
#import "MJRefresh.h"
#import "NewTuneInMainTableListCell.h"
#import "NewTuneInPremiumController.h"

#define CONTROOLER_NAME @"NewTuneInMoreViewController"

@interface NewTuneInMoreViewController ()<MJRefreshBaseViewDelegate, NewTuneInPremiumControllerDelegate>
{
    MJRefreshHeaderView *headerView;
    MJRefreshFooterView *footerView;
}
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) LPTuneInRequest *request;
@property (strong, nonatomic) NSMutableDictionary *itemCellDict;
@property (strong, nonatomic) UILabel *statuLab;
@property (strong, nonatomic) NSString *nextUrl;

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewTuneInMoreViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.nextUrl.length == 0){
        footerView.hidden = YES;
    }else{
        footerView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.backImage.image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
    self.title = self.name;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :newTuneIn_DEFAULT_COLOR,NSFontAttributeName : [UIFont systemFontOfSize:17]}];

    //refresh
    headerView = [MJRefreshHeaderView header];
    headerView.scrollView = self.tableView;
    headerView.delegate = self;
   
    self.tableView.tableFooterView = [self addFooterView];
    footerView = [MJRefreshFooterView footer];
    footerView.scrollView = self.tableView;
    footerView.delegate = self;
    
    [self requestData:self.url];
}

- (void)requestData:(NSString *)url
{
    [self showHud:@""];
    self.statuLab.hidden = YES;
    [self.request tuneInGetSingleTypeContentList:url success:^(NSArray * _Nonnull list) {
        
         [self hideHud:@"" afterDelay:0 type:MBProgressHUDModeIndeterminate];
        
        self.itemCellDict = [[NSMutableDictionary alloc] init];
        
        for (LPTuneInPlayHeader *playHeader in list) {
            
            NSArray *children = playHeader.children;
            for (LPTuneInPlayItem *playItem in children) {
                
               NSDictionary *cellHeightDict = [[NewTuneInMusicManager shared] dealDescriptionCellHeight:playItem isOpenMore:NO];
               
               [self.itemCellDict setValue:@{
                   @"isOpen":@(NO),
                   @"cellDict":cellHeightDict
               } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];
            }
        }
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:list];
        [self.tableView reloadData];
        [self hideRefresh];
        
        //是否需要分页
        LPTuneInPlayHeader *playHeader = list.lastObject;
        self.nextUrl = playHeader.morePivots ? playHeader.morePivots :@"";
        if (self.nextUrl.length == 0)
        {
            self->footerView.hidden = YES;
        }else{
            self->footerView.hidden = NO;
        }

        if (self.dataArray.count > 0)
        {
            [self showStatuLab:NO Text:@"" Delay:0];
        }else{
            [self showStatuLab:YES Text:TUNEINLOCALSTRING(@"newtuneIn_No_results") Delay:0];
        }
    } failure:^(NSError * _Nonnull error) {
        
        NSString *message;
        if (error.code == -1001) {
            message =TUNEINLOCALSTRING(@"newtuneIn_Time_out");
        }else{
            message =TUNEINLOCALSTRING(@"newtuneIn_Fail");
        }
        [self hideHud:message afterDelay:2.0 type:MBProgressHUDModeIndeterminate];
        [self hideRefresh];
        if (self.dataArray.count == 0)
        {
            [self showStatuLab:YES Text:message Delay:2.0];
        }
    }];
}

- (void)showStatuLab:(BOOL)show Text:(NSString *)text Delay:(NSTimeInterval)delay
{
    if (show){
        if (delay > 0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.statuLab.hidden = NO;
                self.statuLab.text = text;
            });
        }else{
            self.statuLab.hidden = NO;
            self.statuLab.text = text;
        }
    }else{
        self.statuLab.hidden = YES;
    }
}

- (void)hideRefresh
{
    if (headerView.isRefreshing){
        [headerView endRefreshing];
    }
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == self->headerView)
        {
            [self requestData:self.url];
        }else{
            if (self.nextUrl.length > 0){
                
                [self showHud:@""];
                
                [self.request tuneInGetSingleTypeContentList:self.nextUrl success:^(NSArray * _Nonnull list) {

                    [self hideHud:@"" afterDelay:0 type:MBProgressHUDModeIndeterminate];
                    
                    for (LPTuneInPlayHeader *playHeader in list) {
                        
                        NSArray *children = playHeader.children;
                        for (LPTuneInPlayItem *playItem in children) {
                            
                           NSDictionary *cellHeightDict = [[NewTuneInMusicManager shared] dealDescriptionCellHeight:playItem isOpenMore:NO];
                           
                           [self.itemCellDict setValue:@{
                               @"isOpen":@(NO),
                               @"cellDict":cellHeightDict
                           } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];
                        }
                    }
                    [self.dataArray addObjectsFromArray:list];
                    [self->footerView endRefreshing];
                    
                   //分页
                   LPTuneInPlayHeader *playHeader = list.lastObject;
                   self.nextUrl = playHeader.morePivots ? playHeader.morePivots :@"";
                   if (self.nextUrl.length == 0)
                   {
                       self->footerView.hidden = YES;
                   }else{
                       self->footerView.hidden = NO;
                   }
                   [self.tableView reloadData];

                } failure:^(NSError * _Nonnull error) {
                    
                    NSString *message;
                    if (error.code == -1001) {
                        message =TUNEINLOCALSTRING(@"newtuneIn_Time_out");
                    }else{
                        message =TUNEINLOCALSTRING(@"newtuneIn_Fail");
                    }
                    [self hideHud:message afterDelay:2.0 type:MBProgressHUDModeIndeterminate];
                    [self->footerView endRefreshing];
                }];
                
            }else{
                [self->footerView endRefreshing];
            }
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

- (NSString *)currentDeviceId
{
    return [[NewTuneInMusicManager shared] deviceId];
}

-(NSString *)navigationBarTitle
{
    return self.name;
}

#pragma mark -- playView changed
-(void)mediaInfoChanged
{
    [super mediaInfoChanged];
    [self playStatuChanged];
}

- (void)playStatuChanged
{
    if (self.dataArray.count == 0) {
        return;
    }
    
    NSString *songId = [[NewTuneInMusicManager shared] songId];
    if (songId == nil || songId.length == 0){
        return;
    }
    
    if (![[[NewTuneInMusicManager shared] mediaSource] isEqualToString:NEW_TUNEIN_SOURCE]) {
        
        return;
    }
    
    for (LPTuneInPlayHeader *playHeader in self.dataArray) {

        for (LPTuneInPlayItem *playItem in playHeader.children) {
            
            if ([playItem.trackId isEqualToString:songId]) {
                
                [self.tableView reloadData];
                return;
            }
        }
    }
}

#pragma mark ---- TableViewDelegate && TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    NSArray *list = playHeader.children;
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSArray *list = playHeader.children;
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

        if ([[NewTuneInMusicManager shared] isCurrentPlayingHeader:playHeader index:indexPath.row])
        {
            cell.title.textColor = HWCOLORA(80, 227, 194, 1);
        }else{
            
            cell.title.textColor = [UIColor whiteColor];
        }

        BOOL isOpenMore = [cellDict[@"openMore"] boolValue];
        if (isOpenMore)
        {
            [cell.moreButton setImage:[NewTuneInMethod imageNamed:@"tunein_tital_more_s_n"] forState:UIControlStateNormal];
            cell.duration.hidden = NO;
            cell.duration.text = cellDict[@"time"];
            cell.curationHeightCon.constant = [cellDict[@"durationHeight"] intValue];
        }else{
            
            [cell.moreButton setImage:[NewTuneInMethod imageNamed:@"tunein_tital_more_s_d"] forState:UIControlStateNormal];
            cell.duration.hidden = YES;
        }

        #ifdef NEWTUNEIN_PRESENT_OPEN
        //是否可以预置
        BOOL isCanPreset = [[NewTuneInMusicManager shared] isCanPresetWithModel:playItem];
        if (isCanPreset)
        {
            cell.presentButton.hidden = NO;
        }
        else
        {
            cell.presentButton.hidden = YES;
        }
        #endif

        cell.block = ^(int type){

            if (type == 0) {
                //改变open
                BOOL newOpenMore = !isOpenMore;
            
                //计算高度
                NSDictionary *cellHeightDict = [[NewTuneInMusicManager shared] dealDescriptionCellHeight:playItem isOpenMore:newOpenMore];
                
                [self.itemCellDict setValue:@{
                    @"isOpen":@(newOpenMore),
                    @"cellDict":cellHeightDict
                } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];

                [self.tableView reloadData];
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
        [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[NewTuneInMethod imageNamed:@"tunein_album_logo"]];

        if ([[NewTuneInMusicManager shared] isCurrentPlayingHeader:playHeader index:indexPath.row])
        {
            cell.titleLab.attributedText = [[NewTuneInMusicManager shared] attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:HWCOLORA(80, 227, 194, 1) subLabColor:newTuneIn_LIGHT_COLOR];
        }else{
            cell.titleLab.attributedText = [[NewTuneInMusicManager shared] attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor whiteColor] subLabColor:newTuneIn_LIGHT_COLOR];
        }

        #ifdef NEWTUNEIN_PRESENT_OPEN
        //是否可以预置
        BOOL isCanPreset = [[NewTuneInMusicManager shared] isCanPresetWithModel:playItem];
        if (isCanPreset)
        {
            cell.presentButton.hidden = NO;
            cell.block = ^(id action){
                [self presetMusicWithModel:playHeader index:indexPath.row];
            };
        }
        else
        {
           cell.presentButton.hidden = YES;
        }
        #endif

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
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    NSString *nextAction = playItem.nextAction;

    //browse
    if ([nextAction isEqualToString:@"1"]) {
       
        NewTuneInBrowseDetailController *controller = [[NewTuneInBrowseDetailController alloc] init];
        controller.trackName = playItem.trackName;
        controller.url = playItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //detail
    }else if ([nextAction isEqualToString:@"2"]){
    
        NewTuneInMusicDetailController *controller = [[NewTuneInMusicDetailController alloc] init];
        controller.url = playItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //play
    }else if ([nextAction isEqualToString:@"3"]){
        
      [self showHud:@""];
      [[NewTuneInMusicManager shared] startPlayHeader:playHeader index:indexPath.row Block:^(int ret, NSString * _Nonnull message) {
            
        [self hideHud:@"" afterDelay:2 type:0];
        if (ret == 1){
            [self.view makeToast:message];
        }else{
            [self.tableView reloadData];
        }
      }];

    //premium
    }else if ([nextAction isEqualToString:@"4"]){
        
      [self premiumAction];
        
    //error
    }else if ([nextAction isEqualToString:@"5"]){
        
      [self.view makeToast:TUNEINLOCALSTRING(@"newtuneIn_This_show_will_be_available_later__Please_come_back_then_")];
    }

    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    
    NSMutableDictionary *itemCellDict = [self.itemCellDict objectForKey:[NSString stringWithFormat:@"%@%@",playItem.trackId,playItem.trackName]];
    NSMutableDictionary *cellDict = itemCellDict[@"cellDict"] ? itemCellDict[@"cellDict"] :@{};
    return [cellDict[@"height"] floatValue];
}

- (void)premiumAction
{
    NewTuneInPremiumController *premiumController = [[NewTuneInPremiumController alloc] init];
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:premiumController];
    navcontroller.modalPresentationStyle = UIModalPresentationFullScreen;
    premiumController.delegate = self;
    [self presentViewController:navcontroller animated:YES completion:nil];
}

- (void)presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    [[NewTuneInMusicManager shared] presetMusicWithModel:playHeader index:index];
}

#pragma mark -----
- (void)newTuneInPremiumControllerResult:(BOOL)result
{
    if (result) {
        [self requestData:self.url];
    }
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (LPTuneInRequest *)request
{
    if (!_request) {
        _request = [[LPTuneInRequest alloc] init];
    }
    return _request;
}

- (UILabel *)statuLab
{
    if (!_statuLab) {
        _statuLab = [[UILabel alloc] initWithFrame:CGRectMake(10, (SCREENHEIGHT - 100)/2.0 - 20, SCREENWIDTH - 20, 100)];
        _statuLab.font = [UIFont systemFontOfSize:16];
        _statuLab.textColor = [UIColor whiteColor];
        _statuLab.numberOfLines = 0;
        _statuLab.hidden = YES;
        _statuLab.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:_statuLab];
    }
    return _statuLab;
}

- (NSString *)nextUrl
{
    if (!_nextUrl) {
        _nextUrl = [[NSString alloc] init];
    }
    return _nextUrl;
}

@end
