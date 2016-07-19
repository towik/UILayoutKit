//
//  DependencyGraphNode.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ULKPoolable.h"

@interface ULKDependencyGraphNode : NSObject<ULKPoolable>

@property (nonatomic, strong) UIView *view;
@property (nonatomic, readonly) NSMutableSet *dependents;
@property (nonatomic, readonly) NSMutableDictionary *dependencies;

- (void)releaseNode;
+ (ULKDependencyGraphNode *)acquireView:(UIView *)view;

@end
