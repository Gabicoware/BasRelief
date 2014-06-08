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

@interface MainMenuViewController()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, RenderViewControllerDelegate,UIActionSheetDelegate>

- (void) initializeRenderer;

- (IBAction)viewRendering;

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end


@implementation MainMenuViewController{
    
    BasReliefMaterial * material;
	
	RenderViewController *renderer;
	
	UIImagePickerController *picker;
    
	
	CGImageRef destinationImageRef;
	
	CGImageRef imageRef;
	
	IBOutlet UIImageView *imageView;
	
	IBOutlet UIBarButtonItem *photoButton;
	IBOutlet UIBarButtonItem *reliefButton;
	IBOutlet UIBarButtonItem *shareButton;
    
	IBOutlet UIToolbar *toolbar;
    
	IBOutlet UIView *loadingView;
	
	BOOL didChangeImage;
	
    BOOL needsRendering;
	
	CGImageRef formattedImageRef;
	
}

+(Class)rendererClass{
	return [RenderViewController class];
}

- (CGImageRef) copyImageRef{
	
	return CGImageCreateCopy( formattedImageRef );
	
}

- (void)viewDidLoad{
	[super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	loadingView.hidden = YES;
	toolbar.hidden = NO;
	
	picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	//picker.allowsImageEditing = NO;
	[self initializeRenderer];
	//viewFullButton.enabled = NO;	
	
}

#define PhotoActionSheetTag 1001
#define CameraTitle @"Take Photo"
#define LibraryTitle @"Choose Existing Photo"
#define CancelTitle @"Cancel"

- (IBAction)didTapPhotoButton {
    NSString* buttonTitle1 = nil;
    NSString* buttonTitle2 = nil;
    //@"Take Photo"
    //@"Choose Existing Photo"
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            buttonTitle1 = CameraTitle;
            buttonTitle2 = LibraryTitle;
        }else{
            buttonTitle1 = LibraryTitle;
        }
    }else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        buttonTitle1 = CameraTitle;
    }
    
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CancelTitle destructiveButtonTitle:nil otherButtonTitles:buttonTitle1,buttonTitle2, nil];
    sheet.tag = PhotoActionSheetTag;
    [sheet showFromBarButtonItem:photoButton animated:YES];
}

-(void)photoActionSheetDidDismissWithButtonTitle:(NSString*)buttonTitle{
    if ([buttonTitle isEqualToString:CameraTitle]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }else if ([buttonTitle isEqualToString:LibraryTitle]) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{}];
    }
}

#define TiltTitle @"Tilt"
#define TouchTitle @"Touch"
#define ReliefActionSheetTag 1002

-(IBAction)didTapReliefButton:(id)sender{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CancelTitle destructiveButtonTitle:nil otherButtonTitles:TiltTitle,TouchTitle, nil];
    sheet.tag = ReliefActionSheetTag;
    [sheet showFromBarButtonItem:photoButton animated:YES];
}

-(void)reliefActionSheetDidDismissWithButtonTitle:(NSString*)buttonTitle{
    if ([buttonTitle isEqualToString:TiltTitle]) {
        [self viewRendering:NO];
    }else if ([buttonTitle isEqualToString:TouchTitle]) {
        [self viewRendering:YES];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (actionSheet.tag == PhotoActionSheetTag) {
        [self photoActionSheetDidDismissWithButtonTitle:buttonTitle];
    }else if (actionSheet.tag == ReliefActionSheetTag) {
        [self reliefActionSheetDidDismissWithButtonTitle:buttonTitle];
    }
    
}

- ( void ) viewControllerDidFinishPreparing: ( UIViewController * ) viewer{
    [self presentViewController:viewer animated:NO completion:^{}];
	
}


- (void)viewRendering:(BOOL)isUsingTouch {
	
	[self initializeRenderer];
	
	loadingView.hidden = NO;
	toolbar.hidden = YES;
	renderer.isUsingTouch = isUsingTouch;
	
	if(needsRendering){
		[renderer prepareRendering];
		needsRendering = NO;
	}else{
		[self presentViewController:renderer animated:NO completion:^{}];
	}
	
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
	
	shareButton.enabled = YES;
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
	
	shareButton.enabled = NO;
	
	//viewPreviewButton.enabled = NO;
	//viewFullButton.enabled = NO;

	needsRendering = YES;
	[self dismissModalViewControllerAnimated:YES];
	
	if(formattedImageRef != NULL)
		CGImageRelease(formattedImageRef);
	
	formattedImageRef = CGImageForBasRefliefFormat([image CGImage], CGRectMake(0.0, 0.0, FULL_WIDTH, FULL_HEIGHT));
    
    CGImageRetain(formattedImageRef);
    
	imageView.image = [UIImage imageWithCGImage:formattedImageRef];
	
	reliefButton.enabled = YES;
	   
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
	renderer = NULL;
	formattedImageRef = NULL;
	destinationImageRef = NULL;
}

- (IBAction)didTapShareButton{
    
    NSString *textToShare = @"#basrelief";
    NSArray *itemsToShare = @[textToShare, imageView.image];
    
    UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
    
}

@end
