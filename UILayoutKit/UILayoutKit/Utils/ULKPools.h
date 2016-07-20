//
//  Pools.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULKPoolable.h"
#import "ULKPoolableManager.h"
#import "ULKPool.h"

@interface ULKPools : NSObject

+ (id<ULKPool>)simplePoolForPoolableManager:(id<ULKPoolableManager>)poolableManager;
+ (id<ULKPool>)finitePoolWithLimit:(NSUInteger)limit forPoolableManager:(id<ULKPoolableManager>)poolableManager;
+ (id<ULKPool>)synchronizedPoolForPool:(id<ULKPool>)pool;
+ (id<ULKPool>)synchronizedPoolForPool:(id<ULKPool>)pool withLock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership;

@end
