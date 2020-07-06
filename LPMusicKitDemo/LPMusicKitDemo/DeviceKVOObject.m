//
//  DeviceKVOObject.m
//  muzoplayer
//
//  Created by 许一宁 on 2019/8/6.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "DeviceKVOObject.h"
#import "NSObject+FBKVOController.h"

@interface DeviceKVOObject()



@end

@implementation DeviceKVOObject

- (DeviceKVOObject *)initWithLPDevice:(LPDevice *)boxInfo{
    self.boxInfo = boxInfo;
    [self KVO];
    return self;
}

- (void)reKVO {
    [self.KVOController unobserveAll];
    [self KVO];
}

- (void)removeKVO {
    [self.KVOController unobserveAll];
}

- (void)KVO{
    __weak typeof(self) weakSelf = self;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;

    // Song title
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"title" options:options block:^(id observer, id object, NSDictionary *change) {
        NSString * title = weakSelf.boxInfo.mediaInfo.title;
        [weakSelf updateLPDeviceInfo:@"title" value:title];
    }];
    
    // Song artist
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"artist" options:options block:^(id observer, id object, NSDictionary *change) {
        NSString * artist = weakSelf.boxInfo.mediaInfo.artist;
        [weakSelf updateLPDeviceInfo:@"artist" value:artist];
    }];
    
    // Song mediaType
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"mediaType" options:options block:^(id observer, id object, NSDictionary *change) {
        // Filtering
        if ([self checkStringNeedUpdate:change]) {
            NSString * mediaType = weakSelf.boxInfo.mediaInfo.mediaType;
            [weakSelf updateLPDeviceInfo:@"mediaType" value:mediaType];
        }
    }];
    
    // Song album image
    [self.KVOController observe:self.boxInfo.mediaInfo keyPath:@"artworkUri" options:options block:^(id observer, id object, NSDictionary *change) {
        NSString * artworkUri = weakSelf.boxInfo.mediaInfo.artworkUri;
        artworkUri = [artworkUri isEqualToString:@"un_known"] ? @"" :artworkUri;
        [weakSelf updateLPDeviceInfo:@"artworkUri" value:artworkUri];
    }];
    
    // Volume
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"volume" options:options block:^(id observer, id object, NSDictionary *change) {
        int volume = (int)weakSelf.boxInfo.deviceStatus.volume;
        [weakSelf updateLPDeviceInfo:@"volume" numValue:volume];
    }];
    
    // Channel
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"currentChannel" options:options block:^(id observer, id object, NSDictionary *change) {
        int currentChannel = (int)weakSelf.boxInfo.deviceStatus.currentChannel;
        [weakSelf updateLPDeviceInfo:@"currentChannel" numValue:currentChannel];
    }];
    
    // The current playing time of the song
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"relativeTime" options:options block:^(id observer, id object, NSDictionary *change) {
        NSTimeInterval currentChannel = weakSelf.boxInfo.deviceStatus.relativeTime;
        [weakSelf updateLPDeviceInfo:@"relativeTime" numValue:currentChannel];
    }];
    
    // Total song time
    [self.KVOController observe:self.boxInfo.deviceStatus keyPath:@"trackDuration" options:options block:^(id observer, id object, NSDictionary *change) {
        NSTimeInterval currentChannel = weakSelf.boxInfo.deviceStatus.trackDuration;
        [weakSelf updateLPDeviceInfo:@"trackDuration" numValue:currentChannel];
    }];
    
    // Playing state
    [self.KVOController observe:self.boxInfo.deviceInfo keyPath:@"playStatus" options:options block:^(id observer, id object, NSDictionary *change) {
        // Filtering
        if ([self checkValueNeedUpdate:change]) {
            LPPlayStatus playStatus = weakSelf.boxInfo.deviceInfo.playStatus;
            [weakSelf updateLPDeviceInfo:@"playStatus" numValue:(int)playStatus];
        }
    }];
}


// Compare string new/old
- (BOOL)checkStringNeedUpdate:(NSDictionary *)change{
    NSArray * keys = change.allKeys;
    if (![keys containsObject:@"old"]) {
        return YES;
    }
    
    if (![change[@"new"] isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    if (![change[@"old"] isKindOfClass:[NSString class]]) {
        //if new is string，old is not string， has changed
        return YES;
    }
    NSString * new = change[@"new"];
    NSString * old = change[@"old"];
    if (new && old && ![new isEqualToString:old]){
        return YES;
    }
    return NO;
}

// Compare int new/old
- (BOOL)checkValueNeedUpdate:(NSDictionary *)change{
    NSArray * keys = change.allKeys;
    if (![keys containsObject:@"old"]) {
        return YES;
    }
    
    int new = [change[@"new"] intValue];
    int old = [change[@"old"] intValue];
    if (new != old){
        return YES;
    }
    return NO;
}

- (void)updateLPDeviceInfo:(NSString *)key value:(NSString *)value{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeviceInfoByKey" object:nil userInfo:@{@"UUID":self.boxInfo.deviceStatus.UUID,@"key":key,@"value": value ? value : @""}];
}

- (void)updateLPDeviceInfo:(NSString *)key numValue:(int)numValue{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeviceInfoByKey" object:nil userInfo:@{@"UUID":self.boxInfo.deviceStatus.UUID,@"key":key,@"value": [NSNumber numberWithInt:numValue]}];
}

- (void)dealloc
{
    NSLog(@"[DeviceKVOObject] dealloc");
}

@end
