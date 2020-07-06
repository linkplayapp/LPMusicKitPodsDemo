//  category: alarm
//
//  AlarmClockChooseRateViewController.m
//  iMuzo
//
//  Created by Ning on 15/4/9.
//  Copyright (c) 2015年 wiimu. All rights reserved.
//
#define RATEKEY      @"rateKey"
#define CHOOSEDAYKEY @"chooseKey"
#define RATEINDEXKEY @"rateIndexKey"

#import "AlarmClockChooseRateViewController.h"

@interface AlarmClockChooseRateViewController ()
{
    NSMutableArray *rateInfoArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation AlarmClockChooseRateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundImageView.image = [UIImage imageNamed:@"global_default_backgound"];
    
    rateInfoArray = [ @[@[@{RATEKEY:@"alarm_Once",CHOOSEDAYKEY:@"NO"}],
                        @[@{RATEKEY:@"alarm_Sunday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(6)},
                          @{RATEKEY:@"alarm_Monday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(0)},
                          @{RATEKEY:@"alarm_Tuesday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(1)},
                          @{RATEKEY:@"alarm_Wednesday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(2)},
                          @{RATEKEY:@"alarm_Thursday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(3)},
                          @{RATEKEY:@"alarm_Friday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(4)},
                          @{RATEKEY:@"alarm_Saturday",CHOOSEDAYKEY:@"NO",RATEINDEXKEY:@(5)}]] mutableCopy];

    //处理已经选中的情况
    if (!self.isOnced)
    {
        NSMutableArray *tempArray = [rateInfoArray[1] mutableCopy];
        NSArray *tempRateArray = self.rateDaysSpecial;;
        for (int i = 0;i<[tempRateArray count];i++)
        {
            NSString *str = tempRateArray[i];
            for (int j = 0;j< [tempArray count];j++)
            {
                NSMutableDictionary *primyDictionary = [tempArray[j] mutableCopy];
                if(str == primyDictionary[RATEINDEXKEY])
                {
                    [primyDictionary setObject:@"YES" forKey:CHOOSEDAYKEY];
                    [tempArray replaceObjectAtIndex:j withObject:primyDictionary];
                    break;
                }
            }
        }
        [rateInfoArray replaceObjectAtIndex:1 withObject:tempArray];
    }else{
        NSMutableArray *tempArray = [rateInfoArray[0] mutableCopy];
        NSMutableDictionary *tempDictionary = [tempArray[0] mutableCopy];
        [tempDictionary setObject:@"YES" forKey:CHOOSEDAYKEY];
        [tempArray replaceObjectAtIndex:0 withObject:tempDictionary];
        [rateInfoArray replaceObjectAtIndex:0 withObject:tempArray];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)navigationBarTitle
{
    return [@"alarm_Rate" uppercaseString];
}

- (BOOL)isNavigationBackEnabled
{
    return YES;
}

#pragma mark- UITableViewDelegate &&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [rateInfoArray count];
}

- (BOOL)needBackGroundImageView
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = rateInfoArray[section];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"kCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    else
    {
        for(UIView * subview in [cell.contentView subviews])
        {
            [subview removeFromSuperview];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    NSArray *sArray = rateInfoArray[indexPath.section];
    NSDictionary *rDictionary = sArray[indexPath.row];
    cell.textLabel.text = rDictionary[RATEKEY];
    [cell setAccessoryType:[rDictionary[CHOOSEDAYKEY] isEqualToString:@"YES"]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
    cell.tintColor = [UIColor colorWithRed:00/255.0 green:178/255.0 blue:142/255.0 alpha:1];;
    UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_linew"]];
    lineView.frame = CGRectMake(0, 60, self.view.frame.size.width, 1);
    [cell.contentView addSubview:lineView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSMutableArray *sectionArray = [rateInfoArray[indexPath.section] mutableCopy];
        NSMutableDictionary *mutableDictionary = [sectionArray[indexPath.row] mutableCopy];
        NSMutableArray *sectionTwoArray = [rateInfoArray[1] mutableCopy];
        if ([mutableDictionary[CHOOSEDAYKEY] isEqualToString:@"NO"])
        {
            [mutableDictionary setValue:@"YES" forKey:CHOOSEDAYKEY];
            for (int i = 0; i< [rateInfoArray[1] count] ; i++)
            {
                NSMutableDictionary *dictionary = [sectionTwoArray[i] mutableCopy];
                [dictionary setValue:@"NO" forKey:CHOOSEDAYKEY];
                [sectionTwoArray replaceObjectAtIndex:i withObject:dictionary];
            }
            [rateInfoArray replaceObjectAtIndex:1 withObject:sectionTwoArray];
        }
        else
        {
            [mutableDictionary setValue:@"NO" forKey:CHOOSEDAYKEY];
        }
        [sectionArray replaceObjectAtIndex:indexPath.row withObject:mutableDictionary];
        [rateInfoArray replaceObjectAtIndex:0 withObject:sectionArray];

        if ([self.delegate respondsToSelector:@selector(chooseResultRate:isOnlyOnce:)])
        {
            [self.delegate chooseResultRate:mutableDictionary isOnlyOnce:YES];
        }
    }
    else
    {
        //更新once选中
        NSMutableArray *sectionArray = [rateInfoArray[0] mutableCopy];
        NSMutableDictionary *onceDictionary = [sectionArray[0] mutableCopy];
        [onceDictionary setValue:@"NO" forKey:CHOOSEDAYKEY];
        [sectionArray replaceObjectAtIndex:0 withObject:onceDictionary];

        //更新week扩展模式
        NSMutableArray *sectionTwoArray = [rateInfoArray[indexPath.section] mutableCopy];
        NSMutableDictionary *mutableDictionary = [sectionTwoArray[indexPath.row] mutableCopy];
        if ([mutableDictionary[CHOOSEDAYKEY] isEqualToString:@"NO"])
        {
            [mutableDictionary setValue:@"YES" forKey:CHOOSEDAYKEY];
        }
        else
        {
            [mutableDictionary setValue:@"NO" forKey:CHOOSEDAYKEY];
        }
        [sectionTwoArray replaceObjectAtIndex:indexPath.row withObject:mutableDictionary];
        [rateInfoArray replaceObjectAtIndex:0 withObject:sectionArray];
        [rateInfoArray replaceObjectAtIndex:indexPath.section withObject:sectionTwoArray];
        BOOL isAllNotChoose = YES;
        for (NSDictionary * dict in sectionTwoArray)
        {
            if ([dict[CHOOSEDAYKEY] isEqualToString:@"YES"])
            {
                isAllNotChoose = NO;
                break;
            }
        }
        if (isAllNotChoose)
        {
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }

        if ([self.delegate respondsToSelector:@selector(chooseResultRate:isOnlyOnce:)])
        {
            [self.delegate chooseResultRate:mutableDictionary isOnlyOnce:NO];
        }

    }

    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}


@end
