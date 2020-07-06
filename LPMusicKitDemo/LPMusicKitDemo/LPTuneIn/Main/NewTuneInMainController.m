//
//  NewTuneInMainController.m
//  iMuzo
//
//  Created by lyr on 2019/4/15.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMainController.h"
#import "NewTuneInNavigationBar.h"
#import "NewTuneInConfig.h"
#import "MJRefresh.h"
#import "NewTuneInSearchController.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInMainTableViewCell.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+LZCategory.h"
#import "NewTuneInMenuView.h"

#import "NewTuneInBrowseController.h"
#import "NewTuneInSettingController.h"
#import "NewTuneInFavoriteController.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"
#import "LPDeviceFunctionViewController.h"
#import "AlarmClockMusicViewController.h"

@interface NewTuneInMainController ()<NewTuneInNavigationBarDelegate,MJRefreshBaseViewDelegate,NewTuneInPremiumControllerDelegate>
{
    MJRefreshHeaderView *headerView;
    NSString *selectId;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NewTuneInNavigationBar *navBarMethod;
@property (strong, nonatomic) NewTuneInMenuView *menuView;
@property (nonatomic, strong) LPTuneInRequest *request;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) UILabel *statuLab;

@end

@implementation NewTuneInMainController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //设置footer
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.tableFooterView = [self addFooterView];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //navigation button
    UIImage *image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
    self.backImage.image = image;
    float barViewHeight = self.navigationController.navigationBar.frame.size.height;
    NSArray *navButArr = [self.navBarMethod navigationButHeight:barViewHeight];
    self.navigationItem.rightBarButtonItems = navButArr;
    self.navigationItem.leftBarButtonItems = [self.navBarMethod navigationLeft];
    self.statuLab.hidden = YES;
    
    //refresh
    headerView = [MJRefreshHeaderView header];
    headerView.scrollView = self.tableView;
    headerView.delegate = self;
    
    [self requestData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.menuView.hidden = YES;
}

- (void)requestData
{
    [self showHud:@""];
    self.statuLab.hidden = YES;
    
    [self.request tuneInGetHomeSuccess:^(NSArray * _Nonnull list) {
        
        [self hideHud:@"" afterDelay:0 type:MBProgressHUDModeIndeterminate];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:list];
        [self.tableView reloadData];
        [self hideRefresh];
        
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

- (void)hideRefresh
{
    if (headerView.isRefreshing){
        [headerView endRefreshing];
    }
}

- (void)showStatuLab:(BOOL)show Text:(NSString *)text Delay:(NSTimeInterval)delay
{
    if (show){
        if (delay > 0){
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

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == self->headerView){
            [self requestData];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return NO;
}

- (NSString *)currentDeviceId
{
    return [[NewTuneInMusicManager shared] deviceId];
}

#pragma mark -- playView changed
-(void)mediaInfoChanged
{
    [super mediaInfoChanged];
    [self playStatuChanged];
}

- (void)playStatuChanged
{
    NSString *songId = [[NewTuneInMusicManager shared] songId];
    if (songId == nil || songId.length == 0){
        return;
    }
    
    if (selectId.length > 0 && [selectId isEqualToString:songId]) {
        return;
    }
    
    if (![[[NewTuneInMusicManager shared] mediaSource] isEqualToString:NEW_TUNEIN_SOURCE]) {
        
        return;
    }
    
    for (LPTuneInPlayHeader *playHeader in self.dataArray) {

        for (LPTuneInPlayItem *playItem in playHeader.children) {
            
            if ([playItem.trackId isEqualToString:songId]) {
                
                selectId = [[NSString alloc] initWithFormat:@"%@",songId];
                [self.tableView reloadData];
                return;
            }
        }
    }
}

#pragma mark - UITableViewDelegate && UITabelViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LPTuneInPlayHeader *header = self.dataArray[section];
    NSMutableArray *array = header.children;
    if (array){
        NSString *present = header.Presentation ? header.Presentation[@"Layout"] : @"";
        if ([present isEqualToString:@"Gallery"]){
            return 1;
        }else{
            return array.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *header = self.dataArray[indexPath.section];
    NSMutableArray *array = header.children;
    
    NSString *present = header.Presentation ? header.Presentation[@"Layout"] : @"";
    if ([present isEqualToString:@"Gallery"])
    {
        //第一个item的排列方式
        LPTuneInPlayItem *playItem = array[0];
        NSString *itemPresent = playItem.Presentation ? playItem.Presentation[@"Layout"] : @"";
        
        //纯图片
        if ([itemPresent isEqualToString:@"BrickTile"])
        {
            NewTuneInMainTableViewCell *cell = [NewTuneInMainTableViewCell cellWithTableView:tableView CellType:[NSString stringWithFormat:@"newTuneInMainTableViewImageCell%ld",(long)index] type:Cell_image];
            cell.block = ^(NSInteger selectIndex, NSInteger type){
               
                if (type == 1) {
                    [self presetMusicWithModel:header index:selectIndex];
                }else{
                    [self didSelectHeader:header index:selectIndex];
                }
            };
            cell.playHeader = header;
            return cell;
        }else{
            
            NewTuneInMainTableViewCell *cell = [NewTuneInMainTableViewCell cellWithTableView:tableView CellType:[NSString stringWithFormat:@"newTuneInMainTableViewTitleCell%ld",(long)index] type:Cell_image_title];
            cell.block = ^(NSInteger selectIndex, NSInteger type){
                [self didSelectHeader:header index:selectIndex];
            };
            cell.playHeader = header;
            return cell;
        }
    }
    else
    {
        LPTuneInPlayItem *playItem = array[indexPath.row];
        
        if (playItem.trackImage.length > 0)
        {
            NSString *kCellIdentifier = @"NewTuneInBrowseDetailTableViewCell";
            NewTuneInBrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInBrowseDetailTableViewCell" owner:self options:nil] lastObject];
            }
            cell.ImageLeftCon.constant = 22;
            cell.backgroundColor = [UIColor clearColor];
            [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[NewTuneInMethod imageNamed:@"tunein_album_logo"]];
            
            #ifdef NEWTUNEIN_PRESENT_OPEN
            //是否可以预置
            BOOL isCanPreset = [[NewTuneInMusicManager shared] isCanPresetWithModel:playItem];
            if (isCanPreset)
            {
                cell.presentButton.hidden = NO;
                cell.block = ^(id action){
                    [self presetMusicWithModel:header index:indexPath.row];
                };
            }
            else
            {
               cell.presentButton.hidden = YES;
            }
            #endif
            
            if ([[NewTuneInMusicManager shared] isCurrentPlayingHeader:header index:indexPath.row])
            {
                cell.titleLab.attributedText = [[NewTuneInMusicManager shared] attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:HWCOLORA(80, 227, 194, 1) subLabColor:newTuneIn_HIGH_COLOR];
            }
            else
            {
                cell.titleLab.attributedText = [[NewTuneInMusicManager shared] attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor whiteColor] subLabColor:newTuneIn_LIGHT_COLOR];
            }
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
            
            cell.lineLab.hidden = YES;
            cell.TitleLeftCon.constant = 22;
            cell.backgroundColor = [UIColor clearColor];
            cell.titleLab.text = playItem.trackName;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSString *present = playHeader.Presentation ? playHeader.Presentation[@"Layout"] : @"";
    if (![present isEqualToString:@"Gallery"]){
       [self didSelectHeader:playHeader index:indexPath.row];
    }
    [self.tableView reloadData];
}

- (void)didSelectHeader:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    LPTuneInPlayItem *selectItem = playHeader.children[index];
    NSString *nextAction = selectItem.nextAction;
    
    //browse
    if ([nextAction isEqualToString:@"1"]) {
       
        NewTuneInBrowseDetailController *controller = [[NewTuneInBrowseDetailController alloc] init];
        controller.trackName = selectItem.trackName;
        controller.url = selectItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //detail
    }else if ([nextAction isEqualToString:@"2"]){
    
        NewTuneInMusicDetailController *controller = [[NewTuneInMusicDetailController alloc] init];
        controller.url = selectItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //play
    }else if ([nextAction isEqualToString:@"3"]){
        
      [self showHud:@""];
      [[NewTuneInMusicManager shared] startPlayHeader:playHeader index:index Block:^(int ret, NSString * _Nonnull message) {
            
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSString *present = playHeader.Presentation ? playHeader.Presentation[@"Layout"] : @"";
    if ([present isEqualToString:@"Gallery"])
    {
        LPTuneInPlayItem *playItem = playHeader.children[0];
        NSString *itemPresen = playItem.Presentation ? playItem.Presentation[@"Layout"] : @"";
        if ([itemPresen isEqualToString:@"BrickTile"]){
            return 95;
        }
        return 145;
    }else{
        
        NSMutableArray *dataArray = playHeader.children;
        LPTuneInPlayItem *playItem = dataArray[indexPath.row];
        if (playItem.trackImage.length > 0){
            return 82;
        }
        return 50;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 57)];
    headView.backgroundColor = [UIColor clearColor];
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    
    if (playHeader.headTitle.length == 0){
        headView.frame = CGRectMake(0, 0, 0, 0);
        return headView;
    }
    
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeCustom];
     headBut.frame = CGRectMake(22, 8, SCREENWIDTH - 46, 40);
    
    //premium
    if ([playHeader.Premium isEqualToString:@"1"])
    {
        UIButton *premiumButton = [self createPremiumButton];
        [headView addSubview:premiumButton];
        headBut.frame = CGRectMake(22, 8, SCREENWIDTH - 98 - 44, 40);
    }
    
    //title
    headBut.backgroundColor = [UIColor clearColor];
    [headBut setTitle:playHeader.headTitle forState:UIControlStateNormal];
    if (playHeader.ContainerNavigation && playHeader.ContainerNavigation.allKeys > 0){
        
        headBut.userInteractionEnabled = YES;
        [headBut setImage:[NewTuneInMethod imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
        [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        headBut.userInteractionEnabled = NO;
    }
    headBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headBut.tag = section + 100;
    [headBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    headBut.titleLabel.font = [UIFont systemFontOfSize:18];
     [headBut setbuttonType:LZCategoryTypeLeft];
    [headView addSubview:headBut];
    
    return headView;
}

- (UIButton *)createPremiumButton
{
    UIButton *premiumButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 98 - 20, 13, 98, 24)];
    premiumButton.backgroundColor = [UIColor clearColor];
    [premiumButton setImage:[NewTuneInMethod imageNamed:@"tuneinPremiumBadge"] forState:UIControlStateNormal];
    [premiumButton addTarget:self action:@selector(premiumAction) forControlEvents:UIControlEventTouchUpInside];
    return premiumButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    if (playHeader.headTitle.length == 0){
        return 0;
    }
    return 57.f;
}

#pragma mark -- button action
- (void)moreAction:(UIButton *)sender
{
    LPTuneInPlayHeader *playHeader = self.dataArray[sender.tag - 100];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more[@"Url"];
    
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";

    if (navigationStr.length > 0)
    {
        NewTuneInBrowseDetailController *controller = [[NewTuneInBrowseDetailController alloc] init];
        controller.trackName = playHeader.headTitle;
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

#pragma mark -- amazonMusicNavigationBar delegate
- (void)selectMusicNavigationBar:(NewTuneInNavButType)type
{
    if (type == NavBut_Search)
    {
        NewTuneInSearchController *search = [[NewTuneInSearchController alloc] init];
        [self.navigationController pushViewController:search animated:YES];
    }
    else if (type == NavBut_Back)
    {
        if ([GlobalUI sharedInstance].alarmSourceObj.isEditingAlarmSource) {
            
            for (UIViewController *tempController in self.navigationController.viewControllers) {

                if ([tempController isKindOfClass:[AlarmClockMusicViewController class]]) {

                    [self.navigationController popToViewController:tempController animated:YES];
                }
            }
            return;
        }
        
        for (UIViewController *tempController in self.navigationController.viewControllers) {

            if ([tempController isKindOfClass:[LPDeviceFunctionViewController class]]) {

                [self.navigationController popToViewController:tempController animated:YES];
            }
        }
    }
    else
    {
        if (self.menuView.isHidden){
            self.menuView.hidden = NO;
        }else{
            self.menuView.hidden = YES;
        }

        __weak typeof(self) weakSelf = self;
        self.menuView.block = ^(NSInteger index)
        {
            switch (index) {
                case 1:
                {
                    NewTuneInBrowseController *browse = [[NewTuneInBrowseController alloc] init];
                    [weakSelf.navigationController pushViewController:browse animated:YES];
                }
                    break;
                case 2:
                {
                    NewTuneInFavoriteController *favorite = [[NewTuneInFavoriteController alloc] init];
                    [weakSelf.navigationController pushViewController:favorite animated:YES];
                }
                    break;
                case 3:
                {
                    NewTuneInSettingController *setting = [[NewTuneInSettingController alloc] init];
                    [weakSelf.navigationController pushViewController:setting animated:YES];
                }
                    break;
                case 5:
                {
                    weakSelf.menuView.hidden = YES;
                }
                    break;

                default:
                    break;
            }
        };
    }
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

- (void)newTuneInPremiumControllerResult:(BOOL)result
{
    if (result) {
        [self requestData];
    }
}

- (NewTuneInMenuView *)menuView
{
    if (!_menuView)
    {
        _menuView = [[NewTuneInMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _menuView.select = 0;
        _menuView.hidden = YES;
        [self.view addSubview:_menuView];
    }
    return _menuView;
}

- (NewTuneInNavigationBar *)navBarMethod
{
    if (!_navBarMethod) {
        _navBarMethod = [[NewTuneInNavigationBar alloc] init];
        _navBarMethod.delegate = self;
    }
    return _navBarMethod;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]  init];
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
        _statuLab.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:_statuLab];
    }
    return _statuLab;
}


@end
