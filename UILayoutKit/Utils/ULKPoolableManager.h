//
//  PoolableManager.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULKPoolable.h"

@protocol ULKPoolableManager <NSObject>

- (id<ULKPoolable>)newInstance;

- (void)onAcquiredElement:(id<ULKPoolable>)element;
- (void)onReleasedElement:(id<ULKPoolable>)element;

@end
