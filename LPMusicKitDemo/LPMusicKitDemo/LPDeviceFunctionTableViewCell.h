//
//  LPDeviceFunctionTableViewCell.h
//  LPMusicKitDemo
//
//  Created by sunyu on 2020/9/9.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPDeviceFunctionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

NS_ASSUME_NONNULL_END
