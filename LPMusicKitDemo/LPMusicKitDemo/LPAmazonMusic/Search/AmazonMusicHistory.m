//
//  AmazonMusicHistory.m
//  LPMDPKitDemo
//
//  Created by lyr on 2019/9/29.
//  Copyright © 2019年 Linkplay-jack. All rights reserved.
//

#import "AmazonMusicHistory.h"

@implementation AmazonMusicHistory

- (instancetype)init
{
    self = [super init];
    if (self){
    }
    return self;
}

- (NSMutableArray *)selectAllSearchHistory
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSMutableArray *localArray = [self readLoaclDict];
    for (int i = (int)localArray.count - 1; i < localArray.count; i -- )
    {
        [newArray addObject:localArray[i]];
    }
    return newArray;
}

- (BOOL)addSearchKeyword:(NSString *)keyword
{
    if (keyword.length == 0)
    {
        return YES;
    }
    
    NSMutableArray *localArray = [self readLoaclDict];
    [localArray removeObject:keyword];
    [localArray addObject:keyword];
    [self writeDictToLoacl:localArray];
    return YES;
}

- (BOOL)deleteSearchKeyword:(NSString *)keyword
{
    if (keyword.length == 0)
    {
        return YES;
    }
    NSMutableArray *localArray = [self readLoaclDict];
    [localArray removeObject:keyword];
    return YES;
}

- (BOOL)deleteAllSearchKeyword
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *plistPath = [self searchHistoryLocalPath];
    [fileManager removeItemAtPath:plistPath error:nil];
    return YES;
}

- (void)writeDictToLoacl:(NSMutableArray *)array
{
    NSString *plistPath = [self searchHistoryLocalPath];
    [array writeToFile:plistPath atomically:YES];
}

- (NSMutableArray *)readLoaclDict
{
    NSString *plistPath = [self searchHistoryLocalPath];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[NSMutableArray arrayWithContentsOfFile:plistPath]];
    return  array;
}

- (NSString *)searchHistoryLocalPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *local = [paths objectAtIndex:0];
    
    NSString *userId = [AmazonMusicBoxManager shared].account.userId;
    NSString *plistPath = [local stringByAppendingFormat:@"/AmazonMusicSearch%@",userId];
    return plistPath;
}

//转换成utf8
- (NSString *)utf8Str:(NSString *)str
{
    if (@available(iOS 9.0,*))
    {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else
    {
        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}


@end
