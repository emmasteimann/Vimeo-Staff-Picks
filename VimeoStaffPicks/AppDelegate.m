//
//  AppDelegate.m
//  VimeoStaffPicks
//
//  Created by Johnny Blockingcall on 6/26/15.
//  Copyright (c) 2015 Vimeo. All rights reserved.
//

#import "AppDelegate.h"
#import "ImageCache.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ImageCache sharedInstance];
    return YES;
}

@end
