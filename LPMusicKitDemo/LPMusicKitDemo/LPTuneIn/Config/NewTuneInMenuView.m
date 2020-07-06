//
//  NewTuneInMenuView.m
//  iMuzo
//
//  Created by lyr on 2019/5/31.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "NewTuneInMenuView.h"
#import "UIButton+LZCategory.h"
#import "NewTuneInConfig.h"

@interface NewTuneInMenuView ()
{
    int menuWidth;
}

@property(nonatomic, strong) UIButton *homeBut;
@property(nonatomic, strong) UIButton *browseBut;
@property(nonatomic, strong) UIButton *favoriteBut;
@property(nonatomic, strong) UIButton *settingBut;
@property(nonatomic, strong) UIButton *customURLBut;


@end

@implementation NewTuneInMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *tapEditor = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapChange:)];
        tapEditor.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapEditor];
       
        self.hidden = YES;
        
        self.userInteractionEnabled = YES;
        [self setObject];
    }
    return self;
}

- (void)doTapChange:(UITapGestureRecognizer *)tap
{
    if (self.block)
    {
        self.block(5);
    }
}

- (void)setObject
{
    UIView *view = [[UIView alloc] init];
    
#ifdef AUDIOPRO_TARGET
    menuWidth = 133;
    view.frame = CGRectMake(SCREENWIDTH - 20 - menuWidth, 10, menuWidth, 210);
#else
    menuWidth = 123;
    view.frame = CGRectMake(SCREENWIDTH - 20 - menuWidth, 10, menuWidth, 170);
#endif
    
    view.layer.backgroundColor = [UIColor colorWithRed:10/255.0 green:34/255.0 blue:42/255.0 alpha:0.9].CGColor;
    view.layer.cornerRadius = 6;
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,2);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 2;
    view.userInteractionEnabled = YES;
    
    [self addSubview:view];
    [self addSubview:self.homeBut];
    [self addSubview:self.browseBut];
    [self addSubview:self.favoriteBut];
    [self addSubview:self.settingBut];
    
#ifdef AUDIOPRO_TARGET
    [self addSubview:self.customURLBut];
#endif
}

- (void)setSelect:(NSInteger)select
{
    _select = select;
    
    switch (select) {
        case 0:
        {
            self.homeBut.selected = YES;
            self.homeBut.userInteractionEnabled = NO;
        }
            break;
        case 1:
        {
            self.browseBut.selected = YES;
            self.browseBut.userInteractionEnabled = NO;
        }
            break;
        case 2:
        {
            self.favoriteBut.selected = YES;
            self.favoriteBut.userInteractionEnabled = NO;
        }
            break;
        case 3:
        {
            self.settingBut.selected = YES;
            self.settingBut.userInteractionEnabled = NO;
        }
            break;
        case 4:
        {
            self.customURLBut.selected = YES;
            self.customURLBut.userInteractionEnabled = NO;
        }
            break;
            
        default:
            break;
    }
}

- (UIButton *)homeBut
{
    if (!_homeBut)
    {
        _homeBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _homeBut.frame = CGRectMake(SCREENWIDTH - 20 - menuWidth + 5 , 5 + 10, menuWidth, 40);
       
        [_homeBut setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_homeBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
        
        _homeBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _homeBut.backgroundColor = [UIColor clearColor];
        [_homeBut setTitle:TUNEINLOCALSTRING(@"newtuneIn_Home") forState:UIControlStateNormal];
        [_homeBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_home_n"] forState:UIControlStateNormal];
        [_homeBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_home_d"] forState:UIControlStateSelected];
        
        [_homeBut addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
        [_homeBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_homeBut setTitleColor:HWCOLORA(80, 227, 194, 1) forState:UIControlStateSelected];
        
        _homeBut.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _homeBut;
}
- (UIButton *)browseBut
{
    if (!_browseBut)
    {
        _browseBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _browseBut.frame = CGRectMake(CGRectGetMinX(self.homeBut.frame), CGRectGetMaxY(self.homeBut.frame), menuWidth, 40);
        
        [_browseBut setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_browseBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
       
        _browseBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _browseBut.backgroundColor = [UIColor clearColor];
        [_browseBut setTitle:TUNEINLOCALSTRING(@"newtuneIn_Browse") forState:UIControlStateNormal];
        [_browseBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_browse_n"] forState:UIControlStateNormal];
        [_browseBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_browse_d"] forState:UIControlStateSelected];
        
        [_browseBut addTarget:self action:@selector(browseAction) forControlEvents:UIControlEventTouchUpInside];
        [_browseBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_browseBut setTitleColor:HWCOLORA(80, 227, 194, 1) forState:UIControlStateSelected];
        
        _browseBut.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _browseBut;
}

- (UIButton *)customURLBut
{
    if (!_customURLBut)
    {
        _customURLBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _customURLBut.frame = CGRectMake(CGRectGetMinX(self.settingBut.frame), CGRectGetMaxY(self.settingBut.frame), menuWidth, 40);
        
        [_customURLBut setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_customURLBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
       
        _customURLBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _customURLBut.backgroundColor = [UIColor clearColor];
        [_customURLBut setTitle:TUNEINLOCALSTRING(@"devicelist_Custom_URL") forState:UIControlStateNormal];
        [_customURLBut setImage:[NewTuneInMethod imageNamed:@"tunein_custom_n"] forState:UIControlStateNormal];
        [_customURLBut setImage:[NewTuneInMethod imageNamed:@"tunein_custom_d"] forState:UIControlStateSelected];
        [_customURLBut addTarget:self action:@selector(CustomAction) forControlEvents:UIControlEventTouchUpInside];
        [_customURLBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_customURLBut setTitleColor:HWCOLORA(80, 227, 194, 1) forState:UIControlStateSelected];
        
        _customURLBut.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _customURLBut;
}

- (UIButton *)favoriteBut
{
    if (!_favoriteBut)
    {
        _favoriteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteBut.frame = CGRectMake(CGRectGetMinX(self.browseBut.frame), CGRectGetMaxY(self.browseBut.frame), menuWidth, 40);
        
        [_favoriteBut setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_favoriteBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
        
        _favoriteBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _favoriteBut.backgroundColor = [UIColor clearColor];
        [_favoriteBut setTitle:TUNEINLOCALSTRING(@"newtuneIn_Favorites") forState:UIControlStateNormal];
        [_favoriteBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_favorites_n"] forState:UIControlStateNormal];
        [_favoriteBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_favorites_d"] forState:UIControlStateSelected];
        
        [_favoriteBut addTarget:self action:@selector(favotiteAction) forControlEvents:UIControlEventTouchUpInside];
        [_favoriteBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_favoriteBut setTitleColor:HWCOLORA(80, 227, 194, 1) forState:UIControlStateSelected];
        
        _favoriteBut.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _favoriteBut;
}
- (UIButton *)settingBut
{
    if (!_settingBut)
    {
        _settingBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBut.frame = CGRectMake(CGRectGetMinX(self.favoriteBut.frame), CGRectGetMaxY(self.favoriteBut.frame), menuWidth, 40);
        
        [_settingBut setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        [_settingBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
        
        _settingBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _settingBut.backgroundColor = [UIColor clearColor];
        [_settingBut setTitle:TUNEINLOCALSTRING(@"newtuneIn_Setting") forState:UIControlStateNormal];
        [_settingBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_settings_n"] forState:UIControlStateNormal];
        [_settingBut setImage:[NewTuneInMethod imageNamed:@"tunein_menu_settings_d"] forState:UIControlStateSelected];
        
        [_settingBut addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
        [_settingBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_settingBut setTitleColor:HWCOLORA(80, 227, 194, 1) forState:UIControlStateSelected];
        
        _settingBut.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _settingBut;
}

- (void)homeAction
{
    if (self.block)
    {
        self.block(0);
    }
}

- (void)browseAction
{
    if (self.block)
    {
        self.block(1);
    }
}

- (void)favotiteAction
{
    if (self.block)
    {
        self.block(2);
    }
}

- (void)settingAction
{
    if (self.block)
    {
        self.block(3);
    }
}

- (void)CustomAction
{
   if (self.block)
    {
        self.block(4);
    }
}


@end
