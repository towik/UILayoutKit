//
//  SynchronizedPool.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULKPool.h"

@interface ULKSynchronizedPool : NSObject <ULKPool>

- (instancetype)initWithPool:(id<ULKPool>)pool lock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPool:(id<ULKPool>)pool;

@end
