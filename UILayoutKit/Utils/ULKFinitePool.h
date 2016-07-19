//
//  FinitePool.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULKPool.h"
#import "ULKPoolableManager.h"

@interface ULKFinitePool : NSObject <ULKPool>

- (instancetype)initWithPoolableManager:(id<ULKPoolableManager>)manager NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPoolableManager:(id<ULKPoolableManager>)manager limit:(NSUInteger)limit NS_DESIGNATED_INITIALIZER;

@end
