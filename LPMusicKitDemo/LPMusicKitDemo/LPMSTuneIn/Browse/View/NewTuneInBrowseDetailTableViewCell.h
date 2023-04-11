//
//  NewTuneInBrowseDetailTableViewCell.h
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BrowseDetailTableViewCellDidBlock)(id action);

@interface NewTuneInBrowseDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageLeftCon;
@property (weak, nonatomic) IBOutlet UIButton *presentButton;

@property (nonatomic, copy) BrowseDetailTableViewCellDidBlock block;

@end

NS_ASSUME_NONNULL_END
