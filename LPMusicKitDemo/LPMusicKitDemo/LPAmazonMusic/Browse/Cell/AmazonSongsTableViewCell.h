//
//  AmazonSongsTableViewCell.h
//  iMuzo
//
//  Created by 刘宁 on 2018/4/13.
//  Copyright © 2018 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^selectButActionBlock)();
@interface AmazonSongsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBut;

@property (nonatomic,strong) selectButActionBlock block;

@end
