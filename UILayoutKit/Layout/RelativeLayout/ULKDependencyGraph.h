//
//  DependencyGraph.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ULKDependencyGraph : NSObject

@property (nonatomic, readonly) NSMutableDictionary *keyNodes;

- (void)clear;
- (void)addView:(UIView *)view;
- (void)getSortedViews:(NSMutableArray *)sorted forRules:(NSArray *)rules;

@end
