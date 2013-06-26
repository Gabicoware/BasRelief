//
//  BasReliefAppDelegate.m
//  BasRelief
//
//  Created by Daniel Mueller on 1/17/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BasReliefAppDelegate.h"
#import "MainMenuController.h"
#import "LightSource.h"

#define kAccelerometerFrequency		100.0 // Hz
#define kFilteringFactor			0.1

@implementation BasReliefAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	
	// Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}



@end
