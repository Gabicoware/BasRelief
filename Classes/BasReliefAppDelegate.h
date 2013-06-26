//
//  BasReliefAppDelegate.h
//  BasRelief
//
//  Created by Daniel Mueller on 1/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainMenuController.h"

@class MainMenuController;

@interface BasReliefAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*window;
    MainMenuController		*viewController;
	UIAccelerationValue			accel[3];
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainMenuController *viewController;

@end

