//
//  BasReliefRendering.m
//  BasRelief
//
//  Created by Daniel Mueller on 6/27/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import "BasReliefRendering.h"
#import "brgeom.h"
#import "BitmapAccessor.h"
#import "LightSource.h"


@interface BasReliefRendering()
	
	-(void)setLightSourceX:(float)lightX Y:(float)lightY Z:(float)lightZ;
	
@end

@implementation BasReliefRendering

@synthesize isRendering, isNew;
@synthesize width, height, heightShiftValue;
@synthesize baseImageArray;
@synthesize renderedImageArray;
@synthesize indices;
@synthesize vertices;
@synthesize heightMap;
@synthesize normals;

-(Boolean)needsUpdate{
	
	if(forceUpdate){
		forceUpdate = FALSE;
		return TRUE;
	}
	
	if(locked){
		return FALSE;
	}
	
	
	if(GetLightSourceDidUpdate()){
		return TRUE;
	}
	
	return FALSE;
	
	
}

-(void)setFixedLightSourceX:(float)lightX Y:(float)lightY Z:(float)lightZ{
	forceUpdate = TRUE;
	locked = TRUE;
	[self setLightSourceX:lightX Y:lightY Z:lightZ];
	
}

-(void)setFreeLightSourceX:(float)lightX Y:(float)lightY Z:(float)lightZ{
	forceUpdate = TRUE;
	locked = FALSE;	
	[self setLightSourceX:lightX Y:lightY Z:lightZ];
}

-(void)setLightSourceX:(float)lightX Y:(float)lightY Z:(float)lightZ{
	light[0] = lightX;
	light[1] = lightY;
	light[2] = lightZ;
	
}

-(id)initWithHeight:(int)h width:(int)w{
	if(self = [super init]){
		baseImageArray = (GLubyte *)malloc(sizeof(GLubyte)*h*w*4);
		renderedImageArray = (GLubyte *)malloc(sizeof(GLubyte)*h*w*4);
		indices = (GLushort *)malloc(sizeof(GLushort)*w*2);
		vertices = (GLfixed *)malloc(sizeof(GLfixed)*h*w*2);
		
		heightMap = (unsigned char *)malloc(sizeof(char)*h*w);
		normals = (float *)malloc(sizeof(float)*h*w*3);
		width = w;
		height = h;
		
		light = (float *)malloc(sizeof(float)*3);
		
		light[0] = 0.0;
		light[1] = 0.0;
		light[2] = 1.0;
		
		locked = FALSE;
		forceUpdate = FALSE;
		
		isRendering = FALSE;
		isNew = FALSE;
		
	}
	return self;
}

-(void)useCGImage:(CGImageRef)imageRef material:(BasReliefMaterial *)mat{
	
	material = mat;
	sourceImageRef = imageRef;
	CGImageRetain(sourceImageRef);
}

-(void)renderBase{
	forceUpdate = TRUE;

	RGBArrayFromImagePath( material.materialBundlePath, baseImageArray , width, height);
	
	GenerateIndices( width,  indices);
	
	GenerateVertices( width, height, vertices);
	
	HeightMapFromCGImage(sourceImageRef, heightMap, width, height, heightShiftValue);
		
	CalculateNormals( heightMap, normals, width, height );
	
	SetRenderingValues(material.base);
	
	SetHeightMap(heightMap);
	
	SetNormals(normals);
	
	RenderBase( width, height, baseImageArray);
	
}

-(void)setAsCurrent{
	
	SetHeightMap(heightMap);
	
	SetNormals(normals);
	
	SetMaxHeight(255>>heightShiftValue);

	SetRenderingValues(material.shadow);

}

-(void)render{
	

	//It's copied from the LightSource.m to here
	if(!locked){
		[self setLightSourceX:GetLightSourceX() Y:GetLightSourceY() Z:GetLightSourceZ()];
	}
	
	self.isRendering = TRUE;
	
	SetLightVector( light[0], light[1], light[2]);
	
	RenderDeterminate( width, height, baseImageArray, renderedImageArray);
	
	self.isRendering = FALSE;
	
	isNew = TRUE;

	
}

-(void)copyLightToRendering:(BasReliefRendering *) rendering{
	[rendering setFixedLightSourceX:light[0] Y:light[1] Z:light[2]];
}


-(void)dealloc{
	
	//Do not dealloc the material
	
	CGImageRelease(sourceImageRef);

	
	free(baseImageArray);
	free(renderedImageArray);
	free(indices);
	free(vertices);
	free(heightMap);
	free(normals);
	
	[super dealloc];
	
}


@end
