//
//  AmazonMusicNavigationBar.m
//  iMuzo
//
//  Created by 程龙 on 2018/12/12.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import "AmazonMusicNavigationSet.h"
#import <UIKit/UIKit.h>

@interface AmazonMusicNavigationSet ()

@property (nonatomic, strong) UIBarButtonItem *searchBut;
@property (nonatomic, strong) UIBarButtonItem *settingBut;
@property (nonatomic, strong) UIBarButtonItem *spaceBut;
@property (nonatomic, assign) NSInteger barViewHeight;

@end

@implementation AmazonMusicNavigationSet

- (instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (NSArray *)navigationButHeight:(NSInteger)barViewHeight
{
    self.barViewHeight = barViewHeight;
    if (@available(iOS 11.0,*))
    {
        return @[self.settingBut,self.searchBut];
    }
    else
    {
        return @[self.settingBut,self.searchBut,self.spaceBut];
    }
}

- (void)searchClick
{
    if ([self.delegate respondsToSelector:@selector(selectMusicNavigationBar:)])
    {
        [self.delegate selectMusicNavigationBar:NavBut_Search];
    }
}

- (void)settingClick
{
    if ([self.delegate respondsToSelector:@selector(selectMusicNavigationBar:)])
    {
        [self.delegate selectMusicNavigationBar:NavBut_Setting];
    }
}

- (UIBarButtonItem *)searchBut
{
    if (!_searchBut) {
        UIButton *search = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, self.barViewHeight)];
        [search setImage:[AmazonMusicMethod imageNamed:@"searchcell_on"] forState:UIControlStateNormal];
        [search setImage:[AmazonMusicMethod imageNamed:@"searchcell"] forState:UIControlStateHighlighted|UIControlStateSelected];
        [search addTarget:self action:@selector(searchClick)forControlEvents:UIControlEventTouchDown];
        _searchBut = [[UIBarButtonItem alloc] initWithCustomView:search];
    }
    return _searchBut;
}

- (UIBarButtonItem *)settingBut
{
    if (!_settingBut) {
        UIButton *setting = [UIButton buttonWithType:UIButtonTypeCustom];
        [setting setFrame:CGRectMake(0, 0, 44, self.barViewHeight)];
        [setting setImage:[AmazonMusicMethod imageNamed:@"muzo_device_settings"] forState:UIControlStateNormal];
        setting.contentEdgeInsets =UIEdgeInsetsMake(0, 3,0, 0);
        setting.imageEdgeInsets =UIEdgeInsetsMake(0, 3,0, 0);
        [setting addTarget:self action:@selector(settingClick)forControlEvents:UIControlEventTouchUpInside];
         _settingBut = [[UIBarButtonItem alloc] initWithCustomView:setting];
    }
    return _settingBut;
}

- (UIBarButtonItem *)spaceBut
{
    if (!_spaceBut) {
        _spaceBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        _spaceBut.width = 10.0f;
    }
    return _spaceBut;
}

@end
