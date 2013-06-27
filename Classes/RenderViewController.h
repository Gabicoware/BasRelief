//
//  RenderViewController.h
//  BasRelief
//
//  Created by Daniel Mueller on 6/15/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderViewControllerDelegate.h"
#import "BitmapAccessor.h"
#import "BasReliefMaterial.h"
#import "BasReliefRendering.h"
#import "RenderView.h"

@interface RenderViewController : UIViewController <UIAccelerometerDelegate>{
	id <NSObject, RenderViewControllerDelegate > delegate;
	BasReliefMaterial *material;
	
	BasReliefRendering *previewRendering;
	BasReliefRendering *fullRendering;
	
	//This needs to be set from a sub class
	IBOutlet RenderView *renderView;
	
	BOOL isPreviewing;
		
	double	accel[3];
	
	BOOL isUsingTouch;
	
	NSTimeInterval touchStartTime;
	NSTimeInterval interactionStartTime;
	
	
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	
	BOOL returnToMainMenuRequested;
	BOOL isInitial;
	BOOL needsFullRendering;
	
	
	
}

@property (atomic) BOOL isUsingTouch;

@property (nonatomic) NSTimeInterval animationInterval;

+(Class)viewClass;

- (void)startAnimation;
- (void)stopAnimation;

-(void)prepareRendering;

-(void)showRendering;

//-(void)preparePreviewRendering;
//-(void)prepareFullRendering;

//-(void)showPreviewRendering;
//-(void)showFullRendering;


@property (retain) id <NSObject, RenderViewControllerDelegate> delegate;
@property (retain) BasReliefMaterial * material;

+(CGImageRef)imageRefFromRendering:(BasReliefRendering *)rendering;

@end
