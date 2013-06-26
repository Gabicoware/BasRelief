//
//  BasReliefRenderView.h
//  BasRelief
//
//  Created by Daniel Mueller on 1/23/09.
//  Copyright 2013 Gabicoware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "BasReliefRendering.h"
#import "RenderView.h"
/*
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.
 Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface TextureRenderView : RenderView {
    
@private
    
	
	/* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
    
	/* OpenGL name for the sprite texture */
	GLuint spriteTexture;
	GLfloat *spriteTexcoords;
	GLfloat *spriteVertices;
	
}


@end
