//
//  ViewController.m
//  LexisParty-Guest
//
//  Created by Alex Sue on 2/11/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "RsvpMeStuff.h"

@interface ViewController () {
    AppDelegate* appDelegate;
    CLProximity lastProximity;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        lastProximity = CLProximityUnknown;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkIn"];
    
    BOOL locationEnabled = YES;
    if(![CLLocationManager locationServicesEnabled]) {
        //You need to enable Location Services
        locationEnabled = NO;
    }
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        //Region monitoring is not available for this Class;
        locationEnabled = NO;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        //You need to authorize Location Services for the APP
        locationEnabled = NO;
    }
    
    if ( !locationEnabled ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please enable location services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        // Do any additional setup after loading the view.
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self initRegion];
        [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
        if ([self.locationManager respondsToSelector:
             @selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:RSVPME_UUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:RSVPME_IDENTIFIER];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconFoundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //CLBeacon *beacon = [[CLBeacon alloc] init];
    CLBeacon *beacon = [beacons lastObject];
    if ( beacon.proximity != lastProximity ) {
        RsvpMeStuff* rsvpStuff = [RsvpMeStuff sharedRsvpMeStuff];
        if (beacon.proximity == CLProximityUnknown) {
            NSLog(@"Unknown Proximity");
            rsvpStuff.isNearEnough = NO;
        }
        else if (beacon.proximity == CLProximityImmediate) {
            NSLog(@"Immediate");
            rsvpStuff.isNearEnough = YES;
        }
        else if (beacon.proximity == CLProximityNear) {
            NSLog(@"Near");
            rsvpStuff.isNearEnough = YES;
        }
        else if (beacon.proximity == CLProximityFar) {
            NSLog(@"Far");
            rsvpStuff.isNearEnough = NO;
        }
    }
    lastProximity = beacon.proximity;
    //NSLog(@"%ld", beacon.rssi);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"rangingBeaconsDidFailForRegion: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}


@end
