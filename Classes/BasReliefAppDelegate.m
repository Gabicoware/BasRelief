//
//  BasReliefAppDelegate.m
//  BasRelief
//
//  Created by Daniel Mueller on 1/17/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import "BasReliefAppDelegate.h"
#import "MainMenuViewController.h"
#import "LightSource.h"

@implementation BasReliefAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenuViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}





@end
