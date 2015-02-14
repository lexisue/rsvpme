//
//  PhotoStreamViewController.h
//  RSVPMe
//
//  Created by Alex Sue on 2/14/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoStreamViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource> {
    UIRefreshControl* refreshControl;
}

@end