//
//  NewTuneInSearchController.m
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInSearchController.h"
#import "NewTuneInSearchFirstCell.h"
#import "NewTuneInSearchSecondCell.h"
#import "NewTuneInSearchBarView.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"
#import "PresetViewController.h"

#import "LPTuneInSearchHistory.h"
#import "LPTuneInSearchHistoryTableViewCell.h"

#import "NewTuneInConfig.h"
#import "NewTuneInPublicMethod.h"
#import "Masonry.h"
@interface NewTuneInSearchController ()<NewTuneInSearchBarViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSString *searchContext;
    BOOL _isShowHistory;
}
@property (weak, nonatomic) IBOutlet UILabel *statuLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchBarBack;

@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NewTuneInSearchBarView *searchBar;
@property (strong, nonatomic) LPTuneInRequest *request;

@property (assign, nonatomic) BOOL showHead;

@property (nonatomic, strong) NSMutableArray *historyArray;//搜索历史
@property (nonatomic, strong) LPTuneInSearchHistory *historyMethod;//搜索历史管理

@end

@implementation NewTuneInSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //停止编辑
    UITapGestureRecognizer *tapEditor = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange:)];
    tapEditor.numberOfTapsRequired = 1;
    tapEditor.delegate = self;
    [self.view addGestureRecognizer:tapEditor];
    
    //搜索框
    self.statuLab.hidden = NO;
    self.tableView.hidden = YES;
    [self setSearchBar];
    
    //显示搜索历史
    self.historyArray = [self.historyMethod selectAllSearchHistory];
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

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

-(NSString *)navigationBarTitle
{
    return [LOCALSTRING(@"newtuneIn_Search") uppercaseString];
}

- (void)doTapChange:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSString *name = NSStringFromClass([touch.view class]);
    
    if ([name isEqualToString:@"UITableViewCellContentView"] || [name isEqualToString:@"UIControl"]) {
        
        //判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }
    //否则手势存在
    return YES;
}

- (void)setSearchBar
{
    self.searchBar = [[NewTuneInSearchBarView alloc] initWithFrame:CGRectMake(13, 18, SCREENWIDTH - 25, 50)];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    [self.searchBarBack addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12.5);
        make.left.mas_equalTo(12.5);
        make.top.mas_equalTo(self.view.mas_topMargin).offset(18);
        make.height.mas_equalTo(50);
    }];
    
    self.searchBarBack.userInteractionEnabled = YES;

    self.tableView.tableFooterView = [self addFooterView];
    
    self.statuLab.textColor = [UIColor whiteColor];
    self.statuLab.text = LOCALSTRING(@"newtuneIn_Search_for_stations__podcasts__or_events");
}

- (void)backButtonPressedss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchContext:(NSString *)string
{
    if (string.length == 0) {
        return;
    }

    [self showHud:nil];
    self.showHead = YES;
    [self.historyMethod addSearchKeyword:string];
    [self.historyArray removeObject:string];
    [self.historyArray addObject:string];
    
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInSearchWithKeywords:string success:^(NSArray * _Nonnull list) {

        [weakSelf.searchArray removeAllObjects];
        [weakSelf.searchArray addObjectsFromArray:list];
        
        [weakSelf hideHud:@"" afterDelay:0 type:0];
        weakSelf.showHead = NO;
        [weakSelf setShowHistory:NO];
        weakSelf.statuLab.hidden = YES;
        weakSelf.tableView.hidden = NO;
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        
        weakSelf.showHead = NO;
        NSString *message = [NewTuneInPublicMethod failureResultError:error];
        [weakSelf hideHud:message afterDelay:2.0 type:0];
    }];
}

- (void)setShowHistory:(BOOL)show
{
    _isShowHistory = show;
}

#pragma mark ---- searchBarDelegate
- (void)newTuneInSearchBarView:(NSInteger)statu Text:(nonnull NSString *)text
{
    if (statu == 3)
    {
        //开始搜索
        searchContext = [[NSString alloc] initWithString:text];
        [self searchContext:text];
    }
    else if (statu == 1 || statu == 4)
    {
//        if (text.length > 0)
//        {
            //显示历史记录
            if (self.historyArray.count > 0) {
            
                _isShowHistory = YES;
                self.statuLab.hidden = YES;
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }else{
                _isShowHistory = NO;
                self.statuLab.hidden = NO;
                self.tableView.hidden = YES;
            }
//        }
//        else
//        {
//            //显示提示语
//            _isShowHistory = NO;
//            self.statuLab.hidden = NO;
//            self.tableView.hidden = YES;
//            self.showHead = NO;
//        }
    }else if (statu == 2){
        
        if (self.historyArray.count == 0) {
            _isShowHistory = NO;
            self.statuLab.hidden = NO;
            self.tableView.hidden = YES;
        }
    }
}

#pragma mark ---- TableViewDelegate && TableViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.searchBar.textFiled.isEditing) {
        [self.view endEditing:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isShowHistory) {
        return 1;
    }
    if (self.searchArray.count == 0 && self.searchBar.textFiled.text.length > 0)
    {
        return 1;
    }
    return self.searchArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isShowHistory) {
        return self.historyArray.count;
    }
    
    if (self.searchArray.count == 0)
    {
        return 0;
    }
    
    LPTuneInPlayHeader *playHeader = self.searchArray[section];
    NSMutableArray *list = playHeader.children;
    if (list){
        return list.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isShowHistory) {
        
        NSString *searchKey = self.historyArray[indexPath.row];
        static NSString *kCellIdentifier = @"LPTuneInSearchHistoryTableViewCell";
        LPTuneInSearchHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil)
        {
           cell = [[[NSBundle mainBundle] loadNibNamed:@"LPTuneInSearchHistoryTableViewCell" owner:self options:nil] lastObject];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.titleLabel.text = self.historyArray[indexPath.row];
        __weak typeof(self) weakSelf = self;
        cell.block = ^()
        {
           [weakSelf.historyMethod deleteSearchKeyword:searchKey];
           [weakSelf.historyArray removeObject:searchKey];
           [weakSelf.tableView reloadData];
            
            if (weakSelf.historyArray.count == 0) {
                [weakSelf setShowHistory:NO];
                weakSelf.statuLab.hidden = NO;
                weakSelf.tableView.hidden = YES;
            }
        };
        return cell;
    }
    
    LPTuneInPlayHeader *playHeader = self.searchArray[indexPath.section];
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
        cell.backgroundColor = [UIColor clearColor];
        [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[UIImage imageNamed:@"tunein_album_logo"]];
        
        cell.titleLab.attributedText = [self attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor whiteColor] subLabColor:[UIColor lightGrayColor]];
        
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

- (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor
{
    NSMutableAttributedString *attributedStr;
    attributedStr = [[NSMutableAttributedString alloc] initWithString:item ? item:@"" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    if (subLab.length == 0)
    {
        return attributedStr;
    }
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:subLab attributes:@{NSForegroundColorAttributeName:subColor,NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
    return attributedStr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isShowHistory) {
        NSString *searchKey = self.historyArray[indexPath.row];
        self.searchBar.textFiled.text = searchKey;
        [self.view endEditing:YES];
        searchContext = [[NSString alloc] initWithString:searchKey];
        [self searchContext:searchKey];
        return;
    }

    LPTuneInPlayHeader *playHeader = self.searchArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
   
    if (self.searchBar.textFiled.isEditing)
    {
         [self.view endEditing:YES];
    }
    
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
    if (_isShowHistory) {
        return 50;
    }
    
    LPTuneInPlayHeader *playHeader = self.searchArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    
    if (playItem.trackImage.length > 0){
        return 82;
    }else{
        return 50;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_isShowHistory) {
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 5)];
        return headView;
    }
    
    if (self.searchArray.count == 0)
    {
        NSString *head = [NSString stringWithFormat:@"%@ \"%@\"",LOCALSTRING(@"newtuneIn_No_Results_found_for"), self.searchBar.textFiled.text];
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 82)];
        if (self.showHead)
        {
            return headView;
        }
        
        UILabel *headLab = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, SCREENWIDTH - 32, 82)];
        headLab.layer.borderWidth = 1;
        headLab.layer.borderColor = [UIColor grayColor].CGColor;
        headLab.layer.cornerRadius = 5;
        headLab.numberOfLines = 0;
        headLab.layer.masksToBounds = YES;
        headLab.backgroundColor = [UIColor clearColor];
        headLab.textColor = [UIColor whiteColor];
        headLab.font = [UIFont systemFontOfSize:18];
        headLab.textAlignment = NSTextAlignmentCenter;
        headLab.text = head;
        [headView addSubview:headLab];
        return headView;
    }
    
    UIView *headView = [[UIView alloc] init];
    LPTuneInPlayHeader *playHeader = self.searchArray[section];
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
    headView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeSystem];
    headBut.frame = CGRectMake(16, 0, SCREENWIDTH - 32 - premiumWidth, 50);
    headBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headBut.tag = section + 100;
    headBut.backgroundColor = [UIColor clearColor];
    
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";

    [headBut setTitle:playHeader.headTitle forState:UIControlStateNormal];
    if (moreUrl.length > 0 || navigationStr.length > 0)
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
    [self presentViewController:navcontroller animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isShowHistory) {
        return 5;
    }
    
    if (self.searchArray.count == 0){
        return 82;
    }
    
    LPTuneInPlayHeader *playHeader = self.searchArray[section];
    if (!(playHeader.headTitle.length > 0)){
        return 0;
    }
    return 50.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (_isShowHistory) {
        
        UIView *headView = [[UIView alloc] init];
        if (self.historyArray.count > 0)
        {
            headView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
            UIButton *deletebutton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH - 20, 50)];
            deletebutton.titleLabel.font = [UIFont systemFontOfSize:17];
            [deletebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [deletebutton addTarget:self action:@selector(deleteAllHistory) forControlEvents:UIControlEventTouchUpInside];
            [deletebutton setTitle:LOCALSTRING(@"newtuneIn_Remove_all_history") forState:UIControlStateNormal];
            [headView addSubview:deletebutton];
            return headView;
        }
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return headView;
    }
    
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    if (self.searchArray.count == 0)
    {
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return footView;
    }
    
    LPTuneInPlayHeader *playHeader = self.searchArray[section];
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    
    if (navigationStr.length > 0 || moreUrl.length > 0 )
    {
        NSString *butTitle = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Title"] :@"";
        if (butTitle.length == 0){
            butTitle = more[@"DisplayName"] ? more[@"DisplayName"] : @"";
        }
        
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
        if (butTitle.length > 0)
        {
            UIButton *headBut = [UIButton buttonWithType:UIButtonTypeSystem];
            headBut.backgroundColor = [UIColor clearColor];
            headBut.frame = CGRectMake(16, 10, SCREENWIDTH - 32, 40);
            [headBut setTitle:butTitle forState:UIControlStateNormal];
            [headBut setImage:[UIImage imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
            headBut.tintColor = [UIColor whiteColor];
            [headBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    if (_isShowHistory) {
        if (self.historyArray.count > 0){
            return 50;
        }
        return 0;
    }
    
    if (self.searchArray.count == 0){
        return 0;
    }
    
    LPTuneInPlayHeader *playHeader = self.searchArray[section];
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
    LPTuneInPlayHeader *playHeader = self.searchArray[sender.tag - 100];
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

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return  [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (void)presetMusicWithModel:(LPTuneInPlayHeader *)playHeader index:(NSInteger)index
{
    NSMutableArray *array = playHeader.children;
    LPTuneInPlayItem *playItem = array[index];

}

#pragma mark ------ history
- (void)deleteAllHistory
{
    [self.historyMethod deleteAllSearchKeyword];
    [self.historyArray removeAllObjects];
    [self.tableView reloadData];
    
    if (self.historyArray.count == 0) {
        _isShowHistory = NO;
        self.statuLab.hidden = NO;
        self.tableView.hidden = YES;
    }
}

- (NSMutableArray *)historyArray
{
    if (!_historyArray) {
        _historyArray = [[NSMutableArray alloc] init];
    }
    return _historyArray;
}

- (NSMutableArray *)searchArray
{
    if (!_searchArray) {
        _searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}

- (LPTuneInRequest *)request
{
    if (!_request) {
        _request = [[LPTuneInRequest alloc] init];
    }
    return _request;
}

- (LPTuneInSearchHistory *)historyMethod
{
    if (!_historyMethod) {
        _historyMethod = [[LPTuneInSearchHistory alloc] init];
    }
    return _historyMethod;
}


@end
