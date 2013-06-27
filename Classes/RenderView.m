//
//  RenderView.m
//  BasRelief
//
//  Created by Daniel Mueller on 8/23/09.
//  Copyright 2009 Gabico Software. All rights reserved.
//

#import "RenderView.h"

@implementation RenderView

@synthesize positionerAlpha;   


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
		
		self.positionerAlpha = 0.0;
		
    }
    return self;
}

- (id)initWithFrame:(CGRect)aRect{

	if ((self = [super initWithFrame:aRect])) {
		
		self.positionerAlpha = 0.0;
		
    }
    return self;
	
	
}

- (void)setRendering:(BasReliefRendering *)rendering{
	
    currentRendering = rendering;
	
}

- (void)drawRendering{
	//SUBCLASS SPECIFIC CODE
}

- (void)drawPositionerAtX:(float)x Y:(float)y{
	//subclass specific code here
}

- (void)presentImage{
	
}

@end
