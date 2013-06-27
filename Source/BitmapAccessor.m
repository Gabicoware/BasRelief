//
//  BitmapAccessor.m
//  BasReliefDevToolBox
//
//  Created by Daniel Mueller on 4/20/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import "BitmapAccessor.h"
#import <QuartzCore/QuartzCore.h>

#define PI 3.14159265358979323846



	static inline float radians(double degrees) { return degrees * PI / 180; }

	void RGBArrayFromImagePath( NSString *path, unsigned char *rgbArray , int width, int height){
				
		//NSString *imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
		//CGDataProviderRef provider = CGDataProviderCreateWithFilename([imageFileName UTF8String]);
		//CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		
		CGImageRef image  = CGImageFromPath( path );
		
		RGBArrayFromCGImage( image, rgbArray, width, height);
		
	}

	CGImageRef CGImageFromPath( NSString *path ){
		NSString *imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
		CGDataProviderRef provider = CGDataProviderCreateWithFilename([imageFileName UTF8String]);
		return CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
	}



	void RGBArrayFromCGImage( CGImageRef imageRef, unsigned char *rgbArray, int width, int height ){
		
		CGContextRef cgctx = CreateBitmapContext(width, height, RGB);
		if (cgctx == NULL) 
		{ 
			// error creating context
			return;
		}
		
		// Draw the image to the bitmap context. Once we draw, the memory 
		// allocated for the context for rendering will then contain the 
		// raw image data in the specified color space.
		CGContextDrawImage(cgctx, CGRectMake(0.0, 0.0, width, height), imageRef); 
		
		
		unsigned char *bytes = CGBitmapContextGetData (cgctx);
		if (bytes != NULL)
		{
			
			int j;
			
			//USED INSTEAD OF CASTING EVERY TIME
			int l = (int) width * height;
			
			//unsigned char c0, c1, c2, c3;
			
			for(j = 0; j < l; j++){
				
				rgbArray[j*4+0] = bytes[j*4+1];
				rgbArray[j*4+1] = bytes[j*4+2];
				rgbArray[j*4+2] = bytes[j*4+3];
				rgbArray[j*4+3] = 255;
				
				//c0 = rgbArray[j*4+0];
				//c1 = rgbArray[j*4+1];
				//c2 = rgbArray[j*4+2];
				//c3 = rgbArray[j*4+3];
				
				//c0 = c1;
				
			}
			
			free(bytes);
			
		}
		
		CGContextRelease(cgctx);
		
	}

	void HeightMapFromCGImage( CGImageRef image, unsigned char heightMap[], int width, int height, int shiftValue){
		
		CGContextRef cgctx = CreateBitmapContext(width, height, GRAYSCALE);
		if (cgctx == NULL) 
		{ 
			// error creating context
			return;
		}
		
		// Draw the image to the bitmap context. Once we draw, the memory 
		// allocated for the context for rendering will then contain the 
		// raw image data in the specified color space.
		CGContextDrawImage(cgctx, CGRectMake(0.0, 0.0, width, height), image);
		
		
		unsigned char *bytes = CGBitmapContextGetData (cgctx);
		if (bytes != NULL)
		{
			
			int j;
			
			//USED INSTEAD OF CASTING EVERY TIME
			int l = (int) width * height;
			
			for(j = 0; j < l; j++){
				
				heightMap[j] = bytes[j] >> shiftValue;
				
			}
			
			free(bytes);
			
		}
		
		CGContextRelease(cgctx);
		
		
	}
	

	CGContextRef CreateBitmapContextWithData ( size_t pixelsWide, size_t pixelsHigh , int colorSpaceID, void *bitmapData)
	{
		CGContextRef    context = NULL;
		CGColorSpaceRef colorSpace;
		int             bitmapByteCount;
		int             bitmapBytesPerRow;
		CGImageAlphaInfo alphaInfo;
		
		// Get image width, height. We'll use the entire image.
		//size_t pixelsWide = CGImageGetWidth(inImage);
		//size_t pixelsHigh = CGImageGetHeight(inImage);
		
		// Declare the number of bytes per row. Each pixel in the bitmap in this
		// example is represented by 4 bytes; 8 bits each of red, green, blue, and
		// alpha.
		
		// Use the generic RGB color space.
		switch (colorSpaceID) {
			case RGBX:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				bitmapBytesPerRow   = (pixelsWide * 4 );
				alphaInfo = kCGImageAlphaNoneSkipLast;
				break;
			case GRAYSCALE:
				colorSpace = CGColorSpaceCreateDeviceGray();
				bitmapBytesPerRow   = pixelsWide;
				alphaInfo = kCGImageAlphaNone;
				break;
			case RGB:
			default:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				bitmapBytesPerRow   = (pixelsWide * 4 );
				alphaInfo = kCGImageAlphaPremultipliedFirst;
				break;
		}
		
		bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
		
		if (colorSpace == NULL)
		{
			fprintf(stderr, "Error allocating color space\n");
			return NULL;
		}
				
		// Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
		// per component. Regardless of what the source image format is 
		// (CMYK, Grayscale, and so on) it will be converted over to the format
		// specified here by CGBitmapContextCreate.
		context = CGBitmapContextCreate( bitmapData,
										pixelsWide,
										pixelsHigh,
										8,      // bits per component
										bitmapBytesPerRow,
										colorSpace,
										alphaInfo);
		//kCGImageAlphaPremultipliedFirst);
		if (context == NULL)
		{
			fprintf (stderr, "Context not created!");
		}
		
		// Make sure and release colorspace before returning
		CGColorSpaceRelease( colorSpace );
		
		return context;
	}


	CGContextRef CreateBitmapContext ( size_t pixelsWide, size_t pixelsHigh , int colorSpaceID)
	{
		CGContextRef    context = NULL;
		CGColorSpaceRef colorSpace;
		void *          bitmapData;
		int             bitmapByteCount;
		int             bitmapBytesPerRow;
		CGImageAlphaInfo alphaInfo;
		
		// Get image width, height. We'll use the entire image.
		//size_t pixelsWide = CGImageGetWidth(inImage);
		//size_t pixelsHigh = CGImageGetHeight(inImage);
		
		// Declare the number of bytes per row. Each pixel in the bitmap in this
		// example is represented by 4 bytes; 8 bits each of red, green, blue, and
		// alpha.
		
		// Use the generic RGB color space.
		switch (colorSpaceID) {
			case RGBX:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				bitmapBytesPerRow   = (pixelsWide * 4 );
				alphaInfo = kCGImageAlphaNoneSkipLast;
				break;
			case GRAYSCALE:
				colorSpace = CGColorSpaceCreateDeviceGray();
				bitmapBytesPerRow   = pixelsWide;
				alphaInfo = kCGImageAlphaNone;
				break;
			case RGB:
			default:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				bitmapBytesPerRow   = (pixelsWide * 4 );
				alphaInfo = kCGImageAlphaPremultipliedFirst;
				break;
		}
		
		bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
		
		if (colorSpace == NULL)
		{
			fprintf(stderr, "Error allocating color space\n");
			return NULL;
		}
		
		// Allocate memory for image data. This is the destination in memory
		// where any drawing to the bitmap context will be rendered.
		bitmapData = malloc( bitmapByteCount );
		if (bitmapData == NULL) 
		{
			fprintf (stderr, "Memory not allocated!");
			CGColorSpaceRelease( colorSpace );
			return NULL;
		}
		
		// Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
		// per component. Regardless of what the source image format is 
		// (CMYK, Grayscale, and so on) it will be converted over to the format
		// specified here by CGBitmapContextCreate.
		context = CGBitmapContextCreate( bitmapData,
										 pixelsWide,
										 pixelsHigh,
										 8,      // bits per component
										 bitmapBytesPerRow,
										 colorSpace,
										 alphaInfo);
		//kCGImageAlphaPremultipliedFirst);
		if (context == NULL)
		{
			free (bitmapData);
			fprintf (stderr, "Context not created!");
		}
		
		// Make sure and release colorspace before returning
		CGColorSpaceRelease( colorSpace );
		
		return context;
	}
	
	CGImageRef CGImageCreateForBasRefliefFormat(CGImageRef imageRef, CGRect targetRect)
	{
		size_t sourceWidth = CGImageGetWidth(imageRef);
		size_t sourceHeight = CGImageGetHeight(imageRef);
		
		CGContextRef bitmap;
		
        CGImageRef rotatedImageRef = NULL;
        
		if((sourceWidth > sourceHeight && targetRect.size.width < targetRect.size.height)  || (sourceWidth < sourceHeight && targetRect.size.width > targetRect.size.height)){
			
			//Rotation
			
			bitmap = CreateBitmapContext(	sourceHeight, sourceWidth, GRAYSCALE	);
			
			CGContextRotateCTM (bitmap, radians(-90));
			
			CGContextDrawImage(bitmap, CGRectMake(( -1.0 * sourceWidth ) , 0.0, sourceWidth, sourceHeight ), imageRef);
						
			rotatedImageRef = CGBitmapContextCreateImage(bitmap);
			
			CGContextRelease(bitmap);
			
			sourceWidth = CGImageGetWidth(rotatedImageRef);
			sourceHeight = CGImageGetHeight(rotatedImageRef);
			
		}
		
		CGRect crop = CGRectMake(0.0, 0.0, sourceWidth, sourceHeight);
		
		if(sourceWidth / sourceHeight > targetRect.size.width / targetRect.size.height ){
			crop.size.width = ( sourceHeight / targetRect.size.height ) * targetRect.size.width ;
			crop.origin.x = ( sourceWidth - crop.size.width )/2;
			
		}else{
			crop.size.height = ( sourceWidth / targetRect.size.width ) * targetRect.size.height ;
			crop.origin.y = ( sourceHeight - crop.size.height )/2;
		}
		
		//NSLog(@"%i, %f, %i, %f, %f, %f",sourceWidth,crop.size.width,sourceHeight,crop.size.height, crop.origin.x, crop.origin.y );
        
		CGImageRef croppedImageRef = CGImageCreateWithImageInRect( rotatedImageRef == NULL ? imageRef : rotatedImageRef, crop );
		
        if(rotatedImageRef != NULL){
            CGImageRelease(rotatedImageRef);
        }
		
		// Build a bitmap context that's the size of the thumbRect
		bitmap = CreateBitmapContext(	targetRect.size.width,	targetRect.size.height, GRAYSCALE);
		
		// Draw into the context, this scales the image
		CGContextDrawImage(bitmap, targetRect, croppedImageRef);
		
		CGImageRelease(croppedImageRef);
		
		CGImageRef result = CGBitmapContextCreateImage(bitmap);
		
		return result;
		
	}
	
