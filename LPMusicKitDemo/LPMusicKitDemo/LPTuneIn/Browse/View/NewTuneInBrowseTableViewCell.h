//
//  NewTuneInBrowseTableViewCell.h
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewTuneInBrowseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *nextImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *lineLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TitleLeftCon;

@end

NS_ASSUME_NONNULL_END
