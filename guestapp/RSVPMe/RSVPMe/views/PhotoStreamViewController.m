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
    
    imageArray = [NSMutableArray array];
    
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
    
    [self loadImages];
}

- (IBAction)showMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)handleRefresh:(id)sender {
    [self loadImages];
}

- (void)loadImages {
    if (isRefreshing) {
        return;
    }
    
    isRefreshing = YES;
    PFQuery* query = [PFQuery queryWithClassName:@"Image"];
    [query addDescendingOrder:@"updatedAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray* results, NSError* error) {
        if (!error) {
            [imageArray removeAllObjects];
            
            [imageArray addObjectsFromArray:results];
            
            [self.collectionView reloadData];
            
            [refreshControl endRefreshing];
            
        }
        isRefreshing = NO;
    }];
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

#pragma mark UICollectionViewDataSource delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [imageArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell1" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor grayColor];
    
    PFFile* imageFile = [[imageArray objectAtIndex:indexPath.row] objectForKey:@"imageFile"];
    [imageFile getDataInBackgroundWithBlock:^(NSData* data, NSError* error) {
        if (!error) {
            UIImageView* cellView = (UIImageView*) [cell.contentView viewWithTag:3];
            cellView.image = [UIImage imageWithData:data];
        }
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize toReturn = CGSizeMake(118, 118);
    
    if ((indexPath.row % 2) == 0) {
        //toReturn = CGSizeMake(60, 40);
    }
    
    return toReturn;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*if (!isEditingMode) {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    }
    else {
        [self removeCellButtonPressed];
    }*/
}

@end