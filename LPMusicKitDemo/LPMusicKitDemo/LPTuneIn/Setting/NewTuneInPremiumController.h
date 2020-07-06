//
//  NewTuneInPremiumController.h
//  iMuzo
//
//  Created by 程龙 on 2019/9/23.
//  Copyright © 2019 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NewTuneInPremiumControllerDelegate <NSObject>

- (void)newTuneInPremiumControllerResult:(BOOL)result;

@end


@interface NewTuneInPremiumController : UIViewController

@property (nonatomic,weak) id <NewTuneInPremiumControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
