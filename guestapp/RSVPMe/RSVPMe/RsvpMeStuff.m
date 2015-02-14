//
//  RsvpMeStuff.m
//  RSVPMe
//
//  Created by Corey Taira on 2/14/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import "RsvpMeStuff.h"
#import "SynthesizeSingleton.h"

/**
 * Try to make these "private"
 */
@interface RsvpMeStuff (Private)

@end

/**
 * RsvpMeStuff implementation
 */
@implementation RsvpMeStuff

@synthesize isNearEnough;

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(RsvpMeStuff);

@end
