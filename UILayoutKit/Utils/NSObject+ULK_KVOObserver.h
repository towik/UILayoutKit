//
//  NSObject+ULK_KVOObserver.h
//  UILayoutKit
//
//  Created by Tom Quist on 21.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ULKKVOObserverBlock)(NSString *keyPath, id object, NSDictionary *change);

@interface NSObject (ULK_KVOObserver)

- (void)ulk_addObserver:(ULKKVOObserverBlock)observer withIdentifier:(NSString *)identifier forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options;
- (void)ulk_removeObserverWithIdentifier:(NSString *)identifier;
- (BOOL)ulk_hasObserverWithIdentifier:(NSString *)identifier;

@end
