//
//  BasReliefAppDelegate.h
//  BasRelief
//
//  Created by Daniel Mueller on 1/17/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainMenuViewController.h"

@class MainMenuViewController;

@interface BasReliefAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*window;
    MainMenuViewController		*viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MainMenuViewController *viewController;

@end

