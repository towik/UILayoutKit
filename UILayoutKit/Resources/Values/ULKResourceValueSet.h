//
//  ULKResourceValueSet.h
//  UILayoutKit
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULKStyle.h"

@interface ULKResourceValueSet : NSObject

- (ULKStyle *)styleForName:(NSString *)name;
- (NSString *)stringForName:(NSString *)name;
- (NSArray *)stringArrayForName:(NSString *)name;
+ (ULKResourceValueSet *)createFromXMLData:(NSData *)data;
+ (ULKResourceValueSet *)createFromXMLURL:(NSURL *)url;

@end
