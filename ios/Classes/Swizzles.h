//
//  NSURLSessionConfiguration+Authorization.h
//  Runner
//
//  Created by Marvin The Robot on 21/08/2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/MGLMapView.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (HttpHeaders)
+ (void) load;
@end

NS_ASSUME_NONNULL_END
