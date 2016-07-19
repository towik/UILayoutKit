//
//  ULKPool.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULKPoolable.h"

@protocol ULKPool <NSObject>

- (id<ULKPoolable>)acquire;

- (void)releaseElement:(id<ULKPoolable>) element;

@end
