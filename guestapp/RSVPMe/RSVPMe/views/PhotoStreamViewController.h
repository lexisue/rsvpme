//
//  PhotoStreamViewController.h
//  RSVPMe
//
//  Created by Alex Sue on 2/14/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface PhotoStreamViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate> {
    UIRefreshControl* refreshControl;
}

- (IBAction)showMenu:(id)sender;

- (void)handleRefresh:(id)sender;

- (IBAction)addPhoto:(id)sender;

- (void)loadImages;

@end