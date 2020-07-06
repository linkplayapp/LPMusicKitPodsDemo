//
//  LPMultiroomViewController.m
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/23.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "LPMultiroomViewController.h"
#import <LPMusicKit/LPMultiroomManager.h>

@interface LPMultiroomViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation LPMultiroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Multi-Room";
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 19)];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
    doneButton.userInteractionEnabled = YES;
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.deviceArray = [NSMutableArray array];
    NSArray *slaveListArray = [[LPDeviceManager sharedInstance] slaveDeviceArray:self.uuid];
    NSArray *allDeviceArray = [[LPDeviceManager sharedInstance] deviceArray];
    for (LPDevice *device in allDeviceArray) {
        if (device.deviceStatus.UUID == self.uuid || [slaveListArray containsObject:device]) {
            [self.deviceArray addObject:@{@"device":device, @"check":@"1"}];
        }else {
            [self.deviceArray addObject:@{@"device":device, @"check":@"0"}];
        }
    }
}


#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deviceArray count];
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
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    NSDictionary *dict = self.deviceArray[indexPath.row];
    LPDevice *device = dict[@"device"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",device.deviceStatus.friendlyName, (device.deviceStatus.roomState == LP_ROOM_MASTER)?@"Master":@"Slave"];
    [cell setAccessoryType:[dict[@"check"] isEqualToString:@"1"]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
    cell.tintColor = [UIColor colorWithRed:00/255.0 green:178/255.0 blue:142/255.0 alpha:1];;
    UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_linew"]];
    lineView.frame = CGRectMake(0, 60, self.view.frame.size.width, 1);
    [cell.contentView addSubview:lineView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.deviceArray[indexPath.row]];
    BOOL isCheck = [dict[@"check"] intValue];
    isCheck = !isCheck;
    [dict setObject:[NSString stringWithFormat:@"%@",@(isCheck)] forKey:@"check"];
    [self.deviceArray replaceObjectAtIndex:indexPath.row withObject:[dict copy]];
    [self.tableView reloadData];
    

}

- (void)doneButtonClick {
    NSMutableArray *multiroomArray = [NSMutableArray array];
    for (NSDictionary * dict in self.deviceArray) {
        if ([dict[@"check"] isEqualToString:@"1"]) {
            [multiroomArray addObject:dict[@"device"]];
        }
    }
    if (multiroomArray.count > 0) {
        [[LPMultiroomManager sharedInstance] deviceMultiroomWithDeviceList:[multiroomArray copy] handler:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Multiroom success" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }]];
                    [self presentViewController:alertController animated:true completion:nil];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Multiroom failed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }]];
                    [self presentViewController:alertController animated:true completion:nil];
                });
            }
        }];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
