//
//  UIButton+LZCategory.h
//  LZButtonCategory
//
//  Created by Artron_LQQ on 16/5/5.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LZCategoryType) {
    LZCategoryTypeLeft = 0,
    LZCategoryTypeBottom = 1,
    LZCategoryTypeLocationChange
};
@interface UIButton (LZCategory)

- (void)setbuttonType:(LZCategoryType)type;
@end
