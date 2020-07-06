//
//  AmazonAlbumCollectionViewCell.m
//  iMuzo
//
//  Created by Ning on 2017/10/13.
//  Copyright © 2017年 wiimu. All rights reserved.
//

#import "AmazonAlbumCollectionViewCell.h"
#import "AmazonMusicMethod.h"

@implementation AmazonAlbumCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = THEME_DEFAULT_COLOR;
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AmazonAlbumCollectionViewCell" owner:self options:nil];
        
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
- (IBAction)SelectBut:(UIButton *)sender {
    if (_block) {
        _block();
    }
}

@end
