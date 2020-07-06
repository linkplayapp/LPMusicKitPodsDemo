//
//  AmazonSongsCollectionViewCell.h
//  iMuzo
//
//  Created by 许一宁 on 2017/10/30.
//  Copyright © 2017年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AddMusicButtonBlock)();

@interface AmazonSongsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic, copy) AddMusicButtonBlock block;
@property (strong, nonatomic) UIImageView *maskImage;



@end
