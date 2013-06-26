//
//  BasReliefBitmapRenderViewController.m
//  BasRelief
//
//  Created by Daniel Mueller on 6/13/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import "BitmapRenderViewController.h"

@implementation BitmapRenderViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
/*
- (id)init
{
    if ((self = [super init])) {
				
		cgctx = CreateBitmapContext(RENDERING_WIDTH, RENDERING_HEIGHT, RGB);
        
		baseImageArray = (unsigned char *)malloc(sizeof(unsigned char)*RENDERING_HEIGHT*RENDERING_WIDTH*4);
		renderedImageArray = CGBitmapContextGetData (cgctx);
		
		heightMap = (unsigned char *)malloc(sizeof(char)*RENDERING_HEIGHT*RENDERING_WIDTH);
		normals = (float *)malloc(sizeof(float)*RENDERING_HEIGHT*RENDERING_WIDTH*3);
		
		float animInterv = 1.0 / 2.0;
		
        
		
		#if TARGET_IPHONE_SIMULATOR
			animInterv = 1.0 / 10.0;
		#endif
		
		animationInterval = animInterv;

    }
    return self;
}


- (void)loadView {
	//Create the BitmapContext
	renderView = [[BitmapRenderView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	self.view = renderView;
		
}


- (void)viewDidAppear:(BOOL)animated{
	
	CGImageRef imageRef;
	imageRef = delegate.imageRef;
	
	float fps= [delegate frameRate];
	
	animationInterval = 1.0/fps;
	
	//CGContextDrawImage(cgctx, CGRectMake(0.0, RENDERING_HEIGHT, RENDERING_WIDTH, RENDERING_HEIGHT), imageRef);
	
	//[renderView setCGContext:cgctx];
	
	[self renderBasReliefFromCGImageRef:imageRef material:@"sandstone.png"];
	
	[self startAnimation];
}



- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
	free((void *)baseImageArray);
	free((void *)heightMap);
	free((void *)normals);
	
	CGContextRelease(cgctx);
	
	 [self stopAnimation];
	
    [super dealloc];
}




- (void)renderBasReliefFromCGImageRef:(CGImageRef)imageRef material:(NSString *) materialImagePath{
			
	
	//RGBArrayFromImagePath( materialImagePath, baseImageArray );
		
	//HeightMapFromCGImage(imageRef, heightMap);
	
	CalculateNormals( heightMap, normals, RENDERING_WIDTH, RENDERING_HEIGHT );
	
	SetRenderingValues(0.7, 96, 0.7, 32);
	
	
	
	SetLightSource( 0.0, 0.0, 1.0);
	
	SetHeightMap(heightMap);
	
	SetNormals(normals);
	
	RenderDeterminate( RENDERING_WIDTH, RENDERING_HEIGHT, baseImageArray, baseImageArray);
	
	reliefIsRendered = TRUE;
	
}



- (void)drawView {
    
	if(!reliefIsRendered)
		return;
		
#if TARGET_IPHONE_SIMULATOR
	currentLightSourceAngle = currentLightSourceAngle + M_PI/180;
	
	SetLightSource(1.0*(float) cos(currentLightSourceAngle), (float) sin(currentLightSourceAngle), 2.0);
#endif
	
	RenderDeterminate( RENDERING_WIDTH, RENDERING_HEIGHT, baseImageArray, renderedImageArray);
	
	[renderView setCGImageRef:CGBitmapContextCreateImage(cgctx)];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	//#if TARGET_IPHONE_SIMULATOR
	[self stopAnimation];
	//#endif
	[delegate viewControllerDidFinishViewing:self];
	
}

*/

@end
