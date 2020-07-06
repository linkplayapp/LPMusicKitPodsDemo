//
//  AmazonAlbumCollectionViewCell.h
//  iMuzo
//
//  Created by Ning on 2017/10/13.
//  Copyright © 2017年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^albumSelectButtonBlock)();

@interface AmazonAlbumCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *SelectBUt;
@property (nonatomic, copy) albumSelectButtonBlock block;

@end
