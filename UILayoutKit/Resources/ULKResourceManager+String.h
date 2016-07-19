//
//  ULKResourceManager+String.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "ULKResourceManager+Core.h"

@interface ULKResourceManager (String)

- (NSString *)stringForIdentifier:(NSString *)identifierString;

- (NSArray *)stringArrayForIdentifier:(NSString *)identifierString;

@end
