//
//  AmazonMusicErrorView.m
//  iMuzo
//
//  Created by lyr on 2019/6/6.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicErrorView.h"

@interface AmazonMusicErrorView ()

@property (nonatomic, strong) UILabel *showLab;

@end

@implementation AmazonMusicErrorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.showLab.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

- (void)show:(NSString *)string
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (string.length == 0)
        {
            self.hidden = YES;
        }
        else
        {
            self.hidden = NO;
        }
        
        self.showLab.text = string;
    });
}

- (void)dismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.hidden = YES;
        self.showLab.text = @"";
    });
}

- (UILabel *)showLab
{
    if (!_showLab) {
        _showLab = [[UILabel alloc] init];
        _showLab.textColor = [UIColor whiteColor];
        _showLab.backgroundColor = [UIColor clearColor];
        _showLab.textAlignment = NSTextAlignmentCenter;
        _showLab.font = [UIFont systemFontOfSize:18];
        _showLab.numberOfLines = 0;
        [self addSubview:_showLab];
    }
    return _showLab;
}

@end
