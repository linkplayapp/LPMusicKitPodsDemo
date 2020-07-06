//
//  NewTuneInBrowseDetailTableViewCell.m
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInBrowseDetailTableViewCell.h"
#import "NewTuneInConfig.h"

@implementation NewTuneInBrowseDetailTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.backImage.layer.masksToBounds = YES;
    self.backImage.layer.cornerRadius = 4;
    self.backImage.backgroundColor = HWCOLORA(0, 0, 0, 0.5);
    
    [self.presentButton setImage:[NewTuneInMethod imageNamed:@"XMLYcell_preset_on"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)presentButtonAction:(id)sender {
    
    if (_block) {
        _block(@"");
    }
}

@end
