//
//  NewTuneInBrowseDetailController.m
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInBrowseDetailController.h"
#import "NewTuneInBrowseTableViewCell.h"
#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInMusicDetailController.h"
#import "NewTuneInMainTableViewCell.h"
#import "NewTuneInMainTableListCell.h"
#import "NewTuneInMoreViewController.h"
#import "NewTuneInPremiumController.h"
#import "PresetViewController.h"
#import "NewTuneInPublicMethod.h"
#import "NewTuneInConfig.h"
#import "MJRefresh.h"

#define CONTROOLER_NAME @"NewTuneInBrowseDetailController"

@interface NewTuneInBrowseDetailController ()<MJRefreshBaseViewDelegate,NewTuneInPremiumControllerDelegate>
{
    MJRefreshHeaderView *headerView;
    NSString *_selectId;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) UILabel *statuLab;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableDictionary *itemCellDict;
@property (strong, nonatomic) LPTuneInRequest *request;

@end

@implementation NewTuneInBrowseDetailController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableview.tableFooterView = [self addFooterView];
    //self.title = self.name;
    

    self.backImage.hidden = YES;
    
    //refresh
    headerView = [MJRefreshHeaderView header];
    headerView.scrollView = self.tableview;
    headerView.delegate = self;
    
    [self requestData:self.url];
}
-(NSString *)navigationBarTitle{
    return  self.name;
}

- (void)requestData:(NSString *)url
{
    [self showHud:nil];
    self.statuLab.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [self.request lpTuneInGetDifferentTypesContentList:url success:^(NSArray * _Nonnull list) {
        
        [weakSelf hideHud:@"" afterDelay:0 type:0];
        weakSelf.itemCellDict = [[NSMutableDictionary alloc] init];
        for (LPTuneInPlayHeader *playHeader in list) {
            
            NSArray *children = playHeader.children;
            for (LPTuneInPlayItem *playItem in children) {
                
               //文字+详情
               NSDictionary *dict = playItem.Presentation;
               if (dict && [dict[@"Layout"] isEqualToString:@"OnDemandTile"]){
                   
                   NSDictionary *cellHeightDict = [NewTuneInPublicMethod dealDescriptionHeightWithPlayItem:playItem isOpenMore:NO];
                   [weakSelf.itemCellDict setValue:@{
                       @"isOpen":@(NO),
                       @"cellDict":cellHeightDict
                   } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];
               }
            }
        }
        
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:list];
        [weakSelf.tableview reloadData];
    
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
            [self requestData:self.url];
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

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

-(void)mediaInfoChanged
{
    [super mediaInfoChanged];
    
    NSString *trackId = CURBOX.mediaInfo.songId;
    if ([trackId isEqualToString:_selectId]) {
        return;
    }
    _selectId = [trackId copy];
    [self.tableview reloadData];
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
    if (list){
        NSString *present = playHeader.Presentation ? playHeader.Presentation[@"Layout"] : @"";
        if ([present isEqualToString:@"Gallery"]){
            return 1;
        }else{
            return list.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
  
    NSDictionary *presentation = playItem.Presentation;
    NSString *Prompt = presentation ? presentation[@"Layout"] : @"";
    //cell是提示语
    if ([Prompt isEqualToString:@"Prompt"])
    {
        static NSString *cellID = @"TableViewcellPromptId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        else
        {
            for (UIView *subView in cell.contentView.subviews)
            {
                [subView removeFromSuperview];
            }
        }
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, SCREENWIDTH - 44, 50)];
        detailLab.layer.borderWidth = 1;
        detailLab.layer.borderColor = [UIColor grayColor].CGColor;
        detailLab.layer.cornerRadius = 5;
        detailLab.layer.masksToBounds = YES;
        detailLab.text = playItem.trackName;
        detailLab.textColor = [UIColor whiteColor];
        detailLab.numberOfLines = 0;
        detailLab.textAlignment = NSTextAlignmentCenter;
        detailLab.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:detailLab];
        return cell;
    }
    
    //显示详情文字的cell
    if ([Prompt isEqualToString:@"OnDemandTile"])
    {
        NSString *kCellIdentifier = @"NewTuneInMainTableOnDemandTileCell";
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
        else
        {
            cell.title.textColor = [UIColor whiteColor];
        }
        
        BOOL isOpenMore = [cellDict[@"openMore"] boolValue];
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
                    @"isOpen":@(newOpenMore),
                    @"cellDict":cellHeightDict
                } forKey:[NSString stringWithFormat:@"%@%@",playItem.trackId, playItem.trackName]];
                
                [weakSelf.tableview reloadData];
            }
            else
            {
                [weakSelf presetMusicWithModel:playHeader index:indexPath.row];
            }
        };
        return cell;
    }
    
    NSDictionary *presentations = playHeader.Presentation;
    NSString *gallery = presentations ? presentations[@"Layout"] : @"";
    
    //横向显示
    if ([gallery isEqualToString:@"Gallery"])
    {
        NSInteger index = indexPath.section;
        NSString *itemPresentation = playItem.Presentation ? playItem.Presentation[@"Layout"] : @"";
        
        if ([itemPresentation isEqualToString:@"BrickTile"])
        {
            NewTuneInMainTableViewCell *cell = [NewTuneInMainTableViewCell cellWithTableView:tableView CellType:[NSString stringWithFormat:@"newTuneInMainTableViewImageBrickTileCell%ld",(long)index] type:Cell_image];
            
            __weak typeof(self) weakSelf = self;
            cell.block = ^(NSInteger selectIndex, NSInteger type)
            {
                if (type == 1) {
                    [weakSelf presetMusicWithModel:playHeader index:selectIndex];
                }else{
                    [weakSelf didSelectHeader:playHeader index:selectIndex];
                }
            };
            cell.playHeader = playHeader;
            cell.controllerName = CONTROOLER_NAME;
            return cell;
        }
        else
        {
            NewTuneInMainTableViewCell *cell = [NewTuneInMainTableViewCell cellWithTableView:tableView CellType:[NSString stringWithFormat:@"newTuneInMainTableViewTitleBrickTileCell%ld",(long)index] type:Cell_image_title];
            __weak typeof(self) weakSelf = self;
            cell.block = ^(NSInteger selectIndex, NSInteger type)
            {
                if (type == 1) {
                    [weakSelf presetMusicWithModel:playHeader index:selectIndex];
                }else{
                    [weakSelf didSelectHeader:playHeader index:selectIndex];
                }
            };
            cell.playHeader = playHeader;
            cell.controllerName = CONTROOLER_NAME;
            return cell;
        }
    }
    //竖排显示
    else
    {
        if (playItem.trackImage.length > 0)
        {
            NSString *kCellIdentifier = @"NewTuneInBrowseDetailImageViewCell";
            NewTuneInBrowseDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInBrowseDetailTableViewCell" owner:self options:nil] lastObject];
            }
            cell.backgroundColor = [UIColor clearColor];
            [cell.backImage sd_setImageWithURL:[NSURL URLWithString:playItem.trackImage] placeholderImage:[UIImage imageNamed:@"tunein_album_logo"]];
            
            if ([NewTuneInPublicMethod isCurrentPlayingPlayItem:playItem])
            {
                cell.titleLab.attributedText = [NewTuneInPublicMethod attributedStrLab:playItem.trackName SubLab:playItem.Subtitle  itemLabColor:[UIColor lightGrayColor] subLabColor:[UIColor lightGrayColor]];
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
            NSString *kCellIdentifier = @"NewTuneInBrowseTitleViewCell";
            NewTuneInBrowseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"NewTuneInBrowseTableViewCell" owner:self options:nil] lastObject];
            }
            
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
    [self.tableview reloadData];
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPTuneInPlayHeader *playHeader = self.dataArray[indexPath.section];
    NSMutableArray *list = playHeader.children;
    LPTuneInPlayItem *playItem = list[indexPath.row];
    NSString *headerPresentation = playHeader.Presentation ? playHeader.Presentation[@"Layout"] : @"";
    
    NSDictionary *itemPresentation = playItem.Presentation;
    NSString *itemLayout = itemPresentation ? itemPresentation[@"Layout"] : @"";
    if ([itemLayout isEqualToString:@"Prompt"]){
        return 50;
    }
    
    if ([itemLayout isEqualToString:@"OnDemandTile"]){
        
        NSMutableDictionary *itemCellDict = [self.itemCellDict objectForKey:[NSString stringWithFormat:@"%@%@",playItem.trackId,playItem.trackName]];
        NSMutableDictionary *cellDict = itemCellDict[@"cellDict"] ? itemCellDict[@"cellDict"] :@{};
        return [cellDict[@"height"] floatValue];
    }
    
    if ([headerPresentation isEqualToString:@"Gallery"]){
        
        if ([itemLayout isEqualToString:@"BrickTile"]){
            return 95;
        }
        return 145;
    }else{
        
        if (playItem.trackImage.length > 0){
            return 82;
        }
        return 50;
    }
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
        headView.backgroundColor = [UIColor clearColor];
        headView.frame = CGRectMake(0, 0, SCREENWIDTH, 5);
        return headView;
    }
    
    headView.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
    UIButton *headBut = [UIButton buttonWithType:UIButtonTypeSystem];
    headBut.frame = CGRectMake(22, 0, SCREENWIDTH - 22, 50);
    
    //premium
    if ([playHeader.Premium isEqualToString:@"1"])
    {
        UIButton *premiumButton = [self createPremiumButton];
        [headView addSubview:premiumButton];
        headBut.frame = CGRectMake(22, 0, SCREENWIDTH - 98 - 44, 50);
    }
    headBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headBut.tag = section + 100;
    headBut.backgroundColor = [UIColor clearColor];
   
    //
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    
    //
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
    premiumController.delegate = self;
    [self presentViewController:navcontroller animated:YES completion:nil];
}

- (void)newTuneInPremiumControllerResult:(BOOL)result
{
    if (result)
    {
        [self requestData:self.url];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataArray.count == 0)
    {
        return 0;
    }
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    if (!(playHeader.headTitle.length > 0))
    {
        return 5;
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
    
    //横排，去除button
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    NSString *present = playHeader.Presentation ? playHeader.Presentation[@"Layout"] : @"";
    if ([present isEqualToString:@"Gallery"])
    {
        footView.frame = CGRectMake(0, 0, SCREENWIDTH, 0);
        return footView;
    }
    
    //判断添加button
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
            [headBut setTitle:butTitle forState:UIControlStateNormal];
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
    if (self.dataArray.count == 0)
    {
        return 0;
    }
    LPTuneInPlayHeader *playHeader = self.dataArray[section];
    NSString *present = playHeader.Presentation ? playHeader.Presentation[@"Layout"] : @"";
    if ([present isEqualToString:@"Gallery"])
    {
        return 0;
    }
    NSDictionary *more = playHeader.Pivots ? playHeader.Pivots[@"More"]: nil;
    NSString *moreUrl = more ? more[@"Url"]:@"";
    NSString *navigationStr = playHeader.ContainerNavigation ? playHeader.ContainerNavigation[@"Url"] :@"";
    if (navigationStr.length > 0 || moreUrl.length > 0)
    {
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
        _statuLab = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREENHEIGHT/4.0, SCREENWIDTH - 20, 100)];
        _statuLab.font = [UIFont systemFontOfSize:16];
        _statuLab.textColor = [UIColor whiteColor];
        _statuLab.numberOfLines = 0;
        _statuLab.hidden = YES;
        _statuLab.textAlignment = NSTextAlignmentCenter;
        [self.tableview addSubview:_statuLab];
    }
    return _statuLab;
}

@end
