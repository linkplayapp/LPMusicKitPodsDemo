//
//  NewTuneInMusicDetailController.h
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "BasicViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewTuneInMusicDetailController : BasicViewController

@property (nonatomic, strong) NSString *guideId;
@property (nonatomic, strong) NSString *url;

//section标题
@property (nonatomic, strong) NSString *queueName;

@end

NS_ASSUME_NONNULL_END
