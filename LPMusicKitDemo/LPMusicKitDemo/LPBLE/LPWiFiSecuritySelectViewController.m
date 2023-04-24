//
//  LPSecuritySelectViewController.m
//  iMuzo
//
//  Created by sunyu on 2020/12/25.
//  Copyright © 2020 wiimu. All rights reserved.
//

#import "LPWiFiSecuritySelectViewController.h"

@interface LPWiFiSecuritySelectViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation LPWiFiSecuritySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Type";
    [self backButtonItem];
    
    self.tableView.tableFooterView = [self addFooterView];
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)backButtonItem {
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame =CGRectMake(0, 0, 60, 44);
    [btn setTitle:@"BACK" forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftBarButtonItemReturnAction) forControlEvents:(UIControlEventTouchUpInside)];
    UIBarButtonItem *leftItem0 = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem0;
}

- (UIView *)addFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}


- (void)leftBarButtonItemReturnAction {
    if ([self.delegate respondsToSelector:@selector(selectWiFiSecurity:)]) {
        [self.delegate selectWiFiSecurity:self.currentRow];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- UITableViewDelegate &&UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.securityArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    else
    {
        for (UIView *subView in cell.contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    NSDictionary *dict = self.securityArray[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    [cell setAccessoryType:(indexPath.row == self.currentRow)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentRow = (int)indexPath.row;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
