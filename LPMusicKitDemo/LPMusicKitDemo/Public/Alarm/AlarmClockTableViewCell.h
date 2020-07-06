//
//  AlarmClockTableViewCell.h
//  iMuzo
//
//  Created by Ning on 15/4/9.
//  Copyright (c) 2015年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmClockTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;

@end
