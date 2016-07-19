//
//  DependencyGraphNode.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKDependencyGraphNode.h"
#import "ULKPools.h"

#define POOL_LIMIT 100

@interface ULKSimplePoolableManager : NSObject<ULKPoolableManager> {
    Class _class;
}

@end

@implementation ULKSimplePoolableManager

- (instancetype)initWithClass:(Class)class {
    self = [super init];
    if (self) {
        _class = class;
    }
    return self;
}

- (id<ULKPoolable>)newInstance {
    return [[_class alloc] init];
}

- (void)onAcquiredElement:(id<ULKPoolable>)element {
    
}

- (void)onReleasedElement:(id<ULKPoolable>)element {
    
}

@end

@implementation ULKDependencyGraphNode

@synthesize nextPoolable = _next;
@synthesize isPooled = _isPooled;

+ (id<ULKPool>)pool {
    static id<ULKPool> Pool;
    if (Pool == nil) {
        id<ULKPoolableManager> poolableManager = [[ULKSimplePoolableManager alloc] initWithClass:[ULKDependencyGraphNode class]];
        Pool = [ULKPools synchronizedPoolForPool:[ULKPools finitePoolWithLimit:POOL_LIMIT forPoolableManager:poolableManager]];
    }
    return Pool;
}



- (instancetype) init {
	self = [super init]; 
	if (self != nil) {
        _dependents = [[NSMutableSet alloc] init];
        _dependencies = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (ULKDependencyGraphNode *)acquireView:(UIView *)view {
    ULKDependencyGraphNode *node = [[ULKDependencyGraphNode pool] acquire];
    node.view = view;
    return node;
}

- (void)releaseNode {
    self.view = nil;
    [_dependents removeAllObjects];
    [_dependencies removeAllObjects];
    [[ULKDependencyGraphNode pool] releaseElement:self];
}

@end
