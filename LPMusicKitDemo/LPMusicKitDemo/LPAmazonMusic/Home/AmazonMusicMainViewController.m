//
//  AmazonMusicMainViewController.m
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicMainViewController.h"
#import "AmazonMusicNavigationSet.h"
#import "MJRefresh.h"
#import "AmazonMusicErrorView.h"
#import "AmazonMusicConfig.h"
#import "AmazonMusicSearchViewController.h"
#import "AmazonMusicMainTableViewCell.h"
#import "AmazonMusicSettingViewController.h"
#import "AmazonMusicSourceViewController.h"
#import "LPDeviceFunctionViewController.h"

@interface AmazonMusicMainViewController ()<AmazonMusicNavigationBarDelegate,MJRefreshBaseViewDelegate>
{
    MJRefreshHeaderView *headerView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AmazonMusicNavigationSet *NavigationBar;//导航栏集合
@property (nonatomic, strong) LPAmazonMusicNetwork *netWork;//网络请求
@property (nonatomic, strong) AmazonMusicErrorView *errorView;//错误展示

@property (nonatomic, strong) LPAmazonMusicPlayHeader *playHeader;//分页
@property (nonatomic, strong) NSMutableArray *playArray;//播放列表

@end

@implementation AmazonMusicMainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //request
    [self request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setNavagtion
    [self setnavigation];
    
    //request
    [self showHud:AMAZONLOCALSTRING(@"primemusic_Loading____")];
}

- (void)setnavigation
{
    //tableView
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [self addFooterView];
    
    //navigation button
    float barViewHeight = self.navigationController.navigationBar.frame.size.height;
    NSArray *navButArr = [self.NavigationBar navigationButHeight:barViewHeight];
    self.navigationItem.rightBarButtonItems = navButArr;
    
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

-(NSString *)navigationBarTitle
{
    return [AMAZONLOCALSTRING(@"primemusic_Amazon_Music") uppercaseString];
}

-(BOOL)needBlurBack
{
    return YES;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

-(void)backButtonPressed
{
    for (UIViewController *tempController in self.navigationController.viewControllers) {
        if ([tempController isKindOfClass:[LPDeviceFunctionViewController class]]) {
            [self.navigationController popToViewController:tempController animated:YES];
        }
    }
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (refreshView == self->headerView){
            [self showHud:AMAZONLOCALSTRING(@"primemusic_Loading____")];
            [self request];
        }
    });
}

#pragma mark -- amazonMusicNavigationBar delegate
- (void)selectMusicNavigationBar:(AmazonMusicNavButType)type
{
    if (type == NavBut_Search){
        AmazonMusicSearchViewController *searchController = [[AmazonMusicSearchViewController alloc] init];
        [self.navigationController pushViewController:searchController animated:YES];
    }else{
        AmazonMusicSettingViewController *settingController = [[AmazonMusicSettingViewController alloc] init];
        [self.navigationController pushViewController:settingController animated:YES];
    }
}

#pragma mark -- request data
- (void)request
{
    [self.errorView dismiss];
    [self.netWork getHomePageContent:^(LPAmazonMusicPlayHeader *header, NSArray<LPAmazonMusicPlayItem *> *list) {
        
        [self hideHud:AMAZONLOCALSTRING(@"primemusic_Loading____") afterDelay:0 type:0];
        if (self->headerView.isRefreshing){
            [self->headerView endRefreshing];
        }
        
        //添加header
        self.playHeader = [[LPAmazonMusicPlayHeader alloc] init];
        self.playHeader = header;
        
        //添加item
        [self.playArray removeAllObjects];
        [self.playArray addObjectsFromArray:list];
        [self.tableView reloadData];

        if (list.count == 0){
            [self.errorView show:AMAZONLOCALSTRING(@"primemusic_NO_Result")];
        }

    } failure:^(LPAmazonMusicNetworkError *error) {
      
        if (error.type == 1){
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
       
        if (self.playArray.count == 0){
            [self.errorView show:error.message];
        }
        
        if (self->headerView.isRefreshing){
            [self->headerView endRefreshing];
        }
    }];
}

#pragma mark - UITableViewDelegate && UITabelViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPAmazonMusicPlayItem *playItem = self.playArray[indexPath.row];
    AmazonMusicMainTableViewCell *cell = [AmazonMusicMainTableViewCell cellWithTableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.mode = playItem;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LPAmazonMusicPlayItem *playItem = self.playArray[indexPath.row];
    
    //首页存在购买推广，直接跳转到lanuch推广界面
    if (playItem.lanuchPage){
        LPAmazonMusicLanuchViewController *lanuchCntroller = [[LPAmazonMusicLanuchViewController alloc] init];
        lanuchCntroller.navigationPath = playItem.navigationPath;
        lanuchCntroller.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:lanuchCntroller animated:YES completion:nil];
        
     //导航到下一页
    }else if (playItem.navigationPath){
        NSString *contentType = playItem.contentType.length > 0 ? [playItem.contentType uppercaseString] :@"";
        
        AmazonMusicSourceViewController *controller = [[AmazonMusicSourceViewController alloc] init];
        if ([contentType rangeOfString:@"PLAYLIST"].location != NSNotFound )
        {
            controller.cellType = AmazonMusic_PlayList_Type;
        }
        else if ([contentType rangeOfString:@"STATION"].location != NSNotFound || [contentType rangeOfString:@"ALBUM"].location != NSNotFound)
        {
            controller.cellType = AmazonMusic_Ablum_Type;
        }
        else
        {
            controller.cellType = AmazonMusic_Songs_Type;
        }
        controller.playHeader = self.playHeader;
        controller.playItem = playItem;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }else{
        [self.view makeToast:AMAZONLOCALSTRING(@"primemusic_We_re_sorry__this_content_is_no_longer_available") duration:2 position:@"CSToastPositionCenter"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70 *WSCALE;
}

- (AmazonMusicNavigationSet *)NavigationBar
{
    if (!_NavigationBar) {
        _NavigationBar = [[AmazonMusicNavigationSet alloc] init];
        _NavigationBar.delegate = self;
    }
    return _NavigationBar;
}

- (LPAmazonMusicNetwork *)netWork{
    if (!_netWork) {
        _netWork = [[LPAmazonMusicNetwork alloc] init];
    }
    return _netWork;
}

- (AmazonMusicErrorView *)errorView
{
    if (!_errorView) {
        _errorView = [[AmazonMusicErrorView alloc] initWithFrame:CGRectMake(10, (SCREENHEIGHT - 64 - 80)/2.0, SCREENWIDTH - 20, 80)];
        _errorView.hidden = YES;
        [self.view insertSubview:_errorView aboveSubview:self.tableView];
    }
    return _errorView;
}

- (NSMutableArray *)playArray
{
    if (!_playArray) {
        _playArray = [[NSMutableArray alloc] init];
    }
    return _playArray;
}


@end
