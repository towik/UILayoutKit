//
//  FinitePool.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKFinitePool.h"

@implementation ULKFinitePool {
    NSUInteger _limit;
    BOOL _infinite;
    NSUInteger _poolCount;
    
    id<ULKPoolableManager> _manager;
    id<ULKPoolable> _root;
}

- (instancetype)initWithPoolableManager:(id<ULKPoolableManager>)manager {
	self = [super init];
	if (self != nil) {
		_manager = manager;
        _limit = 0;
        _infinite = TRUE;
	}
	return self;
}

- (instancetype)initWithPoolableManager:(id<ULKPoolableManager>)manager limit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _manager = manager;
        _limit = limit;
        _infinite = (limit == 0);
    }
    return self;
}

- (id<ULKPoolable>)acquire {
    id<ULKPoolable> element;
    if (_root != nil) {
        element = _root;
        _root = element.nextPoolable;
        _poolCount--;
    } else {
        element = [_manager newInstance];
    }
    
    if (element != nil) {
        element.nextPoolable = nil;
        [_manager onAcquiredElement:element];
    }
    
    return element;
}


- (void)releaseElement:(id<ULKPoolable>)element {
    if (_infinite || _poolCount < _limit) {
        _poolCount++;
        element.nextPoolable = _root;
        _root = element;
    }
    [_manager onReleasedElement:element];
}


@end
