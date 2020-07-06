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
#import "NewTuneInConfig.h"
#import "NewTuneInSearchBarView.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInBrowseDetailController.h"
#import "UIButton+LZCategory.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"

@interface NewTuneInSearchController ()<NewTuneInSearchBarViewDelegate,UIGestureRecognizerDelegate>
{
    NSString *searchContext;
}
@property (weak, nonatomic) IBOutlet UILabel *statuLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchBarBack;

@property (strong, nonatomic) LPTuneInRequest *request;
@property (nonatomic, strong) NewTuneInSearchBarView *searchBar;

@property (nonatomic, strong) NSMutableArray *searchArray;
@property (assign, nonatomic) BOOL showHead;

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
    [self taleViewAndStatuHide:NO];
    [self setSearchBar];
}

- (void)taleViewAndStatuHide:(BOOL)hide
{
    self.statuLab.hidden = hide;
    self.tableView.hidden = !hide;
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

-(NSString *)navigationBarTitle
{
    return [TUNEINLOCALSTRING(@"newtuneIn_Search") uppercaseString];
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
    self.searchBar.backgroundColor = [UIColor clearColor];
    [self.searchBarBack addSubview:self.searchBar];
    self.searchBarBack.userInteractionEnabled = YES;

    self.tableView.tableFooterView = [self addFooterView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.backImage.image = [NewTuneInMethod imageNamed:@"NewTuneInBackImage"];
   
    self.statuLab.text = TUNEINLOCALSTRING(@"newtuneIn_Search_for_stations__podcasts__or_events");
}

- (void)backButtonPressedss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchContext:(NSString *)string
{
    [self showHud:@""];
    self.showHead = YES;
    
    [self.request tuneInSearchWithKeywords:string success:^(NSArray * _Nonnull list) {
        
        self.showHead = NO;
        [self hideHud:@"" afterDelay:0 type:MBProgressHUDModeIndeterminate];
        
        [self.searchArray removeAllObjects];
        [self.searchArray addObjectsFromArray:list];
        [self.tableView reloadData];
        
        if (self.searchArray.count > 0)
        {
            [self taleViewAndStatuHide:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        
        self.showHead = NO;
        NSString *message;
        if (error.code == -1001) {
            message =TUNEINLOCALSTRING(@"newtuneIn_Time_out");
        }else{
            message =TUNEINLOCALSTRING(@"newtuneIn_Fail");
        }
        [self hideHud:message afterDelay:2.0 type:MBProgressHUDModeIndeterminate];
    }];
}


#pragma mark ---- searchBarDelegate
- (void)newTuneInSearchBarView:(NSInteger)statu Text:(nonnull NSString *)text
{
    if (statu == 3)
    {
        searchContext = [[NSString alloc] initWithString:text];
        [self searchContext:text];
    }
    else if (statu == 4)
    {
        if (text.length > 0)
        {
            [self taleViewAndStatuHide:YES];
        }
        else
        {
            [self taleViewAndStatuHide:NO];
            self.showHead = YES;
            [self.tableView reloadData];
        }
    }
}

#pragma mark ---- TableViewDelegate && TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchArray.count == 0 && self.searchBar.textFiled.text.length > 0){
        return 1;
    }
    return self.searchArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchArray.count == 0){
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
        [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[NewTuneInMethod imageNamed:@"tunein_album_logo"]];
        cell.titleLab.attributedText = [self attributedStrLab:playItem.trackName SubLab:playItem.Subtitle itemLabColor:[UIColor whiteColor] subLabColor:newTuneIn_LIGHT_COLOR];
        
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

- (NSMutableAttributedString *)attributedStrLab:(NSString *)item SubLab:(NSString *)subLab itemLabColor:(UIColor *)itemColor subLabColor:(UIColor *)subColor
{
    NSMutableAttributedString *attributedStr;
    attributedStr = [[NSMutableAttributedString alloc] initWithString:item ? item:@"" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:SYSTEMFONT(16)}];
    if (subLab.length == 0)
    {
        return attributedStr;
    }
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName:itemColor,NSFontAttributeName:SYSTEMFONT(16)}]];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:subLab attributes:@{NSForegroundColorAttributeName:subColor,NSFontAttributeName:SYSTEMFONT(14)}]];
    return attributedStr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    if (self.searchArray.count == 0)
    {
        NSString *head = [NSString stringWithFormat:@"%@ \"%@\"",TUNEINLOCALSTRING(@"newtuneIn_No_Results_found_for"), self.searchBar.textFiled.text];
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 82)];
        if (self.showHead){
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
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeCustom];
    headBut.frame = CGRectMake(16, 0, SCREENWIDTH - 32 - premiumWidth, 50);
    headBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headBut.tag = section + 100;
    headBut.backgroundColor = [UIColor clearColor];
    
    //更多
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";

    [headBut setTitle:playHeader.headTitle forState:UIControlStateNormal];
    if (moreUrl.length > 0 || navigationStr.length > 0)
    {
        [headBut setImage:[NewTuneInMethod imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
        [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        headBut.userInteractionEnabled = YES;
    }else{
        headBut.userInteractionEnabled = NO;
    }
    [headBut setbuttonType:LZCategoryTypeLeft];
    [headBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    headBut.titleLabel.font = [UIFont systemFontOfSize:18];
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

- (void)premiumAction
{
    NewTuneInPremiumController *premiumController = [[NewTuneInPremiumController alloc] init];
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:premiumController];
    navcontroller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navcontroller animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    if (self.searchArray.count == 0){
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
            UIButton *headBut = [UIButton buttonWithType:UIButtonTypeCustom];
            headBut.backgroundColor = [UIColor clearColor];
            headBut.frame = CGRectMake(16, 10, SCREENWIDTH - 32, 40);
            [headBut setTitle:butTitle forState:UIControlStateNormal];
            [headBut setImage:[NewTuneInMethod imageNamed:@"devicelist_continue_n"] forState:UIControlStateNormal];
            [headBut setbuttonType:LZCategoryTypeLeft];
            [headBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            headBut.titleLabel.font = [UIFont systemFontOfSize:18];
            [headBut addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
            headBut.tag = section + 100;
            [footView addSubview:headBut];
        }
        return footView;
    }else{
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return footView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
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
    
    if (navigationStr.length > 0){
        
        NewTuneInBrowseDetailController *controller = [[NewTuneInBrowseDetailController alloc] init];
        controller.trackName = playHeader.headTitle;
        controller.url = navigationStr;
        [self.navigationController pushViewController:controller animated:YES];
    }else if (moreUrl.length > 0){
        
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
    [[NewTuneInMusicManager shared] presetMusicWithModel:playHeader index:index];
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


@end
