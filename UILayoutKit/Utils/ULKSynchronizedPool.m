//
//  SynchronizedPool.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKSynchronizedPool.h"

@implementation ULKSynchronizedPool {
    BOOL _hasBlockOwnership;
    id<ULKPool> _pool;
    id _lock;
}


- (instancetype)initWithPool:(id<ULKPool>)pool lock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership {
    self = [super init];
    if (self) {
        _pool = pool;
        _lock = lock;
        _hasBlockOwnership = takeLockOwnership;
    }
    return self;
}

- (instancetype)initWithPool:(id<ULKPool>)pool {
	self = [self initWithPool:pool lock:self takeLockOwnership:FALSE];
	if (self != nil) {
        
	}
	return self;
}

- (id<ULKPoolable>)acquire {
    @synchronized(_lock) {
        return [_pool acquire];
    }
}

- (void)releaseElement:(id<ULKPoolable>)element {
    @synchronized(_lock) {
        return [_pool releaseElement:element];
    }
}

@end
