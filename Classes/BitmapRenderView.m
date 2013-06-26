//
//  BasReliefBitmapRenderView.m
//  BasRelief
//
//  Created by Daniel Mueller on 6/13/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import "BitmapRenderView.h"
#import "BitmapAccessor.h"

@interface BitmapRenderView ()
@end

@implementation BitmapRenderView

- (void)setRendering:(BasReliefRendering *)rendering{
	
	[super setRendering:rendering];
	
	cgctx = CreateBitmapContextWithData(rendering.width, rendering.height, RGBX, rendering.renderedImageArray);
	
}
	
-(void)drawRendering{
	
	
	if(![currentRendering needsUpdate])
		return;
	
	[currentRendering render];
	
	[self setNeedsDisplay];
	
}


- (void)drawRect:(CGRect)rect{
	
	CGImageRef imageRef = CGBitmapContextCreateImage(cgctx);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, [self frame], imageRef);

}

- (void)didReceiveMemoryWarning {
	//[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	
	CGContextRelease(cgctx);
	
	
    [super dealloc];
}


@end
