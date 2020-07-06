//
//  AmazonMusicMainTableViewCell.h
//  iMuzo
//
//  Created by 程龙 on 2018/12/6.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmazonMusicMainTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) LPAmazonMusicPlayItem *mode;


@end


