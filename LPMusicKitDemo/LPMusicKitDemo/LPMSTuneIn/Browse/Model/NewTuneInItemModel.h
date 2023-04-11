//
//  NewTuneInItemModel.h
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewTuneInItemModel : NSObject

@property (nonatomic, strong) NSString *GuideId;
@property (nonatomic, strong) NSString *Index;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSString *ContainerType;
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSDictionary *Pivots;

@property (nonatomic, strong) NSDictionary *ContainerNavigation;
@property (nonatomic, strong) NSDictionary *Presentation;

@end

NS_ASSUME_NONNULL_END
