//
//  BasReliefRenderView.h
//  BasRelief
//
//  Created by Daniel Mueller on 1/23/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "BasReliefRendering.h"
#import "RenderView.h"

/*
 This is a concrete OpenGL implementation of the renderView abstract class.
 Originally there were several different implementations, including bitmap 
 and OpenGL texture rendering, however this seems to give us the bes performance.
 
 */
@interface OpenGLRenderView : RenderView {
        
	/* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
    	
}

@end

