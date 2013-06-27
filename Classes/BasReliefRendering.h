//
//  BasReliefRendering.h
//  BasRelief
//
//  Created by Daniel Mueller on 6/27/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import "BasReliefMaterial.h"
@interface BasReliefRendering : NSObject {
	
	int width;
	int height;
	GLubyte *baseImageArray;
	GLubyte *renderedImageArray;
	GLushort *indices;
	GLfixed *vertices;
	unsigned char *heightMap;
	float *normals;
	int heightShiftValue;
	
	float *light;
	
	BasReliefMaterial * material;
	CGImageRef sourceImageRef;
	
	Boolean locked;
	Boolean forceUpdate;
	
	Boolean isRendering;
	Boolean isNew;
}

@property (readwrite) Boolean isNew;
@property (readwrite) Boolean isRendering;
@property (readwrite) int heightShiftValue;
@property (readwrite) int width;
@property (readwrite) int height;
@property (readwrite) GLubyte *baseImageArray;
@property (readwrite) GLubyte *renderedImageArray;
@property (readwrite) GLushort *indices;
@property (readwrite) GLfixed *vertices;
@property (readwrite) unsigned char *heightMap;
@property (readwrite) float *normals;


-(id)initWithHeight:(int)h width:(int)w;


//TO DO CREATE BAS RELIEF MATERIAL. THIS WILL DO FOR NOW.
-(void)useCGImage:(CGImageRef)imageRef material:(BasReliefMaterial *)mat;
-(void)renderBase;

-(void)render;
//NOTE THIS SETS THE LIGHT SOURCE AS FIXED. 
-(void)copyLightToRendering:(BasReliefRendering *) rendering;

-(Boolean)needsUpdate;

-(void)setAsCurrent;


@end
