//
//  BasicViewController.m
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/2/24.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import "BasicViewController.h"
#import "UIImageView+WebCache.h"
#import "NSObject+FBKVOController.h"

@interface BasicViewController ()

@property (nonatomic, strong) UIImageView *blackImage;
@property (nonatomic, strong) UIImageView * base_blurView;

@end

@implementation BasicViewController
@synthesize HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"class name =========================== %@",className);
    
    //backColor
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1.0];
    
    //backBut
    if([self isNavigationBackEnabled] == YES)
    {
        UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        [backButton setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"backButtonPressed"] forState:UIControlStateHighlighted|UIControlStateSelected];
        [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = leftBtnItem;
    }
    
    //title
    if([[self navigationBarTitle] length] > 0)
    {
        self.title = [self navigationBarTitle];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    
    if ([self showTableHeaderImage])
    {
        self.blackImage.hidden = NO;
    }
    else
    {
        self.blackImage.hidden = YES;
    }
   
    //背景色
    if([self needBlurBack] && ![self.base_blurView isDescendantOfView:self.view])
    {
        self.base_blurView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
        self.base_blurView.image = [UIImage imageNamed:@"NewTuneInBackImage"];
        [self.view addSubview:self.base_blurView];
        [self.view sendSubviewToBack:self.base_blurView];
    }
    
    [self.KVOController unobserveAll];
    [self KVO];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"[UI] =========================== page=%@", className);
}

-(void)KVO
{
    if ([self currentDeviceId].length == 0) {
        return;
    }

    LPDevice *device = [[LPDeviceManager sharedInstance] deviceForID:[self currentDeviceId]];
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:device.mediaInfo keyPaths:@[@"mediaType",@"title",@"artist",@"album",@"artwork"] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf mediaInfoChanged];
        });
    }];
    
    
    if ([self needKVOPlayStatus]) {
        [self.KVOController observe:device.deviceInfo keyPath:@"playStatus" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf mediaInfoChanged];
            });
        }];
    }
}

#pragma mark - HUD
-(void)showHud:(NSString *)text
{
    [self showHud:text type:MBProgressHUDModeIndeterminate];
}

-(void)hideHud:(NSString *)text
{
    [self hideHud:text type:MBProgressHUDModeText];
}

-(void)showHud:(NSString *)text type:(MBProgressHUDMode)mode
{
    if(![HUD isDescendantOfView:self.view]){
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    HUD.mode = mode;
    HUD.label.text = text;
}

- (void)hideHud:(NSString *)text afterDelay:(NSTimeInterval)delay type:(MBProgressHUDMode)mode
{
    if([HUD isDescendantOfView:self.view] && [text length] > 0){
        HUD.label.text = text;
    }
    HUD.mode =mode;
    [HUD hideAnimated:YES afterDelay:delay];
}

-(void)hideHud:(NSString *)text type:(MBProgressHUDMode)mode
{
    if([HUD isDescendantOfView:self.view] && [text length] > 0){
        HUD.label.text = text;
    }
    HUD.mode = mode;
    [HUD hideAnimated:YES afterDelay:1];
}

- (UIView *)addFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(BOOL)isNavigationBackEnabled
{
    return NO;
}

-(void)backButtonPressed
{
    if ([self.navigationController.viewControllers.firstObject isEqual:self])
    {//当前页面尚未被Push过
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    for (UIView *view in self.navigationController.view.superview.subviews){
        view.backgroundColor = [UIColor blackColor];
    }
}

-(NSString *)navigationBarTitle
{
    return @"";
}

-(BOOL)needBlurBack
{
    return NO;
}

-(BOOL)needBottomPlayView
{
    return YES;
}

-(void)refreshUI:(BOOL)playing
{
    
}

-(void)mediaInfoChanged
{
    
}

- (void)playViewDismiss
{
   
}

- (BOOL)needKVOPlayStatus
{
    return NO;
}

- (BOOL)showTableHeaderImage
{
    return NO;
}

- (NSString *)currentDeviceId
{
    return @"";
}

- (UIImageView *)getTableHeaderImageView:(NSString *)imageURL defaultImage:(UIImage *)defaultImage isPlayng:(BOOL)playing
{
    NSInteger height = [UIApplication sharedApplication].statusBarFrame.size.height + 270*([UIScreen mainScreen].bounds.size.width/375.0);
    self.blackImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,height)];
    self.blackImage.backgroundColor = [UIColor clearColor];

    UIImageView *albumImage = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - height + 40)/2.0, 20 , height - 40, height - 40)];
    albumImage.layer.masksToBounds = YES;
    albumImage.layer.cornerRadius = 4;
    albumImage.contentMode = UIViewContentModeScaleAspectFit;
    [albumImage sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:defaultImage];
    [self.blackImage addSubview:albumImage];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(10, height - 1, [UIScreen mainScreen].bounds.size.width - 20, 1)];
    blackView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [self.blackImage addSubview:blackView];
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, height - 55, 50, 50)];
    playBtn.userInteractionEnabled = YES;
    
    if (playing) {
        [playBtn setImage:[UIImage imageNamed:@"presetpauseBtn"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"presetpauseBtn_pressed"] forState:UIControlStateHighlighted];
        
    }else{
        [playBtn setImage:[UIImage imageNamed:@"presetplayBtn"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"presetplayBtn_pressed"] forState:UIControlStateHighlighted];
    }
    
    [playBtn addTarget:self action:@selector(controllerPlayBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.blackImage addSubview:playBtn];
    
    self.blackImage.userInteractionEnabled = YES;
    return self.blackImage;
}

- (void)controllerPlayBtn
{
    
}

- (NSString *)selectTrackId
{
    if (!_selectTrackId) {
        _selectTrackId = [[NSString alloc] init];
    }
    return _selectTrackId;
}

@end
