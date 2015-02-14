//
//  RsvpBeacon.m
//  RSVPMe-Host
//
//  Created by Corey Taira on 2/14/15.
//  Copyright (c) 2015 RSVPME. All rights reserved.
//



#import "RsvpBeacon.h"

#define RSVPME_UUID @"0494E11D-0BAC-43E6-B570-2AF6D36F8562"
#define RSVPME_IDENTIFIER @"com.gopherapps.rsvpme"

@implementation RsvpBeacon

- (id)init {
    if ( self = [super init] ) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:RSVPME_UUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                    major:1
                                                                    minor:1
                                                               identifier:RSVPME_IDENTIFIER];
        
        /*
         _beaconRegion.notifyEntryStateOnDisplay = YES;
         _beaconRegion.notifyOnEntry = NO;
         _beaconRegion.notifyOnExit = NO;
         */
    }
    return self;
}


- (void)transmitBeacon {
    NSLog(@"transmitBeacon");
    _beaconPeripheralData = [_beaconRegion peripheralDataWithMeasuredPower:nil];
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                 queue:nil
                                                               options:nil];
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheralManagerDidUpdateState");
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [_peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [_peripheralManager stopAdvertising];
    }
}

@end
