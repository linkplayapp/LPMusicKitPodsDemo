//
//  NewTuneInFavoriteController.m
//  iMuzo
//
//  Created by lyr on 2019/5/8.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInFavoriteController.h"
#import "NewTuneInConfig.h"

#import "NewTuneInBrowseTableViewCell.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInNavigationBar.h"
#import "NewTuneInMenuView.h"
#import "NewTuneInMainController.h"
#import "NewTuneInSettingController.h"
#import "NewTuneInBrowseController.h"
#import "NewTuneInSearchController.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"
#import "PresetViewController.h"
#import "NewTuneInPublicMethod.h"
#import "MJRefresh.h"

#define CONTROOLER_NAME @"NewTuneInFavoriteController"
#import "Masonry.h"
@interface NewTuneInFavoriteController ()<MJRefreshBaseViewDelegate,NewTuneInNavigationBarDelegate>
{
    MJRefreshHeaderView *headerView;
    NSString *_selectId;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UILabel *statuLab;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSDictionary *headDict;

@property (strong, nonatomic) LPTuneInRequest *request;

@property (nonatomic, strong) NewTuneInNavigationBar *navBarMethod;
@property (strong, nonatomic) NewTuneInMenuView *menuView;

@end

@implementation NewTuneInFavoriteController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.menuView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSearchBar];
    
    //refresh
    headerView = [MJRefreshHeaderView header];
    headerView.scrollView = self.tableView;
    headerView.delegate = self;
    [self showHud:nil];
}

- (BOOL)needPopGestureRecognizer {
    return YES;
}

- (void)requestData
{
    self.statuLab.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInGetFavoritesSuccess:^(NSArray * _Nonnull list) {
        
        [weakSelf hideHud:@"" afterDelay:0 type:0];
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:list];
        [weakSelf.tableView reloadData];
        
        NSMutableDictionary *favoriteDictionary = [[NSMutableDictionary alloc] init];
        for (LPTuneInPlayHeader *playHeader in list) {
            for (LPTuneInPlayItem *playItem in playHeader.children) {
                [favoriteDictionary setObject:@"1" forKey:playItem.trackId];
            }
        }
        [[NewTuneInPublicMethod shared] updateFavoriteWithDictionary:favoriteDictionary];
        
        if (weakSelf.dataArray.count > 0)
        {
            [weakSelf showStatuLab:NO Text:@"" Delay:0];
        }
        else
        {
            [weakSelf showStatuLab:YES Text:LOCALSTRING(@"newtuneIn_No_results") Delay:0];
        }
    } failure:^(NSError * _Nonnull error) {
        
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        [weakSelf hideHud:message afterDelay:2.0 type:0];
        if (self.dataArray.count == 0)
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
            [self showHud:@""];
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

- (void)playViewDismiss
{
    [super playViewDismiss];
    [headerView beginRefreshing];
}

- (void)setSearchBar
{
    float barViewHeight = self.navigationController.navigationBar.frame.size.height;
    NSArray *navButArr = [self.navBarMethod navigationButHeight:barViewHeight];
    self.navigationItem.rightBarButtonItems = navButArr;
    self.navigationItem.leftBarButtonItems = [self.navBarMethod navigationLeft];
}

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
    NSMutableArray *list = playHeader.children;
    if (list)
    {
        return list.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    
    if (playItem.trackImage.length > 0)
    {
        NSString *kCellIdentifier = @"NewTuneInBrowseDetailTableViewCell";
        NewTuneInBrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInBrowseDetailTableViewCell" owner:self options:nil] lastObject];
        }
        
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(removeFavoriteAction:)];
        [cell addGestureRecognizer:longGes];
        
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
       
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(removeFavoriteAction:)];
        [cell addGestureRecognizer:longGes];
        cell.backgroundColor = [UIColor clearColor];
        cell.titleLab.text = playItem.trackName;
        return cell;
    }
}

- (void)removeFavoriteAction:(UILongPressGestureRecognizer *)longRecognizer
{
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        //成为第一响应者，需重写该方法
        [self becomeFirstResponder];
        
        CGPoint location = [longRecognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        [self isRemoveFavoriteWithIndex:indexPath];
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)isRemoveFavoriteWithIndex:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.dataArray.count) {
        return;
    }

    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    
    if (playItem.trackId.length == 0) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:playItem.trackName preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:LOCALSTRING(@"newtuneIn_Cancel") style:UIAlertActionStyleCancel handler:nil]];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:LOCALSTRING(@"newtuneIn_Unfavorite") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showHud:@""];
        [weakSelf.request lpTuneInDeleteFavoritesWithTrackId:playItem.trackId success:^(NSArray * _Nonnull list) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf requestData];
                }
            );
        } failure:^(NSError * _Nonnull error) {
            NSString *message = [NewTuneInPublicMethod failureResultError:error];
            [weakSelf hideHud:message afterDelay:2 type:MBProgressHUDModeIndeterminate];
        }];
    }]];
    alertController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:alertController animated:YES completion:nil];
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
    }else if ([nextAction isEqualToString:@"3"] || [nextAction isEqualToString:@"6"]){
        
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

- (UIButton *)createPremiumButton
{
    UIButton *premiumButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 98 - 20, 13, 98, 24)];
    premiumButton.backgroundColor = [UIColor whiteColor];
    [premiumButton setImage:[UIImage imageNamed:@"tuneinPremiumBadge"] forState:UIControlStateNormal];
    [premiumButton addTarget:self action:@selector(premiumAction) forControlEvents:UIControlEventTouchUpInside];
    return premiumButton;
}

- (void)premiumAction
{
    NewTuneInPremiumController *premiumController = [[NewTuneInPremiumController alloc] init];
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:premiumController];
    navcontroller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navcontroller animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    if (playItem.trackImage.length > 0){
        return 82;
    }
    return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] init];
    if (self.dataArray.count == 0)
    {
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return headView;
    }
    
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    if (!(playHeader.headTitle.length > 0))
    {
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return headView;
    }

    //premium
    NSInteger premiumWidth = 0;
    if ([playHeader.Premium isEqualToString:@"1"])
    {
        premiumWidth = 98;
        UIButton *premiumButton = [self createPremiumButton];
        [headView addSubview:premiumButton];
    }

    //title
    if (playHeader.children.count == 0 && playHeader.headTitle.length > 0)
    {
        UILabel *labTit = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, SCREENWIDTH - 32 - premiumWidth, 80)];
        labTit.numberOfLines = 0;
        labTit.textAlignment = NSTextAlignmentCenter;
        labTit.text = playHeader.headTitle;
        labTit.layer.borderWidth = 1;
        labTit.layer.borderColor = [UIColor grayColor].CGColor;
        labTit.layer.cornerRadius = 5;
        labTit.layer.masksToBounds = YES;
        labTit.textColor = [UIColor whiteColor];
        labTit.font = [UIFont systemFontOfSize:15];
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 100);
        [headView addSubview:labTit];
        return headView;
    }

    headView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeSystem];
    headBut.frame = CGRectMake(16, 0, SCREENWIDTH - 32 - premiumWidth, 50);
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataArray.count == 0){
        return 0;
    }

    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    if (!(playHeader.headTitle.length > 0)){
        return 0;
    }

    if (playHeader.children.count == 0 && playHeader.headTitle.length > 0){
        return 80;
    }
    return 50.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    if (self.dataArray.count == 0)
    {
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return footView;
    }
    
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    
    if (navigationStr.length > 0 || moreUrl.length > 0)
    {
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
            [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
            [headBut setbuttonType:LZCategoryTypeLeft];
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
    if (self.dataArray.count == 0){
        return 0;
    }
    
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    if (navigationStr.length > 0 || moreUrl.length > 0){
        return 50;
    }
    return 0;
}

#pragma mark -- moreAction
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
                case 0:
                {
                    NewTuneInMainController *main = [[NewTuneInMainController alloc] init];
                    [weakSelf.navigationController pushViewController:main animated:NO];
                }
                    break;
                case 1:
                {
                    NewTuneInBrowseController *browse = [[NewTuneInBrowseController alloc] init];
                    [weakSelf.navigationController pushViewController:browse animated:NO];
                }
                    break;
                case 3:
                {
                    NewTuneInSettingController *setting = [[NewTuneInSettingController alloc] init];
                    [weakSelf.navigationController pushViewController:setting animated:NO];
                }
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

- (void)presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    NSMutableArray *array = playHeader.children;
    LPTuneInPlayItem *playItem = array[index];
    

}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSDictionary *)headDict
{
    if (!_headDict) {
        _headDict = [[NSDictionary alloc] init];
    }
    return _headDict;
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

- (NewTuneInMenuView *)menuView
{
    if (!_menuView)
    {
        _menuView = [[NewTuneInMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _menuView.select = 2;
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

@end
