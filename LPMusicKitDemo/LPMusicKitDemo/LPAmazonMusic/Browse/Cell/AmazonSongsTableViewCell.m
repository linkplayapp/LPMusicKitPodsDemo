//
//  AmazonSongsTableViewCell.m
//  iMuzo
//
//  Created by 刘宁 on 2018/4/13.
//  Copyright © 2018 wiimu. All rights reserved.
//

#import "AmazonSongsTableViewCell.h"

@implementation AmazonSongsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
}

- (IBAction)selectBut:(UIButton *)sender {
    if (_block) {
        _block();
    }
}

@end
