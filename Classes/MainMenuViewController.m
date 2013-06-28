//
//  BasReliefViewController.m
//  BasRelief
//
//  Created by Daniel Mueller on 1/17/09.
//  Copyright Gabicoware LLC 2013. All rights reserved.
//

#import "MainMenuViewController.h"
#import "RenderViewController.h"

#import "BitmapAccessor.h"

@interface MainMenuViewController()

- (void) initializeRenderer;

- (IBAction)viewRendering;

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@property (atomic) IBOutlet UIButton *tiltButton;
@property (atomic) IBOutlet UIButton *touchButton;

@end


@implementation MainMenuViewController

+(Class)rendererClass{
	return [RenderViewController class];
}

- (CGImageRef) copyImageRef{
	
	return CGImageCreateCopy( formattedImageRef );
	
}

- (void)viewDidLoad{
	
    self.wantsFullScreenLayout = YES;
    
    self.touchButton.selected = YES;
    self.tiltButton.selected = NO;
	
}

- (void)viewWillAppear:(BOOL)animated{
	loadingView.hidden = YES;
	controlsView.hidden = NO;
	
	picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	//picker.allowsImageEditing = NO;
	[self initializeRenderer];
	//viewFullButton.enabled = NO;	
	
}

-(IBAction)didTapTouchButton{
    self.touchButton.selected = YES;
    self.tiltButton.selected = NO;
}

-(IBAction)didTapTiltButton{
    self.touchButton.selected = NO;
    self.tiltButton.selected = YES;
}



- (IBAction)didTapPhotoButton {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentViewController:picker animated:YES completion:^{}];
	}
}

- (IBAction)didTapCameraButton {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentViewController:picker animated:YES completion:^{}];
	}
}

- ( void ) viewControllerDidFinishPreparing: ( UIViewController * ) viewer{
    [self presentViewController:viewer animated:NO completion:^{}];
	
}


- (IBAction)viewRendering {
	
	[self initializeRenderer];
	
	loadingView.hidden = NO;
	controlsView.hidden = YES;
	
	renderer.isUsingTouch = self.touchButton.selected;
	
	if(needsRendering){
		[renderer prepareRendering];
		needsRendering = NO;
	}else{
		[self presentViewController:renderer animated:NO completion:^{}];
	}
	//[self presentModalViewController:renderer animated:NO];
	
}

- (void) initializeRenderer{
	if(renderer == NULL){
		RenderingValues base = {0.7, 96, 0.7, 32};
		RenderingValues shadow = {0.7, 96, 0.7, 32};

		renderer = [[[MainMenuViewController rendererClass] alloc] init];
		material = [[BasReliefMaterial alloc] init];
		
		material.materialBundlePath = @"sandstone.png";
		material.base = base;
		material.shadow = shadow;

		renderer.material = material;
		
		renderer.delegate = self;
	}
	
}

- (void) setRenderingImageRef: (CGImageRef) renderedImageRef{

	if(destinationImageRef != NULL)
		CGImageRelease(destinationImageRef);
	
	destinationImageRef = renderedImageRef;
	
	CGImageRetain (destinationImageRef);
	
	imageView.image = [UIImage imageWithCGImage:destinationImageRef];
	
	saveImageButton.enabled = YES;
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
	
	saveImageButton.enabled = NO;
	
	//viewPreviewButton.enabled = NO;
	//viewFullButton.enabled = NO;

	needsRendering = YES;
	[self dismissModalViewControllerAnimated:YES];
	
	if(formattedImageRef != NULL)
		CGImageRelease(formattedImageRef);
	
	formattedImageRef = CGImageForBasRefliefFormat([image CGImage], CGRectMake(0.0, 0.0, FULL_WIDTH, FULL_HEIGHT));
    
    CGImageRetain(formattedImageRef);
    
	imageView.image = [UIImage imageWithCGImage:formattedImageRef];
	
	viewButton.enabled = YES;
	//viewFullButton.enabled = YES;
	//viewFullButton.enabled = NO;
	
    
}


- ( void ) viewControllerDidFinishViewing: ( UIViewController * ) viewer{
	//viewFullButton.enabled = YES;
    [self dismissViewControllerAnimated:NO completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:NULL];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	if(formattedImageRef != NULL)
		CGImageRelease(formattedImageRef);
	if(destinationImageRef != NULL)
		CGImageRelease(destinationImageRef);
	[renderer dealloc];
	renderer = NULL;
	formattedImageRef = NULL;
	destinationImageRef = NULL;
    [super dealloc];
}

- (IBAction)didTapShareButton{
    
    NSString *textToShare = @"#basrelief";
    NSArray *itemsToShare = @[textToShare, imageView.image];
    
    UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
    
    [controller autorelease];
}
    /*
	UIImage *img = imageView.image;
	
	// Request to save the image to camera roll
	UIImageWriteToSavedPhotosAlbum(img, self, 
								   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
		// Show error message...
		
    }
    else  // No errors
    {
		// Show message image successfully saved
    }
}
*/
@end
