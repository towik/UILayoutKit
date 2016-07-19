//
//  Poolable.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ULKPoolable <NSObject>

@property (nonatomic, retain) id<ULKPoolable> nextPoolable;
@property (nonatomic, assign, setter=setPooled:) BOOL isPooled;

@end
