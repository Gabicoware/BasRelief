//
//  BasReliefRenderView.m
//  BasRelief
//
//  Created by Daniel Mueller on 1/23/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <math.h>

#import "TextureRenderView.h"
//This view has no knowledge of the brgeom or BitmapAccessor libraries
//Revision from this view essentially being a super class that did everything


#define USE_DEPTH_BUFFER 0

@interface TextureRenderView (TextureRenderViewPrivate)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@interface TextureRenderView (TextureRenderViewSprite)

- (void)setupView;

@end

@implementation TextureRenderView

//@synthesize animationInterval;

// You must implement this
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder])) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
			[self release];
			return nil;
		}
				
		[self setupView];
	}
	
	return self;
}


- (void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
}


- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}


- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (void)setupView
{
	//CGImageRef spriteImage;
	//CGContextRef spriteContext;
	GLubyte *spriteData;
	size_t	width, height;
	

	// Sets up an array of values to use as the sprite vertices.
	spriteVertices = malloc(sizeof(GLfloat)*8);
	memset(spriteVertices, 0, sizeof(GLfloat)*8);
	spriteVertices[2] = 2.0f;
	spriteVertices[6] = 2.0f;
	spriteVertices[5] = 3.0f;
	spriteVertices[7] = 3.0f;
		
	// Sets up matrices and transforms for OpenGL ES
	glViewport(0, 0, backingWidth, backingHeight);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0.0f, 2.0f, 3.0f, 0.0f, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	
	// Clears the view with black
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	spriteTexcoords = malloc(sizeof(GLfloat)*8);
	memset(spriteTexcoords, 0, sizeof(GLfloat)*8);
	// Sets up pointers and enables states needed for using vertex arrays and textures
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, spriteTexcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Get the width and height of the image
	width = 512; //CGImageGetWidth(spriteImage);
	height = 512; //CGImageGetHeight(spriteImage);
	// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
	// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
	
	// Allocated memory needed for the bitmap context
	spriteData = (GLubyte *) malloc(width * height * 4);
		
	memset((void *) spriteData, 255, width*height*4);
	
	spriteTexcoords[2] = 1.0;
	spriteTexcoords[6] = 1.0;
	spriteTexcoords[5] = 1.0;
	spriteTexcoords[7] = 1.0;
	
	// Use OpenGL ES to generate a name for the texture.
	glGenTextures(1, &spriteTexture);
	// Bind the texture name. 
	glBindTexture(GL_TEXTURE_2D, spriteTexture);
	// Speidfy a 2D texture image, provideing the a pointer to the image data in memory
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
	// Release the image data
	free(spriteData);
	
	// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	// Enable use of the texture
	glEnable(GL_TEXTURE_2D);
	
	//We need speed more than the blending, so turn it off
	// Set a blending function to use
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	//sglEnable(GL_BLEND);
	
}

- (void)setRendering:(BasReliefRendering *)rendering{
	
	[super setRendering:rendering];
	
	spriteTexcoords[2] = (rendering.width*1.0)/512.0;
	spriteTexcoords[6] = (rendering.width*1.0)/512.0;
	
	spriteTexcoords[5] = (rendering.height*1.0)/512.0;
	spriteTexcoords[7] = (rendering.height*1.0)/512.0;	
	
	glTexCoordPointer(2, GL_FLOAT, 0, spriteTexcoords);

}


// Updates the OpenGL view when the timer fires
- (void)drawRendering
{
	
	
	[currentRendering render];
	
	
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, currentRendering.width, currentRendering.height, GL_RGBA, GL_UNSIGNED_BYTE, currentRendering.renderedImageArray);
	
	
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	glClear(GL_COLOR_BUFFER_BIT);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


// Stop animating and release resources when they are no longer needed.
- (void)dealloc
{	
	if([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end

