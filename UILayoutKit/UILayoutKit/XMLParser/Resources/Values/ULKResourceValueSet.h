//
//  ULKResourceValueSet.h
//  UILayoutKit
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
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
