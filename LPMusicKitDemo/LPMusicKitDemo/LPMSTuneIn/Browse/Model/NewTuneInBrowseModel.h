//
//  NewTuneInBrowseModel.h
//  iMuzo
//
//  Created by lyr on 2019/4/25.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewTuneInBrowseModel : NSObject

@property (nonatomic, strong) NSString *GuideId;
@property (nonatomic, strong) NSString *Index;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSString *ContainerType;
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, strong) NSDictionary *Presentation;
@property (nonatomic, strong) NSDictionary *Actions;
@property (nonatomic, strong) NSDictionary *Behaviors;
@property (nonatomic, strong) NSDictionary *Context;

@property (nonatomic, strong) NSString *Image;
@property (nonatomic, strong) NSString *Subtitle;
@property (nonatomic, strong) NSString *Description;

@property (nonatomic, strong) NSDictionary *Pivots;
@property (nonatomic, strong) NSDictionary *Properties;

//新增字段
@property (nonatomic, strong) NSMutableDictionary *cellHeightDict;

//是否打开更多
@property (nonatomic, assign) BOOL openMore;

@end

NS_ASSUME_NONNULL_END
