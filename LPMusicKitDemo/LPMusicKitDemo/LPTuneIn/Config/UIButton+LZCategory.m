//
//  UIButton+LZCategory.m
//  LZButtonCategory
//
//  Created by Jack on 20/2/5.
//  Copyright © 2020年 Artup. All rights reserved.
//

#import "UIButton+LZCategory.h"

@implementation UIButton (LZCategory)

- (void)setbuttonType:(LZCategoryType)type {
   
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0,0)];
    
    [self layoutIfNeeded];
    
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    
    CGFloat space = titleFrame.origin.x - imageFrame.origin.x - imageFrame.size.width - 5;
    
    if (type == LZCategoryTypeLeft) {

        [self setImageEdgeInsets:UIEdgeInsetsMake(0,titleFrame.size.width + space, 0, -(titleFrame.size.width + space))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -(titleFrame.origin.x - imageFrame.origin.x), 0, titleFrame.origin.x - imageFrame.origin.x)];

    } else if(type == LZCategoryTypeBottom) {
        
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0,0, titleFrame.size.height + space, -(titleFrame.size.width))];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(imageFrame.size.height + space, -(imageFrame.size.width), 0, 0)];
    }
    else if (type == LZCategoryTypeLocationChange)
    {
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -(titleFrame.size.width + space + 13))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -(imageFrame.size.width + space + 11))];
    }
}

@end
