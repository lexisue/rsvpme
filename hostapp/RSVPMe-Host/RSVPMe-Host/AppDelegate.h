//
//  AppDelegate.h
//  RSVPMe-Host
//
//  Created by Alex Sue on 2/13/15.
//  Copyright (c) 2015 RSVPME. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BEACON_IDENTIFIER @"com.gopherapps.rsvpme"

typedef NS_ENUM(NSUInteger, CSMApplicationMode) {
    CSMApplicationModePeripheral = 0,
    CSMApplicationModeRegionMonitoring
};


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSUUID *myUUID;

@property (nonatomic, assign) CSMApplicationMode applicationMode;

/**
 * Return the appdelegate class
 */
+ (AppDelegate*)appDelegate;


@end

