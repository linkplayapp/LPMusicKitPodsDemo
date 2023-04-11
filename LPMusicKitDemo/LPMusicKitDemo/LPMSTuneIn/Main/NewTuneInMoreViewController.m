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
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInMainTableListCell.h"
#import "NewTuneInPremiumController.h"
#import "PresetViewController.h"
#import "NewTuneInPublicMethod.h"
#import "NewTuneInConfig.h"
#import "MJRefresh.h"

@interface NewTuneInMoreViewController ()<MJRefreshBaseViewDelegate, NewTuneInPremiumControllerDelegate>
{
    MJRefreshHeaderView *headerView;
    MJRefreshFooterView *footerView;
    NSString *_selectId;
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
    
    if (self.nextUrl.length == 0)
    {
        footerView.hidden = YES;
    }
    else
    {
        footerView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.name;

    //refresh
    headerView = [MJRefreshHeaderView header];
    headerView.scrollView = self.tableView;
    headerView.delegate = self;
   
    self.tableView.tableFooterView = [self addFooterView];
    footerView = [MJRefreshFooterView footer];
    footerView.scrollView = self.tableView;
    footerView.delegate = self;
    
    [self requestData];
}
-(NSString *)navigationBarTitle{
    return  self.name;
}
- (void)requestData
{
    [self showHud:@""];
    self.statuLab.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInGetSingleTypeContentList:self.url success:^(NSArray * _Nonnull list) {
        
        [weakSelf hideHud:@"" afterDelay:0 type:0];
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
        
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:list];
        [weakSelf.tableView reloadData];
      
        //是否需要分页
        LPTuneInPlayHeader *playHeader = list.lastObject;
        weakSelf.nextUrl = playHeader.morePivots ? playHeader.morePivots :@"";
        [weakSelf hideFooter];

        if (weakSelf.dataArray.count > 0 && playHeader.children.count > 0)
        {
            [weakSelf showStatuLab:NO Text:@"" Delay:0];
        }else{
            [weakSelf showStatuLab:YES Text:LOCALSTRING(@"newtuneIn_No_results") Delay:0];
        }
    } failure:^(NSError * _Nonnull error) {
        
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        [weakSelf hideHud:message afterDelay:2.0 type:0];
        if (weakSelf.dataArray.count == 0)
        {
            [weakSelf showStatuLab:YES Text:message Delay:2.0];
        }
    }];
}

- (void)hideFooter
{
    if (self.nextUrl.length == 0){

        footerView.hidden = YES;
    }else{
       footerView.hidden = NO;
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

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == headerView)
        {
            [headerView endRefreshing];
            [self requestData];
        }
        else
        {
            [footerView endRefreshing];
            if (self.nextUrl.length > 0)
            {
                [self requestMoreWithUrl:self.nextUrl];
            }
        }
    });
}

- (void)requestMoreWithUrl:(NSString *)nextUrl
{
    [self showHud:@""];
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInGetSingleTypeContentList:nextUrl success:^(NSArray * _Nonnull list) {

        [weakSelf hideHud:@"" afterDelay:0 type:0];
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
        [weakSelf.dataArray addObjectsFromArray:list];

        //分页
        LPTuneInPlayHeader *playHeader = list.lastObject;
        weakSelf.nextUrl = playHeader.morePivots ? playHeader.morePivots :@"";
        [weakSelf hideFooter];
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        [weakSelf hideHud:message afterDelay:2.0 type:0];
    }];
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

#pragma mark -- playView changed
-(void)mediaInfoChanged
{
    [super mediaInfoChanged];
    
    NSString *trackId = CURBOX.mediaInfo.songId;
    if ([trackId isEqualToString:_selectId]) {
        
        return;
    }
    _selectId = [trackId copy];
    [self.tableView reloadData];
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
    
        NSMutableDictionary *itemCellDict = [self.itemCellDict objectForKey:[NSString stringWithFormat:@"%@%@",playItem.trackId,playItem.trackName]];
        NSMutableDictionary *cellDict = itemCellDict[@"cellDict"] ? itemCellDict[@"cellDict"] :@{};
        
        cell.backgroundColor = [UIColor clearColor];
        cell.titleHeightCon.constant = [cellDict[@"titleHeight"] integerValue];
        cell.title.text = playItem.trackName;
        cell.time.text = cellDict[@"startTime"];

        if ([NewTuneInPublicMethod isCurrentPlayingPlayItem:playItem])
        {
            cell.title.textColor = [UIColor lightGrayColor];
        }
        else{
            cell.title.textColor = [UIColor whiteColor];
        }

        BOOL isOpenMore = [itemCellDict[@"openMore"] boolValue];
        if (isOpenMore)
        {
            [cell.moreButton setImage:[UIImage imageNamed:@"tunein_tital_more_s_n"] forState:UIControlStateNormal];
            cell.duration.hidden = NO;
            cell.duration.text = cellDict[@"time"];
            cell.curationHeightCon.constant = [cellDict[@"durationHeight"] intValue];
        }else{
            
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
                [weakSelf presetMusicWithModel:playHeader index:indexPath.row];
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
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
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

- (void)presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    NSMutableArray *array = playHeader.children;
    LPTuneInPlayItem *playItem = array[index];
    
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
    if (result) {
        [self requestData];
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
