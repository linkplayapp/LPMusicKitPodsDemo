//
//  LPTuneInSearchHistory.m
//  iMuzo
//
//  Created by lyr on 2021/2/26.
//  Copyright © 2021 wiimu. All rights reserved.
//

#import "LPTuneInSearchHistory.h"

@implementation LPTuneInSearchHistory

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
    [self writeDictToLoacl:localArray];
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
    
    NSString *plistPath = [local stringByAppendingFormat:@"/LPTuneInMusicSearch"];
    return plistPath;
}

//转换成utf8
- (NSString *)utf8Str:(NSString *)str
{
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}


@end
