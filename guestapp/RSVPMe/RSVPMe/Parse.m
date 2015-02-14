//
//  Parse.m
//  RSVPMe
//
//  Created by Alex Sue on 2/13/15.
//  Copyright (c) 2015 Gopher Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"

@implementation Parse

+ (void)callFunctionInBackground:(NSString*)functionName withParameters:(NSDictionary*)params block:(void(^)(NSDictionary* result, NSError* error))block {
    
    NSString* urlToUse = [NSString stringWithFormat:@"https://api.parse.com/1/functions/%@", functionName];
    NSMutableURLRequest* request = [Parse getURLRequestWithURL:urlToUse withParameters:params];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        if (data && !error) {
            if (block) {
                NSDictionary* resultDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if ([resultDict objectForKey:@"error"]) {
                    NSDictionary* details = @{NSLocalizedDescriptionKey: [resultDict objectForKey:@"error"]};
                    NSError* errorToSend = [NSError errorWithDomain:@"PARSE_REST" code:500 userInfo:details];
                    block(nil, errorToSend);
                }
                else {
                    block([resultDict objectForKey:@"result"], error);
                }
            }
        }
        else {
            if (block) {
                block(nil, error);
            }
        }
    }];
}

+ (NSMutableURLRequest*)getURLRequestWithURL:(NSString*)url withParameters:(NSDictionary*)params {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    [request addValue:@"LHPd3YWPRWnHYLdOPsynFpXnpl6jgVHt5pGSvLXN" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request addValue:@"rLNpqoXHsMFiBg00loVaDAvthxH92jWDOnDKmZZl" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    
    if (!params) {
        params = [[NSMutableDictionary alloc] init];
    }
    NSData* data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    [request setHTTPBody:data];
    
    return request;
}



@end