//
//  DependencyGraph.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDependencyGraph.h"
#import "ULKDependencyGraphNode.h"
#import "UIView+ULK_Layout.h"
#import "ULKRelativeLayoutParams.h"

@implementation ULKDependencyGraph {
    NSMutableArray *_nodes;
    NSMutableArray *_roots;
}

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		_keyNodes = [[NSMutableDictionary alloc] init];
        _nodes = [[NSMutableArray alloc] init];
        _roots = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)clear {
    NSUInteger count = [_nodes count];
    
    for (int i = 0; i < count; i++) {
        ULKDependencyGraphNode *node = _nodes[i];
        [node releaseNode];
    }
    [_nodes removeAllObjects];
    [_keyNodes removeAllObjects];
    [_roots removeAllObjects];
}

- (void)addView:(UIView *)view {
    NSString *identifier = view.ulk_identifier;
    ULKDependencyGraphNode *node = [ULKDependencyGraphNode acquireView:view];
    
    if (identifier != nil) {
        _keyNodes[identifier] = node;
    }
    
    [_nodes addObject:node];
}

/**
 * Finds the roots of the graph. A root is a node with no dependency and
 * with [0..n] dependents.
 *
 * @param rulesFilter The list of rules to consider when building the
 *        dependencies
 *
 * @return A list of node, each being a root of the graph
 */
- (NSMutableArray *)findRootsWithRules:(NSArray *)rulesFilter {
    NSMutableDictionary *keyNodes = _keyNodes;
    NSMutableArray *nodes = _nodes;
    NSUInteger count = [nodes count];
    
    // Find roots can be invoked several times, so make sure to clear
    // all dependents and dependencies before running the algorithm
    for (int i = 0; i < count; i++) {
        ULKDependencyGraphNode *node = nodes[i];
        [node.dependents removeAllObjects];
        [node.dependencies removeAllObjects];
    }
    
    // Builds up the dependents and dependencies for each node of the graph
    for (int i = 0; i < count; i++) {
        ULKDependencyGraphNode *node = nodes[i];
        
        ULKRelativeLayoutParams *layoutParams = (ULKRelativeLayoutParams *)node.view.layoutParams;
        NSArray *rules = layoutParams.rules;
        NSInteger rulesCount = [rulesFilter count];
        
        // Look only the the rules passed in parameter, this way we build only the
        // dependencies for a specific set of rules
        for (int j = 0; j < rulesCount; j++) {
            NSNumber *ruleId = rulesFilter[j];
            id rule = rules[[ruleId integerValue]];
            if (rule != [NSNull null] && [rule isKindOfClass:[NSString class]]) {
                // The node this node depends on
                ULKDependencyGraphNode *dependency = keyNodes[rule];
                // Skip unknowns and self dependencies
                if (dependency == nil || dependency == node) {
                    continue;
                }
                // Add the current node as a dependent
                [dependency.dependents addObject:node];
                // Add a dependency to the current node
                (node.dependencies)[rule] = dependency;
            }
        }
    }
    
    NSMutableArray *roots = _roots;
    [roots removeAllObjects];
    
    // Finds all the roots in the graph: all nodes with no dependencies
    for (int i = 0; i < count; i++) {
        ULKDependencyGraphNode *node = nodes[i];
        if ([node.dependencies count] == 0) [roots addObject:node];
    }
    
    return roots;
}

/**
 * Builds a sorted list of views. The sorting order depends on the dependencies
 * between the view. For instance, if view C needs view A to be processed first
 * and view A needs view B to be processed first, the dependency graph
 * is: B -> A -> C. The sorted array will contain views B, A and C in this order.
 *
 * @param sorted The sorted list of views. The length of this array must
 *        be equal to getChildCount().
 * @param rules The list of rules to take into account.
 */
- (void)getSortedViews:(NSMutableArray *)sorted forRules:(NSArray *)rules {
    NSMutableArray *roots = [self findRootsWithRules:rules];
    NSInteger index = 0;
    
    while ([roots count] > 0) {
        ULKDependencyGraphNode *node = roots[0];
        [roots removeObjectAtIndex:0];
        UIView *view = node.view;
        NSString *key = view.ulk_identifier;
        
        sorted[index++] = view;
        
        NSMutableSet *dependents = node.dependents;
        for (ULKDependencyGraphNode *dependent in dependents) {
            NSMutableDictionary *dependencies = dependent.dependencies;
            
            [dependencies removeObjectForKey:key];
            if ([dependencies count] == 0) {
                [roots addObject:dependent];
            }
        }
    }
    
    if (index < [sorted count]) {
        @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"Circular dependencies cannot exist in RelativeLayout" userInfo:nil];
    }
}

@end
