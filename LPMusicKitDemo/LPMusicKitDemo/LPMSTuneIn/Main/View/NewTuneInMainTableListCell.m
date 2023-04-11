//
//  NewTuneInMainTableListCell.m
//  iMuzo
//
//  Created by lyr on 2019/5/29.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMainTableListCell.h"
#import "NewTuneInConfig.h"
#import "NewTuneInPublicMethod.h"

@implementation NewTuneInMainTableListCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    self.title.font = [UIFont systemFontOfSize:16];
    self.title.textColor = [UIColor whiteColor];
    
    self.time.font = [UIFont systemFontOfSize:12];
    self.time.textColor = HWCOLOR(173, 173, 173);
    
    self.duration.font = [UIFont systemFontOfSize:12];
    self.duration.textColor = HWCOLOR(173, 173, 173);
    
    self.line.backgroundColor = HWCOLOR(255, 255, 255);
    self.line.alpha = 0.2;

    self.moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.moreButton setTitle:@" ..." forState:UIControlStateNormal];
    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 23, 0, -23)];
    self.moreButton.tintColor = [UIColor whiteColor];
    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 33, 0, -33)];
    
    [self.presentButton setImage:[NewTuneInPublicMethod imageNamed:@"muzo_track_more_n"] forState:UIControlStateNormal];
    self.presentButton.tintColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)openMoreAction:(id)sender {

    if (self.block)
    {
        self.block(0);
    }
}

- (IBAction)presentButtonAction:(id)sender {
    
    if (self.block)
    {
        self.block(1);
    }
}

@end
