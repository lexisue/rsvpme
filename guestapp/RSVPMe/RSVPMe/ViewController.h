//
//  ViewController.h
//  LexisParty-Guest
//
//  Created by Alex Sue on 2/11/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"


#define RSVPME_UUID @"0494E11D-0BAC-43E6-B570-2AF6D36F8562"
#define RSVPME_IDENTIFIER @"com.gopherapps.rsvpme"

@interface ViewController : ECSlidingViewController <CLLocationManagerDelegate>


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

-(void)initRegion;

@end

