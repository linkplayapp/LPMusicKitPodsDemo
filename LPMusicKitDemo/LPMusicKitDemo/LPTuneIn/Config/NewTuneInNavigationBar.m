//
//  NewTuneInNavigationBar.m
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/2/16.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import "NewTuneInNavigationBar.h"

@interface NewTuneInNavigationBar ()

@property (nonatomic, strong) UIBarButtonItem *searchBut;
@property (nonatomic, strong) UIBarButtonItem *settingBut;
@property (nonatomic, strong) UIBarButtonItem *spaceBut;
@property (nonatomic, assign) NSInteger barViewHeight;

@property (nonatomic, strong) UIBarButtonItem *iconBut;
@property (nonatomic, strong) UIBarButtonItem *backBut;

@end

@implementation NewTuneInNavigationBar

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

- (NSArray *)navigationLeft
{
    if (@available(iOS 11.0,*))
    {
        return @[self.backBut,self.iconBut];
    }
    else
    {
        return @[self.backBut,self.iconBut,self.spaceBut];
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

- (void)backButClick
{
    if ([self.delegate respondsToSelector:@selector(selectMusicNavigationBar:)])
    {
        [self.delegate selectMusicNavigationBar:NavBut_Back];
    }
}

- (UIBarButtonItem *)searchBut
{
    if (!_searchBut) {
        UIButton *search;
        
        search = [UIButton buttonWithType:UIButtonTypeCustom];

        [search setFrame:CGRectMake(10,0, 44, self.barViewHeight)];
        search.contentEdgeInsets =UIEdgeInsetsMake(0, 10,0, 0);
        search.imageEdgeInsets =UIEdgeInsetsMake(0, 10,0, 0);
        [search setImage:[NewTuneInMethod imageNamed:@"tunein_search_title_n"] forState:UIControlStateNormal];
        [search setImage:[NewTuneInMethod imageNamed:@"tunein_search_title_d"] forState:UIControlStateHighlighted|UIControlStateSelected];
        [search addTarget:self action:@selector(searchClick)forControlEvents:UIControlEventTouchDown];
        _searchBut = [[UIBarButtonItem alloc] initWithCustomView:search];
    }
    return _searchBut;
}

- (UIBarButtonItem *)settingBut
{
    if (!_settingBut) {
        UIButton *setting;

        setting = [UIButton buttonWithType:UIButtonTypeCustom];
    
        [setting setFrame:CGRectMake(0,0, 44, self.barViewHeight)];
        [setting setImage:[NewTuneInMethod imageNamed:@"tunein_menu_title_n"] forState:UIControlStateNormal];
        [setting setImage:[NewTuneInMethod imageNamed:@"tunein_menu_title_d"] forState:UIControlStateHighlighted|UIControlStateSelected];
        setting.contentEdgeInsets =UIEdgeInsetsMake(0, 3,0, 0);
        setting.imageEdgeInsets =UIEdgeInsetsMake(0, 3,0, 0);
        [setting addTarget:self action:@selector(settingClick)forControlEvents:UIControlEventTouchUpInside];
         _settingBut = [[UIBarButtonItem alloc] initWithCustomView:setting];
    }
    return _settingBut;
}

- (UIBarButtonItem *)backBut
{
    if (!_backBut) {
        UIButton *backBut;
        backBut = [UIButton buttonWithType:UIButtonTypeCustom];
       
        [backBut setFrame:CGRectMake(0,0, 44, self.barViewHeight)];
        [backBut setImage:[NewTuneInMethod imageNamed:@"backButton"] forState:UIControlStateNormal];
        [backBut setImage:[NewTuneInMethod imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted|UIControlStateSelected];
        backBut.imageEdgeInsets =UIEdgeInsetsMake(0, -30, 0, 0);
        [backBut addTarget:self action:@selector(backButClick)forControlEvents:UIControlEventTouchUpInside];
        _backBut = [[UIBarButtonItem alloc] initWithCustomView:backBut];
    }
    return _backBut;
}


- (UIBarButtonItem *)iconBut
{
    if (!_iconBut) {
        UIButton *iconBut;
        iconBut = [UIButton buttonWithType:UIButtonTypeCustom];
        
        iconBut.userInteractionEnabled = NO;
        [iconBut setFrame:CGRectMake(0,0, 50, self.barViewHeight)];
        [iconBut setImage:[NewTuneInMethod imageNamed:@"tunein_logo_title"] forState:UIControlStateNormal];
        iconBut.contentEdgeInsets =UIEdgeInsetsMake(0, 3,0, 0);
        iconBut.imageEdgeInsets =UIEdgeInsetsMake(0, -30,0, 0);
        _iconBut = [[UIBarButtonItem alloc] initWithCustomView:iconBut];
    }
    return _iconBut;
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

