//
//  BitmapAccessor.h
//  BasReliefDevToolBox
//
//  Created by Daniel Mueller on 4/20/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define FULL_HEIGHT 480.0
#define FULL_WIDTH 320.0
#define FULL_SHIFT 1

#define PREVIEW_HEIGHT 120.0
#define PREVIEW_WIDTH 80.0
#define PREVIEW_SHIFT 3

#define GRAYSCALE 0
#define RGB 1
#define RGBX 2

//float RENDERING_HEIGHT = 240.0;
//float RENDERING_WIDTH = 160.0;

void RGBArrayFromImagePath( NSString *path, unsigned char *rgbArray , int width, int height);

//ASSUMES CGImageRef is in the dimensions for the resulting array
void RGBArrayFromCGImage( CGImageRef image, unsigned char *rgbArray , int width, int height);

//ASSUMES CGImageRef is in the dimensions for the resulting array
void HeightMapFromCGImage( CGImageRef image, unsigned char heightMap[], int width, int height, int shiftValue);

CGContextRef CreateBitmapContext ( size_t pixelsWide, size_t pixelsHigh, int colorSpaceID);

CGContextRef CreateBitmapContextWithData ( size_t pixelsWide, size_t pixelsHigh , int colorSpaceID, void *bitmapData);

CGImageRef CGImageCreateForBasRefliefFormat(CGImageRef imageRef, CGRect targetRect);

CGImageRef CGImageFromPath( NSString *path );
