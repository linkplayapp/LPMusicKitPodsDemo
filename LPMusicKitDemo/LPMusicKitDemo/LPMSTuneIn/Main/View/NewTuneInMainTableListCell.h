//
//  NewTuneInMainTableListCell.h
//  iMuzo
//
//  Created by lyr on 2019/5/29.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MainTableListCellDidBlock)(int type);

@interface NewTuneInMainTableListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *line;

@property (nonatomic, copy) MainTableListCellDidBlock block;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *curationHeightCon;

@property (weak, nonatomic) IBOutlet UIButton *presentButton;

@end

NS_ASSUME_NONNULL_END
