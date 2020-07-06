//
//  NewTuneInCollectionViewImageCell.m
//  iMuzo
//
//  Created by lyr on 2019/5/31.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInCollectionViewImageCell.h"
#import "NewTuneInConfig.h"

@implementation NewTuneInCollectionViewImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.image.layer.masksToBounds = YES;
    self.image.layer.cornerRadius = 5;
    self.image.backgroundColor = HWCOLORA(0, 0, 0, 0.5);
    self.presentButton.backgroundColor = HWCOLORA(0, 0, 0, 0.5);
    
    self.presentButton.layer.masksToBounds = YES;
    self.presentButton.layer.cornerRadius = 22;
    
    [self.presentButton setImage:[NewTuneInMethod imageNamed:@"XMLYcell_preset_on"] forState:UIControlStateNormal];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"NewTuneInCollectionViewImageCell" owner:self options:nil];
        
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

- (IBAction)presentButtonAction:(id)sender {
    
    if (_block) {
        _block();
    }
}

@end
