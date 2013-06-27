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

@interface RenderViewController : UIViewController <UIAccelerometerDelegate>

@property (atomic) BOOL isUsingTouch;

@property (nonatomic) NSTimeInterval animationInterval;

+(Class)viewClass;

- (void)startAnimation;
- (void)stopAnimation;

-(void)prepareRendering;

@property (retain) id <NSObject, RenderViewControllerDelegate> delegate;
@property (retain) BasReliefMaterial * material;

@end
