//
//  LPTuneInSearchHistory.h
//  iMuzo
//
//  Created by lyr on 2021/2/26.
//  Copyright © 2021 wiimu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPTuneInSearchHistory : NSObject

- (NSMutableArray *)selectAllSearchHistory;

- (BOOL)addSearchKeyword:(NSString *)keyword;

- (BOOL)deleteSearchKeyword:(NSString *)keyword;

- (BOOL)deleteAllSearchKeyword;


@end

NS_ASSUME_NONNULL_END
