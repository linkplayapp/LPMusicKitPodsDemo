//
//  AmazonMusicHistory.h
//  LPMDPKitDemo
//
//  Created by lyr on 2019/9/29.
//  Copyright © 2019年 Linkplay-jack. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Search History
 */
@interface AmazonMusicHistory : NSObject

- (NSMutableArray *)selectAllSearchHistory;

- (BOOL)addSearchKeyword:(NSString *)keyword;

- (BOOL)deleteSearchKeyword:(NSString *)keyword;

- (BOOL)deleteAllSearchKeyword;

@end

NS_ASSUME_NONNULL_END
