//
//  LPTuneInSearchHistoryTableViewCell.m
//  iMuzo
//
//  Created by lyr on 2020/9/4.
//  Copyright © 2020 wiimu. All rights reserved.
//

#import "LPTuneInSearchHistoryTableViewCell.h"

@implementation LPTuneInSearchHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.titleLabel.textColor = THEME_DEFAULT_COLOR;
//    self.lineImage.backgroundColor = [THEME_DEFAULT_COLOR colorWithAlphaComponent:0.7];
//    self.deleteButton.needTint = true;
//    self.deleteButton.tintColor = THEME_DEFAULT_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteButtonAction:(id)sender
{
    if (_block) {
        _block();
    }
}

@end
