//
//  BasReliefRenderView.m
//  BasRelief
//
//  Created by Daniel Mueller on 1/23/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <math.h>

#import "OpenGLRenderView.h"
//The renderview is no longer in charge of ANYTHING regarding rendering, it simply outputs the image

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface OpenGLRenderView ()

@property (nonatomic, retain) EAGLContext *context;

-(BOOL) createFramebuffer;
-(void) destroyFramebuffer;

@end

@implementation OpenGLRenderView

@synthesize context;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setRendering:(BasReliefRendering *)rendering{
	
	[super setRendering:rendering];
		
	glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
	
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	
	
	//THIS IS PROBABLY NOT THE APPROPRIATE PLACE FOR THIS, BUT FOR NOW IT WILL DO
	[EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
   
	
}



//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		
    }
    return self;
}


- (id)initWithFrame:(CGRect)aRect{
	
	if ((self = [super initWithFrame:aRect])) {
		
		// Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
    }
    return self;
	
	
}



- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
    [self createFramebuffer];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)dealloc {
	
	if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

- (void)drawPositionerAtX:(float)x Y:(float)y{
	//subclass specific code here


	 const GLfloat squareVertices[] = {
	 -0.02f, 0.8f,
	 0.02f,  0.8f,
	 -0.02f,  0.9f,
	 0.02f,   0.9f,
	 -0.010f, 0.82f,
	 0.010f,  0.82f,
	 -0.010f,  0.88f,
	 0.010f,   0.88f,
	 };
	 
	 [EAGLContext setCurrentContext:context];
	 
	 glMatrixMode(GL_PROJECTION);
	 glLoadIdentity();
	 glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, 0.0f, 1.0f);
	 glMatrixMode(GL_MODELVIEW);
	 
	 glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	 
	 float angleInc = 30.0f;
	 int steps = (int) 360.0f/angleInc;
	 
	 glEnable(GL_BLEND);
	 
	 glBlendFunc(GL_ZERO, GL_ZERO);
	 
	 for(int i = 0; i < steps; i++){
	 
		 glColor4f(0.0f, 0.0f, 0.0f, positionerAlpha);
		 
		 glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		 
		 glColor4f(0.4f, 0.4f, 0.4f, positionerAlpha);
		 
		 glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
		 
		 glRotatef( angleInc, 0.0f, 0.0f, 1.0f);
	 
	 }
	 glDisable(GL_BLEND);
	 

}

- (void)presentImage{
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];

}

- (void)drawRendering {
	
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
    glOrthox(0, (GLfixed) currentRendering.width - 1, (GLfixed) currentRendering.height - 1, 0 , -1, 0);
    
	glClear(GL_COLOR_BUFFER_BIT);
	    
	int i;
	for(i=0; i < currentRendering.height-1; i++){
		glVertexPointer(2, GL_FIXED, 0, &currentRendering.vertices[2*currentRendering.width*i]);
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, &currentRendering.renderedImageArray[4*currentRendering.width*i]);
		glDrawElements(GL_TRIANGLE_STRIP, (	GLsizei )2*currentRendering.width, GL_UNSIGNED_SHORT, currentRendering.indices);
	}
	
}

@end

