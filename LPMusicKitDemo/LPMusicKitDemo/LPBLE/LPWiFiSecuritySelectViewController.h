//
//  LPSecuritySelectViewController.h
//  iMuzo
//
//  Created by sunyu on 2020/12/25.
//  Copyright © 2020 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WiFiSecuritySelectDelegate <NSObject>

- (void)selectWiFiSecurity:(NSInteger)selectIndex;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LPWiFiSecuritySelectViewController : UIViewController

@property (nonatomic, strong) NSArray *securityArray;
@property (nonatomic, assign) NSInteger currentRow; 
@property (nonatomic, weak) id<WiFiSecuritySelectDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
