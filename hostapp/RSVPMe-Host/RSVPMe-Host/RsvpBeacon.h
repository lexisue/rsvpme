//
//  RsvpBeacon.h
//  RSVPMe-Host
//
//  Created by Corey Taira on 2/14/15.
//  Copyright (c) 2015 RSVPME. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@interface RsvpBeacon : NSObject <CBPeripheralManagerDelegate> {
    
}





- (void)transmitBeacon;

@end
