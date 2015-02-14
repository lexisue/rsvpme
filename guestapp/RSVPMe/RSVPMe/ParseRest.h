//
//  Parse.h
//  RSVPMe
//
//  Created by Alex Sue on 2/13/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParseRest : NSObject {
    
}

+ (void)callFunctionInBackground:(NSString*)functionName withParameters:(NSDictionary*)params block:(void(^)(NSDictionary* result, NSError* error))block;

+ (NSMutableURLRequest*)getURLRequestWithURL:(NSString*)url withParameters:(NSDictionary*)params;

@end

