//
//  RsvpMeStuff.h
//  RSVPMe
//
//  Created by Corey Taira on 2/14/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RsvpMeStuff : NSObject

@property (nonatomic) BOOL isNearEnough;

+ (RsvpMeStuff*)sharedRsvpMeStuff;


@end
