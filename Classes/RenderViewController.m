//
//  RenderViewController.m
//  BasRelief
//
//  Created by Daniel Mueller on 6/15/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import "BitmapAccessor.h"
#import "RenderViewController.h"
#import "LightSource.h"

#import "OpenGLRenderView.h"

#define kAccelerometerFrequency		100.0 // Hz
#define kFilteringFactor			0.1

#define kMaxTapDuration				0.4
#define kMinAccelerometerTimeout	0.4

//States:
//Initial - Data is not available yet
//Interactive - Preview is being updated continuously
//RenderingFull - Latest Preview is used until Full Rendering is available
//Rendered - Full Rendering is available and shown

typedef enum _RenderingState{
    RenderingStateInitial,
    RenderingStateInteractive,
    RenderingStateRenderingFull,
    RenderingStateRendered,
} RenderingState;

@interface RenderViewController()

+(CGImageRef)imageRefFromRendering:(BasReliefRendering *)rendering;


-(void)update;
-(void)updateLightSourceWithTouch:(UITouch *)touch;


//RENDER WITH ONE OF THESE THREE ITEMS
-(void)renderBasReliefBase:(void *)n;
-(void)renderBasReliefFull:(void *)n;
-(void)renderBasReliefPreview:(void *)n;

@end

@implementation RenderViewController{
    dispatch_queue_t renderingQueue;
    dispatch_queue_t stateLockQueue;

	id <NSObject, RenderViewControllerDelegate > delegate;
	BasReliefMaterial *material;
	
	BasReliefRendering *previewRendering;
	BasReliefRendering *fullRendering;
	
	//This needs to be set from a sub class
	IBOutlet RenderView *renderView;
	
    
	double	accel[3];
	
	BOOL isUsingTouch;
	
	NSTimeInterval touchStartTime;
	NSTimeInterval interactionStartTime;
	
	
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	
	BOOL returnToMainMenuRequested;
    
	BOOL hasInteracted;
    
    RenderingState _renderingState;
}


+(Class)viewClass{
	return [OpenGLRenderView class];
}

@synthesize delegate, material, isUsingTouch;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])){
        stateLockQueue = dispatch_queue_create("com.gabicoware.basrelief.StateLock", DISPATCH_QUEUE_SERIAL);
        renderingQueue = dispatch_queue_create("com.gabicoware.basrelief.Rendering", DISPATCH_QUEUE_SERIAL);
    }
    return self;

}

-(void)setRenderingState:(RenderingState)renderingState{
	
    dispatch_sync(stateLockQueue, ^{
        
        if (renderingState != _renderingState) {
            switch (renderingState) {
                case RenderingStateInitial:
                    break;
                case RenderingStateInteractive:
                    [renderView setRendering:previewRendering];
                    dispatch_async(renderingQueue, ^{
                        [self renderBasReliefPreview:NULL];
                    });
                    break;
                case RenderingStateRenderingFull:
                    [renderView setRendering:previewRendering];
                    
                    dispatch_async(renderingQueue, ^{
                        [self renderBasReliefFull:NULL];
                    });
                    
                    break;
                case RenderingStateRendered:
                    [renderView setRendering:fullRendering];
                    break;
            }
        }
        
        _renderingState = renderingState;
    });

}

-(RenderingState)renderingState{
    __block RenderingState renderingState;
    
    dispatch_sync(stateLockQueue, ^{
        renderingState = _renderingState;
    });
    
    return renderingState;

}

- (void)viewWillAppear:(BOOL)animated{
    [renderView setNeedsLayout];
	//WE EXAMINE 20 times per second
	[self setAnimationInterval:1.0/20.0];
	[self update];
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
    self.wantsFullScreenLayout = YES;
    
    [self view];
    
    self.view.contentMode = UIViewContentModeTop;
    
    hasInteracted = NO;
    
    [self setRenderingState:RenderingStateInitial];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self renderBasReliefBase:NULL];
    });
	
}

-(void)renderBasReliefBase:(void *)n{
	
	CGImageRef imageRef = [delegate copyImageRef];
    
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
    
    CGImageRelease(imageRef);
    
	SetLightSource(0.0f, 0.0f, 1.0f);
    
    [renderView setRendering:previewRendering];
    //the first render happens as part of the initial setup
    [previewRendering setAsCurrent];
	[previewRendering render];
    
    //we do all this inline, instead of using the setter
    dispatch_sync(stateLockQueue, ^{
        
        _renderingState = RenderingStateInteractive;
        
    });
    
	[(id)delegate performSelectorOnMainThread:@selector(viewControllerDidFinishPreparing:) withObject:self waitUntilDone:NO];
    
}

-(void)renderBasReliefFull:(void *)n{
	
	SetLightSourceDidUpdate();
	
    [fullRendering setAsCurrent];
	[fullRendering render];
    
    switch ([self renderingState]) {
        case RenderingStateRenderingFull:
            [self setRenderingState:RenderingStateRendered];
            break;
        case RenderingStateRendered:
            NSLog(@"Potential rendering inconsistency, already in Rendered state.");
            break;
            
        default:
            break;
    }

}


-(void)renderBasReliefPreview:(void *)n{
	
    [previewRendering setAsCurrent];
	[previewRendering render];
    
    if (!hasInteracted) {
        [self setRenderingState:RenderingStateRenderingFull];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
	
	if(isUsingTouch){
        
		[self updateLightSourceWithTouch:[touches anyObject]];
        [self setRenderingState:RenderingStateInteractive];
        
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	
	if(isUsingTouch){
        
        //this may lead to a disconnect in the user experience
        //However, it should be a relatively decent piece of training that
        //you can only return to the main menu when the full rendering is complete
        if ([self renderingState] == RenderingStateRendered) {
			returnToMainMenuRequested = YES;
        }else{
			[self updateLightSourceWithTouch:[touches anyObject]];
            [self setRenderingState:RenderingStateRenderingFull];
        }
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
			
            hasInteracted = YES;
			SetLightSourceDidUpdate();
			
            [self setRenderingState:RenderingStateInteractive];
            
			interactionStartTime = [NSDate timeIntervalSinceReferenceDate];
		}
	}
}


- (void)updateLightSourceWithTouch:(UITouch *)touch {
    
    hasInteracted = YES;
    
	CGPoint currentPosition = [touch locationInView:self.view];
			
	CGFloat xScalar, yScalar, zScalar, radius, length;
	radius= (self.view.bounds.size.width)/2.0;
	
	xScalar = (currentPosition.x - (self.view.bounds.size.width)/2.0)/radius;
	yScalar = (currentPosition.y - (self.view.bounds.size.height)/2.0)/radius;
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
	
    dispatch_release(renderingQueue);
        
    dispatch_release(stateLockQueue);
	
	[super dealloc];
}

-(void)update{
	
    RenderingState renderingState = [self renderingState];
        
    switch(renderingState){
        case RenderingStateInitial:
            //do nothing
            break;
        case RenderingStateInteractive:
        {
            if(renderView.positionerAlpha < 1.0){
                renderView.positionerAlpha = renderView.positionerAlpha + 0.1 ;
                if(renderView.positionerAlpha >= 1.0){
                    renderView.positionerAlpha = 1.0;
                }
            }
            
            if(!previewRendering.isRendering){
                
                
                if(GetLightSourceDidUpdate()){
                    
                    SetLightSourceDidUpdate();
                    
                    dispatch_async(renderingQueue, ^{
                        [self renderBasReliefPreview:NULL];
                    });
                    
                }else if( !isUsingTouch && [NSDate timeIntervalSinceReferenceDate] - interactionStartTime > kMinAccelerometerTimeout){
                    
                    [self setRenderingState:RenderingStateRenderingFull];
                    
                }
                //then do something
            }
            
            [renderView drawRendering];
            [renderView drawPositionerAtX:GetLightSourceX() Y:GetLightSourceY()];
            [renderView presentImage];

        }
            break;
        case RenderingStateRenderingFull:
            //do nothing
            break;
        case RenderingStateRendered:
            if(!fullRendering.isRendering){
                
                if(fullRendering.isNew){
                    fullRendering.isNew = NO;
                    renderView.positionerAlpha = 0.0;
                    [renderView drawRendering];
                    [renderView presentImage];
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
            break;
    }
    
    
	if(renderingState != RenderingStateInteractive){
		
		if( renderView.positionerAlpha > 0.0){
			renderView.positionerAlpha = renderView.positionerAlpha - 0.1 ;
			
			if(renderView.positionerAlpha  <= 0.0){
				
				renderView.positionerAlpha = 0.0;
				
			}
			
		}
	}
	
}

+(CGImageRef)imageRefFromRendering:(BasReliefRendering *)rendering{
	
	CGContextRef ctx;
	CGImageRef imageRef;
	
	ctx = CreateBitmapContextWithData ( rendering.width, rendering.height , RGBX, rendering.renderedImageArray);
	
	imageRef = CGBitmapContextCreateImage(ctx);
	
	CGContextRelease(ctx);	
	
	return (CGImageRef)[(id)imageRef autorelease];
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
