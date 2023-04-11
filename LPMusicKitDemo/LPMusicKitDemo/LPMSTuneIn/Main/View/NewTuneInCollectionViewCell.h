//
//  NewTuneInCollectionViewCell.h
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void (^TuneInCollectionViewMoreBlock)();

@interface NewTuneInCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton * moreButton;

@property (copy, nonatomic) TuneInCollectionViewMoreBlock block;

@end

NS_ASSUME_NONNULL_END
