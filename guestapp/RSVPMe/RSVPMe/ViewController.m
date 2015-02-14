//
//  ViewController.m
//  LexisParty-Guest
//
//  Created by Alex Sue on 2/11/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    CLLocationManager* locationManager;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkIn"];
    
    BOOL locationEnabled = YES;
    NSString* message = @"";
    if(![CLLocationManager locationServicesEnabled])
    {
        //You need to enable Location Services
        locationEnabled = NO;
        message = @"You need to enable Location Services";
    }
    //BUG this doesn't work
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        //Region monitoring is not available for this Class;
        locationEnabled = NO;
        message = @"Region monitoring is not available for this Class";
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        //You need to authorize Location Services for the APP
        locationEnabled = NO;
        message = @"You need to authorize Location Services for the APP";
    }
    if ( !locationEnabled ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [locationManager startUpdatingLocation];
        
        if ([locationManager respondsToSelector:
             @selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        
        [self monitorLocation:[NSDictionary dictionaryWithObjectsAndKeys:@"com.rsvpme", @"identifier", @"21.28589", @"latitude", @"-157.82387", @"longitude", @"300", @"radius", nil]];
        
        NSArray* monitoredRegions = [locationManager.monitoredRegions allObjects];
        for(CLRegion *region in monitoredRegions) {
            NSLog(@"request state for : %@", region.identifier);
            [locationManager requestStateForRegion:region];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)monitorLocation:(NSDictionary*)dictionary {
    NSString *identifier = [dictionary valueForKey:@"identifier"];
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    if(regionRadius > locationManager.maximumRegionMonitoringDistance) {
        regionRadius = locationManager.maximumRegionMonitoringDistance;
    }

    CLRegion* region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                    radius:regionRadius
                                                identifier:identifier];
    [locationManager startMonitoringForRegion:region];
}

- (CLLocationDistance)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude:coord1.latitude longitude:coord1.longitude];
    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude:coord2.latitude longitude:coord2.longitude];
    return [loc1 distanceFromLocation:loc2];
}

#pragma CLLocationManagerDelegate methods


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"YAY!" message:@"didEnterRegion" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExit %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Now monitoring for %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if(state == CLRegionStateInside) {
        NSLog(@"##Entered Region - %@", region.identifier);
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"##Exited Region - %@", region.identifier);
    }
    else{
        NSLog(@"##Unknown state  Region - %@", region.identifier);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    static BOOL firstTime = YES;
    NSLog(@"didUpdateLocations");
    if (firstTime) {
        firstTime = FALSE;
        NSSet * monitoredRegions = locationManager.monitoredRegions;
        NSLog(@"%@", monitoredRegions);
        if(monitoredRegions) {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
             {
                 for (int i = 0; i < [locations count]; i++) {
                     CLLocation* newLocation = [locations objectAtIndex:i];
                     NSString *identifer = region.identifier;
                     CLLocationCoordinate2D centerCoords =region.center;
                     NSLog(@"lat %f", newLocation.coordinate.latitude);
                     NSLog(@"lat %f", region.center.latitude);
                     NSLog(@"long %f", newLocation.coordinate.longitude);
                     NSLog(@"long %f", region.center.longitude);
                     CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                     CLLocationDistance radius = region.radius;
                     double abc = [self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
                     
                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Data" message:[NSString stringWithFormat:@"%f %f : %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, abc] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                     [alert show];
                     
                     if( [self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords] < radius) {
                         NSLog(@"Invoking didEnterRegion Manually for region: %@",identifer);
                         
                         //stop Monitoring Region temporarily
                         [locationManager stopMonitoringForRegion:region];
                         
                         [self locationManager:locationManager didEnterRegion:region];
                         //start Monitoing Region
                         [locationManager startMonitoringForRegion:region];
                         break;
                     }
                     
                 }

             }];
        }
        //Stop Location Updation, we dont need it now.
        [locationManager stopUpdatingLocation];
    }
    
}
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    static BOOL firstTime=TRUE;
    
    if(firstTime) {
        firstTime = FALSE;
        NSSet * monitoredRegions = locationManager.monitoredRegions;
        if(monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
             {
                 NSString *identifer = region.identifier;
                 CLLocationCoordinate2D centerCoords =region.center;
                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                 CLLocationDistance radius = region.radius;
                 
                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
                 if([currentLocationDistance floatValue] < radius)
                 {
                     NSLog(@"Invoking didEnterRegion Manually for region: %@",identifer);
                     
                     //stop Monitoring Region temporarily
                     [locationManager stopMonitoringForRegion:region];
                     
                     [self locationManager:locationManager didEnterRegion:region];
                     //start Monitoing Region
                     [locationManager startMonitoringForRegion:region];
                 }
             }];
        }
        //Stop Location Updation, we dont need it now.
        [locationManager stopUpdatingLocation];
        
    }
}
*/

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Error: %@", error);
}


@end
