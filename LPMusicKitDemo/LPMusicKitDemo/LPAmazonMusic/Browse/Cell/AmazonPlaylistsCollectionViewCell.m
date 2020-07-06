//
//  AmazonPlaylistsCollectionViewCell.m
//  iMuzo
//
//  Created by 许一宁 on 2018/4/13.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonPlaylistsCollectionViewCell.h"

@implementation AmazonPlaylistsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AmazonPlaylistsCollectionViewCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionReusableView类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionReusableView class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
        
    }
    return self;
}
- (IBAction)selectButAction:(UIButton *)sender {
    if (_block) {
        _block();
    }
}

@end
