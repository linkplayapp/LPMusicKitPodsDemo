//
//  BasicViewController.h
//  LPMDPKitDemo
//
//  Created by 程龙 on 2020/2/24.
//  Copyright © 2020 Linkplay-jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface BasicViewController : UIViewController

@property (retain) MBProgressHUD * HUD;

@property (nonatomic, strong) NSString *selectTrackId;

-(void)showHud:(NSString *)text;
-(void)hideHud:(NSString *)text;
-(void)showHud:(NSString *)text type:(MBProgressHUDMode)mode;
-(void)hideHud:(NSString *)text type:(MBProgressHUDMode)mode;
- (void)hideHud:(NSString *)text afterDelay:(NSTimeInterval)delay type:(MBProgressHUDMode)mode;

- (UIView *)addFooterView;

-(void)refreshUI:(BOOL)playing;
-(void)mediaInfoChanged;//当播放信息发生改变，会自动调用此方法
-(void)playViewDismiss;

- (UIImageView *)getTableHeaderImageView:(NSString *)imageURL defaultImage:(UIImage *)defaultImage isPlayng:(BOOL)playing;
- (void)startToChangePlayButtonImageImmediately;
- (void)pageButtonPressed;
- (void)controllerPlayBtn;
- (void)presetMusicList;


@end

NS_ASSUME_NONNULL_END
