//
//  RenderView.h
//  BasRelief
//
//  Created by Daniel Mueller on 8/23/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasReliefRendering.h"

@interface RenderView : UIView {

	BasReliefRendering *currentRendering;
	
	float positionerAlpha;
	
}

@property (readwrite) float positionerAlpha;

- (void)drawRendering;

- (void)setRendering:(BasReliefRendering *)rendering;

- (void)drawPositionerAtX:(float)x Y:(float)y;

- (void)presentImage;

@end
