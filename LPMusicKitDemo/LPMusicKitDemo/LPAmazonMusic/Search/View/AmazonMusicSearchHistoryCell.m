//
//  AmazonMusicSearchHistoryCell.m
//  LPMDPKitDemo
//
//  Created by lyr on 2019/9/29.
//  Copyright © 2019年 Linkplay-jack. All rights reserved.
//

#import "AmazonMusicSearchHistoryCell.h"
#import "AmazonMusicConfig.h"

@implementation AmazonMusicSearchHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lineImage.backgroundColor = HWCOLORA(255, 255, 255, 0.2);

    // Initialization code
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
