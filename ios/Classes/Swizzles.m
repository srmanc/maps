//
//  NSURLSessionConfiguration+Authorization.m
//  CartoDemo
//
//  Created by Jan Driesen on 03.08.20.
//  Copyright © 2020 Driesengard. All rights reserved.
//

#import "Swizzles.h"
#import "NSObject+DTRuntime.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSDictionary *_headers;
static NSArray *_filter;
static NSDictionary *_usedHeaders;

@end

@implementation NSURLRequest (HttpHeaders)

+ (void) load {
    NSLog(@"Swizzle: registering NSURLRequest.requestWithURL override for custom headers");

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class targetClass = [NSURLRequest class];
        Method oldMethod = class_getClassMethod(targetClass, @selector(requestWithURL:));
        Method newMethod = class_getClassMethod(targetClass, @selector(__swizzle_requestWithURL:));
        method_exchangeImplementations(oldMethod, newMethod);
    });
}


+ (NSURLRequest*) __swizzle_requestWithURL:(NSURL*)url {
    NSLog(@"Swizzle: calling override for NSURLRequest.requestWithURL");

    NSMutableURLRequest *req = (NSMutableURLRequest *)[NSURLRequest __swizzle_requestWithURL:url];
    NSArray<NSString*>* stack = [NSThread callStackSymbols];
    if(![url.scheme isEqualToString:@"ws"] && [stack count] >= 2 && [stack[1] containsString:@"Mapbox"] == YES) {
        NSDictionary<NSString*,NSString*>* headers = _headers;
        NSArray<NSString*>* filter = _filter;
        for (NSString* pattern in filter) {
            if ([url.absoluteString containsString:pattern] == YES) {
                for (NSString* key in headers) {
                    [req setValue: headers[key] forHTTPHeaderField:key];
                }
                _usedHeaders = headers;
                return req;
            }
        }
    }

    return req;    
}

+ (void) setHttpHeaders:(NSDictionary<NSString*,NSString*> *)headers forFilter:(NSArray<NSString*> *)filter {    
    _headers = headers;
    _filter = filter;
}

+ (NSDictionary<NSString*,NSString*> *) getUsedHeaders {
    return _usedHeaders;
}

@end