//
//  LPDeviceListTableViewCell.h
//  LPVBSKitDemo
//
//  Created by sunyu on 2020/3/5.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPDeviceListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *UUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *IPLabel;

@end

NS_ASSUME_NONNULL_END
