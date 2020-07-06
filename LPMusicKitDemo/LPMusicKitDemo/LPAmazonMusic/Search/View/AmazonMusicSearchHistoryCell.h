//
//  AmazonMusicSearchHistoryCell.h
//  LPMDPKitDemo
//
//  Created by lyr on 2019/9/29.
//  Copyright © 2019年 Linkplay-jack. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^deleteButtonBlock)(void);

@interface AmazonMusicSearchHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, copy) deleteButtonBlock block;


@end

NS_ASSUME_NONNULL_END
