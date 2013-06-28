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

@interface RenderViewController : UIViewController

@property (atomic) BOOL isUsingTouch;

@property (nonatomic) NSTimeInterval animationInterval;

+(Class)viewClass;

- (void)startAnimation;
- (void)stopAnimation;

-(void)prepareRendering;

@property (strong) id <NSObject, RenderViewControllerDelegate> delegate;
@property (strong) BasReliefMaterial * material;

@end
