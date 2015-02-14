//
//  AppDelegate.h
//  RSVPMe-Host
//
//  Created by Alex Sue on 2/13/15.
//  Copyright (c) 2015 RSVPME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define RSVPME_UUID @"0494E11D-0BAC-43E6-B570-2AF6D36F8562"
#define RSVPME_IDENTIFIER @"com.gopherapps.rsvpme"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CBPeripheralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLBeaconRegion* beaconRegion;
@property (strong, nonatomic) NSDictionary* beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager* peripheralManager;


- (void)transmitBeacon;

@end

