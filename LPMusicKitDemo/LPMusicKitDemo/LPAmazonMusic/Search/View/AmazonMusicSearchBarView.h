//
//  AmazonMusicSearchBarView
//  iMuzo
//
//  Created by lyr on 2019/4/26.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AmazonMusicSearchBarViewDelegate <NSObject>

- (void)amazonMusicSearchBarView:(NSInteger)statu Text:(NSString *)text;

@end


@interface AmazonMusicSearchBarView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UIButton *deleateBut;

@property (nonatomic, assign) id<AmazonMusicSearchBarViewDelegate> delegate;

- (void)endEnditing;

@end

NS_ASSUME_NONNULL_END
