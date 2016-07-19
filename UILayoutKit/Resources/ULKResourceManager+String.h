//
//  ULKResourceManager+String.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceManager+Core.h"

@interface ULKResourceManager (String)

- (NSString *)stringForIdentifier:(NSString *)identifierString;

- (NSArray *)stringArrayForIdentifier:(NSString *)identifierString;

@end
