//
//  RenderViewController.m
//  BasRelief
//
//  Created by Daniel Mueller on 6/15/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import "BitmapAccessor.h"
#import "RenderViewController.h"
#import "LightSource.h"

#import "OpenGLRenderView.h"

#define kAccelerometerFrequency		100.0 // Hz
#define kFilteringFactor			0.1

#define kMaxTapDuration				0.4
#define kMinAccelerometerTimeout	0.4



@interface RenderViewController()

-(void)update;
-(void)renderWithTouch:(UITouch *)touch;


-(void)renderOnThreadWithSelector:(SEL)sel;

//RENDER WITH ONE OF THESE THREE ITEMS
-(void)renderBasReliefBase:(void *)n;
-(void)renderBasReliefFull:(void *)n;
-(void)renderBasReliefPreview:(void *)n;

//AND CALL BACK ON COMPLETION ONE OF THE FOLLOWING
-(void)baseRenderingIsComplete:(void *)n;
-(void)cleanThread:(void *)n;



@property (nonatomic, retain) NSThread *renderThread;

@end

@implementation RenderViewController


+(Class)viewClass{
	return [OpenGLRenderView class];
}



@synthesize delegate, material, renderThread, isUsingTouch;

/*
- (void)loadView{
	
	
	RenderView * rView = [[[RenderViewController viewClass] alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	[rView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[rView setBackgroundColor:[UIColor blackColor]];
	self.view = rView;
	
	[rView release];
	
}
*/

- (void)viewWillAppear:(BOOL)animated{
	[renderView layoutSubviews];
	//WE EXAMINE 20 times per second
	[self setAnimationInterval:1.0/20.0];
	
}
- (void)viewDidAppear:(BOOL)animated{	
	[self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self stopAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)prepareRendering {
	if(!renderView){
		[self loadView];
        self.wantsFullScreenLayout = YES;
	}
	
	
	
	//NOTE THE FULL RENDERING SHOULD NOT HAVE A FRAME RATE
	
	self.view.contentMode = UIViewContentModeTop;
	
	
	[self renderOnThreadWithSelector:@selector(renderBasReliefBase:)];

}

-(void)renderBasReliefBase:(void *)n{
	
	CGImageRef imageRef = [delegate getImageRef];


	if(previewRendering != NULL){
		[previewRendering dealloc];
	}
	
	previewRendering = [[BasReliefRendering alloc] initWithHeight:PREVIEW_HEIGHT width:PREVIEW_WIDTH];
	
	//TO DO Investigate if using the shift value is the best way to go or not.
	previewRendering.heightShiftValue = PREVIEW_SHIFT;
	
	[previewRendering useCGImage:imageRef material:material];
	
	[previewRendering renderBase];	
	
	if(fullRendering != NULL){
		[fullRendering dealloc];
	}
	
	fullRendering = [[BasReliefRendering alloc] initWithHeight:FULL_HEIGHT width:FULL_WIDTH];
	
	fullRendering.heightShiftValue = FULL_SHIFT;
	
	[fullRendering useCGImage:imageRef material:material];
	
	[fullRendering renderBase];	
	
	[self performSelectorOnMainThread:@selector(baseRenderingIsComplete:) withObject:nil waitUntilDone:NO];
	
}

-(void)baseRenderingIsComplete:(void *)n{
	
	[self cleanThread:nil];
	
	[renderView setRendering:previewRendering];
	
	[delegate viewControllerDidFinishPreparing:self];
	
	[self showRendering];
	
}

-(void)renderBasReliefFull:(void *)n{
	
	SetLightSourceDidUpdate();
	
	[fullRendering render];
	
	[self performSelectorOnMainThread:@selector(cleanThread:) withObject:nil waitUntilDone:NO];
	
}


-(void)renderBasReliefPreview:(void *)n{
	
	[previewRendering render];
	
	[self performSelectorOnMainThread:@selector(cleanThread:) withObject:nil waitUntilDone:NO];
	
}


-(void)cleanThread:(void *)n{
	
	[renderThread cancel];
    
	while (renderThread && ![renderThread isFinished]) { // Wait for the thread to finish.
        [NSThread sleepForTimeInterval:0.1];
    }
	
	renderThread = nil;
	
}


-(void)showRendering{
	
	SetLightSource(0.0f, 0.0f, 1.0f);
	
	isInitial = YES;
	needsFullRendering = YES;
	isPreviewing = YES;
	[renderView setRendering:previewRendering];
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	
	if(isUsingTouch){
		if(isPreviewing == NO){
			[renderView setRendering:previewRendering];
		}	
		isPreviewing = YES;

		[self renderWithTouch:[touches anyObject]];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	
	if(isUsingTouch){
		if(isPreviewing){
			
			[self renderWithTouch:[touches anyObject]];
			
			isPreviewing = NO;
			
		}else{
			returnToMainMenuRequested = YES;
		}
		
		[renderView setRendering:fullRendering];
	}else{
		returnToMainMenuRequested = YES;
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	if(!isUsingTouch){
		accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
		accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
		accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);	
		
		SetLightSource(accel[0], accel[1], accel[2]);
		
		if(GetLightSourceDidUpdate()){
			
			SetLightSourceDidUpdate();
			
			isPreviewing = YES;
			
			interactionStartTime = [NSDate timeIntervalSinceReferenceDate];
		}
	}
}


- (void)renderWithTouch:(UITouch *)touch {
	
	needsFullRendering  = YES;
	
	CGSize viewSize;
	CGPoint currentPosition;	
	CGFloat xScalar, yScalar, zScalar, radius, length;
	
	currentPosition = [touch locationInView:self.view];
	
	viewSize = [self.view bounds].size;
	
	currentPosition = [touch locationInView:self.view];
	
	radius= 160.0f; //(viewBounds.size.width)/2.0;
	
	xScalar = (currentPosition.x - 160.0f)/radius;
	yScalar = (currentPosition.y - 240.0f)/radius;
	zScalar = 0.0;
	length = sqrtf( xScalar*xScalar + yScalar*yScalar );
	
	if(length == 0.0f){
		zScalar = 1.0f;
	}else if(length < 1.0f ){
		zScalar = sqrtf(1.0f-length*length);
	}
	//WE DON"T NORMALIZE, THAT IS TAKEN CARE OF BY THE FOLLOWING FUNCTION
	SetLightSource((float)xScalar, (float)yScalar, (float)zScalar);
	
	
}

- (void)dealloc {
	
	[previewRendering dealloc];
	
	[fullRendering dealloc];
	
	[super dealloc];
}

-(void)update{
	
	if(isPreviewing){
		
		if(!isInitial && renderView.positionerAlpha < 1.0){
			renderView.positionerAlpha = renderView.positionerAlpha + 0.02 ;
			if(renderView.positionerAlpha >= 1.0){
				renderView.positionerAlpha = 1.0;
			}
		}
		
		if(!previewRendering.isRendering){
			
			
			if(previewRendering.isNew){
				previewRendering.isNew = NO;
				if(renderView.positionerAlpha == 0.0){
					[renderView drawRendering];
					[renderView presentImage];
					
				}
				if(isInitial){
					isPreviewing = NO;
					isInitial = NO;
					[renderView setRendering:fullRendering];
					
				}
				
			}else if(GetLightSourceDidUpdate()){
				
				SetLightSourceDidUpdate();
				
				NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(renderBasReliefPreview:) object:nil];
				self.renderThread = thread;
				[thread release];
			
				[renderThread start];
			}else if( !isUsingTouch && [NSDate timeIntervalSinceReferenceDate] - interactionStartTime > kMinAccelerometerTimeout){
				
				isPreviewing = NO;
				[renderView setRendering:fullRendering];
				
			}
			//then do something
		}
	
	}else{
		
		if( renderView.positionerAlpha > 0.0){
			renderView.positionerAlpha = renderView.positionerAlpha - 0.1 ;
			
			if(renderView.positionerAlpha  <= 0.0){
				
				renderView.positionerAlpha = 0.0;
				
			}
			
		}
		
		if(!fullRendering.isRendering){
			
			if(fullRendering.isNew){
				needsFullRendering = NO;
				fullRendering.isNew = NO;
				renderView.positionerAlpha = 0.0;
				[renderView drawRendering];
				[renderView presentImage];
			}else if(needsFullRendering && self.renderThread == nil){
				
				[self renderOnThreadWithSelector:@selector(renderBasReliefFull:)];
				
			}else if(returnToMainMenuRequested){
				
				returnToMainMenuRequested = NO;
				
				CGImageRef imageRef;
				
				imageRef = [RenderViewController imageRefFromRendering:fullRendering];
				
				[delegate setRenderingImageRef: imageRef ];
				
				[self stopAnimation];
				
				[delegate viewControllerDidFinishViewing:self];
				
			
			}
			//then do something
		}
		
	}
	
	if(renderView.positionerAlpha > 0.0){
		[renderView drawRendering];
		[renderView drawPositionerAtX:GetLightSourceX() Y:GetLightSourceY()];
		[renderView presentImage];
	}
	
	
}

-(void)renderOnThreadWithSelector:(SEL)sel{
	
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:sel object:nil];
	self.renderThread = thread;
	[thread release];
	
	[renderThread start];
	
}

+(CGImageRef)imageRefFromRendering:(BasReliefRendering *)rendering{
	
	CGContextRef ctx;
	CGImageRef imageRef;
	
	ctx = CreateBitmapContextWithData ( rendering.width, rendering.height , RGBX, rendering.renderedImageArray);
	
	imageRef = CGBitmapContextCreateImage(ctx);
	
	CGContextRelease(ctx);	
	
	return imageRef;
}






@synthesize animationInterval;

- (void)startAnimation
{
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(update) userInfo:nil repeats:YES];
}


- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval = interval;
	
	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}







@end
