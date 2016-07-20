//
//  ULKDrawableContainer+ULK_Internal.h
//  UILayoutKit
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawableContainer.h"

@interface ULKDrawableContainer (ULK_Internal)

@property (nonatomic, readonly) NSInteger currentIndex;

- (instancetype)initWithState:(ULKDrawableContainerConstantState *)state;
- (BOOL)selectDrawableAtIndex:(NSInteger)index;

@end

@interface ULKDrawableContainerConstantState (ULK_Internal)

@property (nonatomic, assign) ULKDrawableContainer *owner;

// Drawables
@property (nonatomic, retain) NSMutableArray *drawables;

// Dimension
@property (nonatomic, assign) CGSize constantIntrinsicSize;
@property (nonatomic, assign) CGSize constantMinimumSize;
@property (nonatomic, assign, getter = isConstantSizeComputed) BOOL constantSizeComputed;
@property (nonatomic, assign, getter = isConstantSize) BOOL constantSize;

// Statful
@property (nonatomic, assign) BOOL haveStateful;
@property (nonatomic, assign, getter = isStateful) BOOL stateful;

// Padding
@property (nonatomic, assign, getter = isPaddingComputed) BOOL paddingComputed;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, assign) BOOL hasPadding;

- (instancetype)initWithState:(ULKDrawableContainerConstantState *)state owner:(ULKDrawableContainer *)owner;
- (void)addChildDrawable:(ULKDrawable *)drawable;

@end