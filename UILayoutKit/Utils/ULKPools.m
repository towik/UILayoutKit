//
//  Pools.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKPools.h"
#import "ULKFinitePool.h"
#import "ULKSynchronizedPool.h"

@implementation ULKPools

+ (id<ULKPool>)simplePoolForPoolableManager:(id<ULKPoolableManager>)poolableManager {
    return [[ULKFinitePool alloc] initWithPoolableManager:poolableManager];
}

+ (id<ULKPool>)finitePoolWithLimit:(NSUInteger)limit forPoolableManager:(id<ULKPoolableManager>)poolableManager {
    return [[ULKFinitePool alloc] initWithPoolableManager:poolableManager limit:limit];
}

+ (id<ULKPool>)synchronizedPoolForPool:(id<ULKPool>)pool {
    return [[ULKSynchronizedPool alloc] initWithPool:pool];
}

+ (id<ULKPool>)synchronizedPoolForPool:(id<ULKPool>)pool withLock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership {
    return [[ULKSynchronizedPool alloc] initWithPool:pool lock:lock takeLockOwnership:takeLockOwnership];
}

@end
