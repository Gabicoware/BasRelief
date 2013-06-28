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

@interface MainMenuViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, RenderViewControllerDelegate>{

    BasReliefMaterial * material;
	
	RenderViewController *renderer;
	
	UIImagePickerController *picker;

	
	CGImageRef destinationImageRef;
	
	CGImageRef imageRef;
	
	IBOutlet UIImageView *imageView;
	
	IBOutlet UIButton *viewButton;
	//IBOutlet UIButton *viewFullButton;
	
	IBOutlet UIButton *saveImageButton;

	IBOutlet UIView *controlsView;

	IBOutlet UIView *loadingView;
	
	BOOL didChangeImage;
	//Boolean needsPreviewRendering;
	BOOL needsRendering;
	
	CGImageRef formattedImageRef;
	
}




@end
