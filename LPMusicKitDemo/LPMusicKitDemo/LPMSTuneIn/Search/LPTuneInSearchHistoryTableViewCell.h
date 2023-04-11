//
//  LPTuneInSearchHistoryTableViewCell.h
//  iMuzo
//
//  Created by lyr on 2020/9/4.
//  Copyright © 2020 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^deleteButtonBlock)(void);

@interface LPTuneInSearchHistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, copy) deleteButtonBlock block;


@end

NS_ASSUME_NONNULL_END
