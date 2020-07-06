//
//  AmazonMusicSettingTableViewCell.m
//  iMuzo
//
//  Created by 程龙 on 2018/11/20.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonMusicSettingTableViewCell.h"

@implementation AmazonMusicSettingTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)switchButton:(id)sender
{
    if (self.block)
    {
        UISwitch *switchButton = (UISwitch *)sender;
        self.block(switchButton.on ? 1:0);
    }
}


@end
