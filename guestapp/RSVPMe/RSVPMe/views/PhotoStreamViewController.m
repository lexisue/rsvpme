//
//  PhotoStreamViewController.m
//  RSVPMe
//
//  Created by Alex Sue on 2/14/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PhotoStreamViewController.h"
#import "MenuViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+ResizeAdditions.h"
#import <Parse/Parse.h>

@implementation PhotoStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup the menu
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // add the refresh controller
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView addSubview:refreshControl];
}

- (IBAction)showMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)handleRefresh:(id)sender {
    
}

- (void)loadImages {
    
}

- (IBAction)addPhoto:(id)sender {
    // make it so don't show if type is camera and camera not available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    
    UIImagePickerController* cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    
    
    //http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:cameraUI animated:YES completion:nil];
    });
}

#pragma mark - UIImagePickerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage* originalImage;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        originalImage = (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        float greaterSide = originalImage.size.width > originalImage.size.height ? originalImage.size.width : originalImage.size.height;
        int sizeFactor = 4;
        if (greaterSide / sizeFactor < 800) {
            sizeFactor = 2;
            if (greaterSide / sizeFactor < 800) {
                sizeFactor = 1;
            }
        }
        
        UIImage* resizedImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                               bounds:CGSizeMake(originalImage.size.width / sizeFactor, originalImage.size.height / sizeFactor)
                                                 interpolationQuality:kCGInterpolationHigh];
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil , nil);
        
        // upload
        NSData* imageData = UIImagePNGRepresentation(resizedImage);
        PFFile* imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        
        PFObject *userPhoto = [PFObject objectWithClassName:@"Image"];
        userPhoto[@"imageName"] = @"image";
        userPhoto[@"imageFile"] = imageFile;
        [userPhoto saveInBackground];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end