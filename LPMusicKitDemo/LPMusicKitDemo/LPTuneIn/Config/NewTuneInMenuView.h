//
//  NewTuneInMenuView.h
//  iMuzo
//
//  Created by lyr on 2019/5/31.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MainMenuBlock)(NSInteger index);

@interface NewTuneInMenuView : UIView

@property (nonatomic, copy) MainMenuBlock block;
@property (nonatomic, assign) NSInteger select;

@end

NS_ASSUME_NONNULL_END
