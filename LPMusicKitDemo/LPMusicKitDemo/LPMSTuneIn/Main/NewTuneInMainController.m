//
//  NewTuneInMainController.m
//  iMuzo
//
//  Created by lyr on 2019/4/15.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMainController.h"
#import "NewTuneInSearchController.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInMainTableViewCell.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "NewTuneInBrowseController.h"
#import "NewTuneInSettingController.h"
#import "NewTuneInFavoriteController.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"
#import "NewTuneInPublicMethod.h"
#import "Masonry.h"
#import "MJRefresh.h"


#import "PresetViewController.h"

@interface NewTuneInMainController ()<NewTuneInNavigationBarDelegate,MJRefreshBaseViewDelegate,NewTuneInPremiumControllerDelegate>
{
    MJRefreshHeaderView *headerView;
    NSString *_selectId;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NewTuneInNavigationBar *navBarMethod;
@property (nonatomic,strong) NewTuneInMenuView *menuView;
@property (nonatomic,strong) UILabel *statuLab;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) LPTuneInRequest *request;

@end

@implementation NewTuneInMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置footer
    self.tableView.tableFooterView = [self addFooterView];
    
    //navgation button
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
    
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
    
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInGetHomeSuccess:^(NSArray * _Nonnull list) {
        [weakSelf hideHud:@"" afterDelay:0 type:0];
        
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:list];
        [weakSelf.tableView reloadData];
    
        if (weakSelf.dataArray.count > 0)
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

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

- (BOOL)needPopGestureRecognizer {
    return YES;
}

#pragma mark -- playView changed
-(void)mediaInfoChanged
{
    [super mediaInfoChanged];
    [self playStatuChanged];
}

- (void)playViewDismiss
{
    [super playViewDismiss];
    [self playStatuChanged];
}

- (void)playStatuChanged
{
    NSString *trackId = CURBOX.mediaInfo.songId;
    if ([trackId isEqualToString:_selectId]) {
        
        return;
    }
    _selectId = [trackId copy];
    [self.tableView reloadData];
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
    if ([present isEqualToString:@"Gallery"]){

        //第一个item的排列方式
        LPTuneInPlayItem *playItem = array[0];
        NSString *itemPresent = playItem.Presentation ? playItem.Presentation[@"Layout"] : @"";
        
        //纯图片
        if ([itemPresent isEqualToString:@"BrickTile"])
        {
            NewTuneInMainTableViewCell *cell = [NewTuneInMainTableViewCell cellWithTableView:tableView CellType:[NSString stringWithFormat:@"newTuneInMainTableViewImageCell%ld",(long)index] type:Cell_image];
            
            __weak typeof(self) weakSelf = self;
            cell.block = ^(NSInteger selectIndex, NSInteger type){
               
                if (type == 1) {
                    [weakSelf presetMusicWithModel:header index:selectIndex];
                }else{
                    [weakSelf didSelectHeader:header index:selectIndex];
                }
            };
            cell.playHeader = header;
            return cell;
        }else{
            
            NewTuneInMainTableViewCell *cell = [NewTuneInMainTableViewCell cellWithTableView:tableView CellType:[NSString stringWithFormat:@"newTuneInMainTableViewTitleCell%ld",(long)index] type:Cell_image_title];
            __weak typeof(self) weakSelf = self;
            cell.block = ^(NSInteger selectIndex, NSInteger type){
                if (type == 1) {
                    [weakSelf presetMusicWithModel:header index:selectIndex];
                }else{
                    [weakSelf didSelectHeader:header index:selectIndex];
                }
            };
            cell.playHeader = header;
            return cell;
        }
    }else{
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
            [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[UIImage imageNamed:@"tunein_album_logo"]];
            
            cell.presentButton.hidden = YES;
           
            if ([NewTuneInPublicMethod isCurrentPlayingPlayItem:playItem])
            {
                cell.titleLab.attributedText = [NewTuneInPublicMethod attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor lightGrayColor] subLabColor:[UIColor lightGrayColor]];
            }
            else
            {
                cell.titleLab.attributedText = [NewTuneInPublicMethod  attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor whiteColor] subLabColor:[UIColor lightGrayColor]];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        controller.name = selectItem.trackName;
        controller.url = selectItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //detail
    }else if ([nextAction isEqualToString:@"2"]){
    
        NewTuneInMusicDetailController *controller = [[NewTuneInMusicDetailController alloc] init];
        controller.url = selectItem.nextPageUrl;
        [self.navigationController pushViewController:controller animated:YES];
        
    //play
    }else if ([nextAction isEqualToString:@"3"]){
  
       [NewTuneInPublicMethod startPlayMusicWithPlayItem:selectItem header:playHeader];
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
    if (playHeader.ContainerNavigation && playHeader.ContainerNavigation.allKeys.count > 0){
        
        headBut.userInteractionEnabled = YES;
        [headBut setImage:[UIImage imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
        [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        headBut.userInteractionEnabled = NO;
    }
    headBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headBut.tag = section + 100;
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

#pragma mark -- amazonMusicNavgationBar delegate
- (void)selectMusicNavigationBar:(NewTuneInNavButType)type
{
    if (type == TuneIn_NavBut_Search)
    {
        NewTuneInSearchController *search = [[NewTuneInSearchController alloc] init];
        [self.navigationController pushViewController:search animated:YES];
    }
    else if (type == TuneIn_NavBut_Back)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        if (self.menuView.isHidden)
        {
            self.menuView.hidden = NO;
        }
        else
        {
            self.menuView.hidden = YES;
        }
       
        __weak typeof(self) weakSelf = self;
        self.menuView.block = ^(NSInteger index)
        {
            switch (index) {
                case 1:
                {
                    NewTuneInBrowseController *browse = [[NewTuneInBrowseController alloc] init];
                    [weakSelf.navigationController pushViewController:browse animated:NO];
                }
                    break;
                case 2:
                {
                    NewTuneInFavoriteController *favorite = [[NewTuneInFavoriteController alloc] init];
                    [weakSelf.navigationController pushViewController:favorite animated:NO];
                }
                    break;
                case 3:
                {
                    NewTuneInSettingController *setting = [[NewTuneInSettingController alloc] init];
                    [weakSelf.navigationController pushViewController:setting animated:NO];
                }
                    break;
               case 4:
                {

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
    NSMutableArray *array = playHeader.children;
    LPTuneInPlayItem *playItem = array[index];
    
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
        [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_topMargin);
            make.left.right.bottom.mas_equalTo(0);
//            make.edges.mas_equalTo(0);
        }];
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
        _statuLab = [[UILabel alloc] init];
        _statuLab.font = [UIFont systemFontOfSize:16];
        _statuLab.textColor = [UIColor whiteColor];
        _statuLab.numberOfLines = 0;
        _statuLab.textAlignment = NSTextAlignmentCenter;
        [self.tableView addSubview:_statuLab];
        
        [_statuLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(SCREENWIDTH-20, 100));
            make.center.mas_equalTo(self.tableView);
        }];
    }
    return _statuLab;
}

@end
