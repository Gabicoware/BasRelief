//
//  BasReliefMaterial.h
//  BasRelief
//
//  Created by Daniel Mueller on 8/10/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "brgeom.h"

@interface BasReliefMaterial : NSObject {
	
	RenderingValues base;
	
	RenderingValues shadow;
	
	NSString * materialBundlePath;
}

@property RenderingValues base;
@property RenderingValues shadow;
@property (strong) NSString * materialBundlePath;

@end
