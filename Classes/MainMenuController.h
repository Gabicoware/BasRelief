//
//  MainMenuViewController.h
//  BasRelief
//
//  Created by Daniel Mueller on 1/17/09.
//  Copyright SaltyMule 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderViewController.h"
#import "BasReliefMaterial.h"

@interface MainMenuController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, RenderViewControllerDelegate>{

    BasReliefMaterial * material;
	
	RenderViewController *renderer;
	
	UIImagePickerController *picker;

	
	CGImageRef destinationImageRef;
	CGImageRef sourceImageRef;
	
	CGImageRef imageRef;
	
	IBOutlet UIImageView *imageView;
	
	IBOutlet UIButton *viewButton;
	//IBOutlet UIButton *viewFullButton;
	
	IBOutlet UIButton *saveImageButton;

	IBOutlet UIView *controlsView;

	IBOutlet UIView *loadingView;

	IBOutlet UISegmentedControl *segmentControl;

	
	BOOL didChangeImage;
	//Boolean needsPreviewRendering;
	BOOL needsRendering;
	
	CGImageRef formattedImageRef;
	
}

- (IBAction)getPhoto;

//- (IBAction)bitmapViewRelief;
//- (IBAction)viewPreview;

- (IBAction)viewRendering;

- (IBAction)saveImage;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;



@end
