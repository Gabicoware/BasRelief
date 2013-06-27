/*
 *  RenderViewControllerDelegate.h
 *  BasRelief
 *
 *  Created by Daniel Mueller on 6/14/09.
 *  Copyright Gabicoware LLC 2013. All rights reserved.
 *
 */

@protocol RenderViewControllerDelegate <NSObject>

//@property (readonly) CGImageRef imageRef;

- (CGImageRef) getImageRef;

- (void) setRenderingImageRef: (CGImageRef) renderedImageRef;

- ( void ) viewControllerDidFinishViewing: ( UIViewController * ) viewer;
- ( void ) viewControllerDidFinishPreparing: ( UIViewController * ) viewer;

@end