//
//  BasReliefBitmapRenderView.h
//  BasRelief
//
//  Created by Daniel Mueller on 6/13/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderView.h"

@interface BitmapRenderView : RenderView {
    CGContextRef cgctx;
}

@end
