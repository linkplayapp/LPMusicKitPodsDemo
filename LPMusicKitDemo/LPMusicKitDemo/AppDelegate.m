//
//  AppDelegate.m
//  LPMusicKitDemo
//
//  Created by sunyu on 2020/6/18.
//  Copyright © 2020 sunyu. All rights reserved.
//

#import "AppDelegate.h"
#import "LPDeviceListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (@available(iOS 13,*)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        return YES;
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        LPDeviceListViewController * controller = [[LPDeviceListViewController alloc] init];
        UINavigationController *rootNavgationController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.window.rootViewController = rootNavgationController;
        [self.window makeKeyAndVisible];
        return YES;
    }
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
