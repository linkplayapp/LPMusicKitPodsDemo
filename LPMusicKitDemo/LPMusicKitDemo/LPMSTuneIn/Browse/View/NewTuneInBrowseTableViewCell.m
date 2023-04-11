//
//  NewTuneInBrowseTableViewCell.m
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInBrowseTableViewCell.h"

@implementation NewTuneInBrowseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.nextImage.tintColor = [UIColor whiteColor];
    self.titleLab.textColor = [UIColor whiteColor];
    self.lineLab.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
