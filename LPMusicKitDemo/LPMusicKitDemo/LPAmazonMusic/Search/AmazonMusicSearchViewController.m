//
//  AmazonMusicSearchViewController.m
//  iMuzo
//
//  Created by 程龙 on 2018/12/11.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonMusicSearchViewController.h"
#import "AmazonMusicMethod.h"
#import "UIImageView+WebCache.h"
#import "AmazonSearchTableViewCell.h"
#import "AmazonMusicConfig.h"
#import "amazonMusicSearchBarView.h"
#import "AmazonMusicSourceViewController.h"
#import "AmazonMusicErrorView.h"
#import "AmazonMusicHistory.h"
#import "AmazonMusicSearchHistoryCell.h"

@interface AmazonMusicSearchViewController () <UIGestureRecognizerDelegate,AmazonMusicSearchBarViewDelegate>
{
    BOOL isInputKeyword;
}

@property (nonatomic, strong) LPAmazonMusicNetwork *amazonNetWork;

@property (weak, nonatomic) IBOutlet UILabel *searchStatuLab;
@property (weak, nonatomic) IBOutlet UIImageView *searchBarBack;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AmazonMusicSearchBarView *searchBar;//搜索栏
@property (nonatomic, strong) AmazonMusicErrorView *errorView;//错误展示
@property (nonatomic, strong) NSMutableArray *playHeaderArray;//分页
@property (nonatomic, strong) NSMutableArray *playArray;//列表
@property (nonatomic, strong) NSMutableArray *historyArray;//搜索历史
@property (nonatomic, strong) AmazonMusicHistory *historyMethod;//搜索历史管理

@end

@implementation AmazonMusicSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //停止编辑
    UITapGestureRecognizer *tapEditor = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange:)];
    tapEditor.numberOfTapsRequired = 1;
    tapEditor.delegate = self;
    [self.view addGestureRecognizer:tapEditor];
    
    //搜索框
    self.historyArray = [self.historyMethod selectAllSearchHistory];
    self.searchStatuLab.hidden = YES;
    self.tableView.hidden = NO;
    isInputKeyword = YES;
    [self setSearchBar];
}

- (void)setSearchBar
{
    self.searchBar = [[AmazonMusicSearchBarView alloc] initWithFrame:CGRectMake(13, 18, SCREENWIDTH - 25, 50)];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor clearColor];
    [self.searchBarBack addSubview:self.searchBar];
    self.searchBarBack.userInteractionEnabled = YES;
    
    self.tableView.tableFooterView = [self addFooterView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.searchStatuLab.text = AMAZONLOCALSTRING(@"primemusic_Search");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.searchBar.textFiled resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isNavigationBackEnabled
{
    return YES;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

-(BOOL)needBlurBack
{
    return YES;
}

-(NSString *)navigationBarTitle
{
    return [AMAZONLOCALSTRING(@"search") uppercaseString];
}

- (void)doTapChange:(UITapGestureRecognizer *)tap
{
    isInputKeyword = NO;
    self.searchStatuLab.hidden = YES;
    self.tableView.hidden = NO;
    [self.errorView dismiss];
    [self.tableView reloadData];
    
    [self.view endEditing:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSString *name = NSStringFromClass([touch.view class]);
    if ([name isEqualToString:@"UITableViewCellContentView"] || [name isEqualToString:@"UIControl"]) {
        
        //判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;
    }
    //否则手势存在
    return YES;
}

#pragma mark ---- searchBarDelegate
- (void)amazonMusicSearchBarView:(NSInteger)statu Text:(nonnull NSString *)text
{
    if (statu == 0)
    {
        self.historyArray = [self.historyMethod selectAllSearchHistory];
        isInputKeyword = YES;
        self.searchStatuLab.hidden = YES;
        self.tableView.hidden = NO;
        self.errorView.hidden = YES;
        [self.tableView reloadData];
    }
    
    if (statu == 1)
    {
        NSLog(@"");
    }
    else if (statu == 3)
    {
        isInputKeyword = NO;
        [self.tableView reloadData];
        [self searchContext:text];
        
        [self.historyMethod addSearchKeyword:text];
    }
    else if (statu == 2)
    {
        NSLog(@"");
    }
    else if (statu == 4)
    {
        if (text.length > 0)
        {
            self.historyArray = [self.historyMethod selectAllSearchHistory];
            isInputKeyword = YES;
            self.searchStatuLab.hidden = YES;
            self.tableView.hidden = NO;
            self.errorView.hidden = YES;
        }
        else
        {
            self.errorView.hidden = NO;
            self.searchStatuLab.hidden = NO;
            self.tableView.hidden = YES;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isInputKeyword)
    {
        return self.historyArray.count;
    }
    return self.playArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isInputKeyword)
    {
        NSString *searchKey = self.historyArray[indexPath.row];
        static NSString *kCellIdentifier = @"AmazonMusicSearchHistoryCell";
        AmazonMusicSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AmazonMusicSearchHistoryCell" owner:self options:nil] lastObject];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.titleLabel.text = self.historyArray[indexPath.row];
        cell.block = ^()
        {
            [self.historyMethod deleteSearchKeyword:searchKey];
            [self.historyArray removeObject:searchKey];
            [self.tableView reloadData];
        };
        return cell;
    }
    AmazonSearchTableViewCell *taskCell = [AmazonSearchTableViewCell cellWithTableView:tableView CellType:@"AmazonMusicIdentiefierSearchCell"];
    taskCell.cellType = SongsType;
    taskCell.model = self.playArray[indexPath.row];
    taskCell.accessoryType = UITableViewCellAccessoryNone;
    return taskCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isInputKeyword)
    {
        return 50;
    }
    return 70 *WSCALE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isInputKeyword)
    {
        isInputKeyword = NO;
        [self.tableView reloadData];
        [self searchContext:self.historyArray[indexPath.row]];
        self.searchBar.textFiled.text = self.historyArray[indexPath.row];
        [self.view endEditing:YES];
        return;
    }
    
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
    
    if (playItem.navigation)
    {
        AmazonMusicSourceViewController *controller = [[AmazonMusicSourceViewController alloc] init];
        controller.playItem = playItem;
        controller.playHeader = playHeader;
        controller.cellType = AmazonMusic_Songs_Type;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        [self.view makeToast:AMAZONLOCALSTRING(@"primemusic_We_re_sorry__this_content_is_no_longer_available") duration:2 position:@"CSToastPositionCenter"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isInputKeyword && self.historyArray.count > 0)
    {
        return 50;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] init];
    if (isInputKeyword && self.historyArray.count > 0)
    {
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
        UIButton *deletebutton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 20, 50)];
        deletebutton.titleLabel.font = [UIFont systemFontOfSize:17];
        [deletebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deletebutton addTarget:self action:@selector(deleteAllHistory) forControlEvents:UIControlEventTouchUpInside];
        [deletebutton setTitle:AMAZONLOCALSTRING(@"primemusic_clear_recent_searches") forState:UIControlStateNormal];
        [headView addSubview:deletebutton];
        return headView;
    }
    
    headView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
    return headView;
}

- (void)deleteAllHistory
{
    [self.historyMethod deleteAllSearchKeyword];
    [self.historyArray removeAllObjects];
    [self.tableView reloadData];
}

//发起搜索请求
- (void)searchContext:(NSString *)searchKey
{
    if (self.playArray.count > 0)
    {
        [self.playArray removeAllObjects];
        [self.tableView reloadData];
    }
   
    [self.errorView dismiss];
    
    [self showHud:@""];
    [self.amazonNetWork searchMusic:searchKey success:^(LPAmazonMusicPlayHeader *header, NSArray<LPAmazonMusicPlayItem *> *list) {
        
        [self hideHud:@"" afterDelay:0 type:0];
        
        //添加header
        [self.playHeaderArray removeAllObjects];
        [self.playHeaderArray addObject:header];
        
        //添加item
        [self.playArray removeAllObjects];
        [self.playArray addObjectsFromArray:list];
        [self.tableView reloadData];
        
        if (list.count == 0)
        {
            [self.errorView show:AMAZONLOCALSTRING(@"primemusic_NO_Result")];
        }
        
    } failure:^(LPAmazonMusicNetworkError *error) {
        
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

- (LPAmazonMusicNetwork *)amazonNetWork{
    if (!_amazonNetWork) {
        _amazonNetWork = [[LPAmazonMusicNetwork alloc] init];
    }
    return _amazonNetWork;
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

- (AmazonMusicErrorView *)errorView
{
    if (!_errorView) {
        _errorView = [[AmazonMusicErrorView alloc] initWithFrame:CGRectMake(10, (SCREENHEIGHT - 64 - 200)/2.0, SCREENWIDTH - 20, 200)];
        [self.view insertSubview:_errorView aboveSubview:self.tableView];
    }
    return _errorView;
}

- (NSMutableArray *)historyArray
{
    if (!_historyArray) {
        _historyArray = [[NSMutableArray alloc] init];
    }
    return _historyArray;
}

- (AmazonMusicHistory *)historyMethod
{
    if (!_historyMethod) {
        _historyMethod = [[AmazonMusicHistory alloc] init];
    }
    return _historyMethod;
}

@end
