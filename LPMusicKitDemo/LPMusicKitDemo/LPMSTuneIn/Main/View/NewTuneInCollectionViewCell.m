//
//  NewTuneInCollectionViewCell.m
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInCollectionViewCell.h"
#import "NewTuneInConfig.h"
#import "NewTuneInPublicMethod.h"

@implementation NewTuneInCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.image.layer.masksToBounds = YES;
    self.image.layer.cornerRadius = 5;
    self.image.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    [self.moreButton setImage:[NewTuneInPublicMethod imageNamed:@"muzo_track_more_h"] forState:UIControlStateNormal];
    self.moreButton.tintColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"NewTuneInCollectionViewCell" owner:self options:nil];
        
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

- (IBAction)moreButtonAction:(id)sender {
    
    if (_block) {
        _block();
    }
}

@end
