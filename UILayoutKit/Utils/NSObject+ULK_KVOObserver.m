//
//  NSObject+ULK_KVOObserver.m
//  UILayoutKit
//
//  Created by Tom Quist on 21.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "NSObject+ULK_KVOObserver.h"
#import <objc/runtime.h>

@interface ULKKVOObserver : NSObject

@property (readwrite, retain) NSString *identifier;
@property (readwrite, copy) ULKKVOObserverBlock observerBlock;
@property (readwrite, assign) id object;
@property (readwrite, retain) NSArray *keyPaths;

@end

@implementation ULKKVOObserver

- (void)dealloc {
    for (NSString *keyPath in self.keyPaths) {
        [self.object removeObserver:self forKeyPath:keyPath];
    }
    self.identifier = nil;
    self.observerBlock = nil;
    self.keyPaths = nil;
//    [super dealloc];
}

- (instancetype)initWithIdentifier:(NSString *)identifier object:(id)obj keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options observerBlock:(ULKKVOObserverBlock)block {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.object = obj;
        self.keyPaths = keyPaths;
        self.observerBlock = block;
        for (NSString *keyPath in keyPaths) {
            [obj addObserver:self forKeyPath:keyPath options:options context:nil];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.observerBlock(keyPath, object, change);
}

@end


@interface NSObject ()

@property (nonatomic, readonly) NSMutableDictionary *ulk_kvoObservers;

@end

@implementation NSObject (ULK_KVOObserver)

static char ulk_kvoObserversKey;

- (NSMutableDictionary *)ulk_kvoObservers {
    @synchronized(self) {
        NSMutableDictionary *array = objc_getAssociatedObject(self, &ulk_kvoObserversKey);
        if (array == nil) {
//            array = [[[NSMutableDictionary alloc] init] autorelease];
            array = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self,
                                     &ulk_kvoObserversKey,
                                     array,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return array;
    }
}

- (void)ulk_removeObserverWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *observers = [self ulk_kvoObservers];
    [observers removeObjectForKey:identifier];
}

- (void)ulk_addObserver:(ULKKVOObserverBlock)observer withIdentifier:(NSString *)identifier forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options {
    ULKKVOObserver *observerObject = [[ULKKVOObserver alloc] initWithIdentifier:identifier object:self keyPaths:keyPaths options:options observerBlock:observer];
    [self ulk_kvoObservers][identifier] = observerObject;
//    [observerObject release];
}

- (BOOL)ulk_hasObserverWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *observers = [self ulk_kvoObservers];
    return observers[identifier] != nil;
}

@end
