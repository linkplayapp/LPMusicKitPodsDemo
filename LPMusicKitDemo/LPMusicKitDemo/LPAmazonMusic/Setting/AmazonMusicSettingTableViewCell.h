//
//  AmazonMusicSettingTableViewCell.h
//  iMuzo
//
//  Created by 程龙 on 2018/11/20.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^switchButtonBlock)(int target);

@interface AmazonMusicSettingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *selectBut;
@property (weak, nonatomic) IBOutlet UIImageView *nextImage;

@property (nonatomic, copy) switchButtonBlock block;

@end

