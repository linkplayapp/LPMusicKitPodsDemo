//
//  AmazonSongsCollectionViewCell.m
//  iMuzo
//
//  Created by 许一宁 on 2017/10/30.
//  Copyright © 2017年 wiimu. All rights reserved.
//

#import "AmazonSongsCollectionViewCell.h"

@implementation AmazonSongsCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AmazonSongsCollectionViewCell" owner:self options:nil];
        
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
- (IBAction)addMyMusicButton:(UIButton *)sender {
    
    if (_block) {
        _block();
    }
}

- (UIImageView *)maskImage
{
    if (!_maskImage) {
        _maskImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 56, 56)];
        _maskImage.backgroundColor = [UIColor grayColor];
        _maskImage.alpha = 0.5;
        _maskImage.hidden = YES;
    }
    
    return _maskImage;
}

@end
