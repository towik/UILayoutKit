//
//  ULKDrawableContainer.m
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawableContainer.h"
#import "ULKDrawableContainer+ULK_Internal.h"
#import "ULKDrawable+ULK_Internal.h"

@interface ULKDrawableContainerConstantState ()

@property (nonatomic, weak) ULKDrawableContainer *owner;

// Drawables
@property (nonatomic, strong) NSMutableArray *drawables;

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

@end

@implementation ULKDrawableContainerConstantState

- (void)dealloc {
    for (ULKDrawable *drawable in self.drawables) {
        drawable.delegate = nil;
    }
}

- (instancetype)initWithState:(ULKDrawableContainerConstantState *)state owner:(ULKDrawableContainer *)owner {
    self = [super init];
    if (self) {
        self.owner = owner;
        if (state != nil) {
            NSMutableArray *drawables = [[NSMutableArray alloc] initWithCapacity:[state.drawables count]];
            for (ULKDrawable *drawable in state.drawables) {
                ULKDrawable *copiedDrawable = [drawable copy];
                copiedDrawable.delegate = owner;
                [drawables addObject:copiedDrawable];
            }
            self.drawables = drawables;
            self.constantIntrinsicSize = state.constantIntrinsicSize;
            self.constantMinimumSize = state.constantMinimumSize;
            self.constantSizeComputed = state.constantSizeComputed;
            self.haveStateful = state.haveStateful;
            self.stateful = state.stateful;
            self.paddingComputed = state.paddingComputed;
            self.padding = state.padding;
            self.hasPadding = state.hasPadding;
        } else {
            NSMutableArray *drawables = [[NSMutableArray alloc] initWithCapacity:10];
            self.drawables = drawables;
        }
    }
    return self;
}

- (void)addChildDrawable:(ULKDrawable *)drawable {
    [self.drawables addObject:drawable];
    drawable.delegate = self.owner;
    
    self.haveStateful = FALSE;
    self.constantSizeComputed = FALSE;
    self.paddingComputed = FALSE;
}

- (void)computeConstantSize {
    CGSize minSize = CGSizeZero;
    CGSize intrinsicSize = CGSizeZero;
    for (ULKDrawable *drawable in self.drawables) {
        CGSize min = drawable.minimumSize;
        CGSize intrinsic = drawable.intrinsicSize;
        if (min.width > minSize.width) minSize.width = min.width;
        if (min.height > minSize.height) minSize.height = min.height;
        if (intrinsic.width > intrinsicSize.width) intrinsicSize.width = intrinsic.width;
        if (intrinsic.height > intrinsicSize.height) intrinsicSize.height = intrinsic.height;
    }
    self.constantIntrinsicSize = intrinsicSize;
    self.constantMinimumSize = minSize;
    self.constantSizeComputed = TRUE;
}

- (CGSize)constantIntrinsicSize {
    if (!self.isConstantSizeComputed) {
        [self computeConstantSize];
    }
    return _constantIntrinsicSize;
}

- (CGSize)constantMinimumSize {
    if (!self.isConstantSizeComputed) {
        [self computeConstantSize];
    }
    return _constantMinimumSize;
}

- (BOOL)isStateful {
    if (self.haveStateful) {
        return _stateful;
    }
    BOOL stateful = FALSE;
    for (ULKDrawable *child in self.drawables) {
        if (child.isStateful) {
            stateful = TRUE;
            break;
        }
    }
    _stateful = stateful;
    _haveStateful = TRUE;
    return stateful;
}

- (void)computePadding {
    UIEdgeInsets padding = UIEdgeInsetsZero;
    BOOL hasPadding = FALSE;
    for (ULKDrawable *drawable in self.drawables) {
        if (drawable.hasPadding) {
            hasPadding = TRUE;
            UIEdgeInsets childPadding = drawable.padding;
            padding.left = MAX(padding.left, childPadding.left);
            padding.right = MAX(padding.right, childPadding.right);
            padding.top = MAX(padding.top, childPadding.top);
            padding.bottom = MAX(padding.bottom, childPadding.bottom);
        }
    }
    _padding = padding;
    _hasPadding = hasPadding;
    _paddingComputed = TRUE;
}

- (UIEdgeInsets)padding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return _padding;
}

- (BOOL)hasPadding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return _hasPadding;
}

@end

@interface ULKDrawableContainer ()

@property (nonatomic, strong) ULKDrawableContainerConstantState *internalConstantState;
@property (nonatomic, strong) ULKDrawable *currentDrawable;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation ULKDrawableContainer

@synthesize currentDrawable = _currentDrawable;


- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentIndex = -1;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    [self.currentDrawable drawInContext:context];
}

- (BOOL)selectDrawableAtIndex:(NSInteger)index {
    BOOL ret = TRUE;
    ULKDrawableContainerConstantState *state = self.internalConstantState;
    if (index == self.currentIndex) {
        ret = FALSE;
    } else if (index >= 0 && index < [state.drawables count]) {
        ULKDrawable *drawable = (state.drawables)[index];
        self.currentDrawable = drawable;
        self.currentIndex = index;
        drawable.state = self.state;
        drawable.bounds = self.bounds;
        [drawable setLevel:self.level];
    } else {
        self.currentDrawable = nil;
        self.currentIndex = -1;
    }
    if (ret) [self invalidateSelf];
    return ret;
}

- (CGSize)intrinsicSize {
    CGSize ret = CGSizeZero;
    ULKDrawableContainerConstantState *state = self.internalConstantState;
    if (state.isConstantSize) {
        ret = state.constantIntrinsicSize;
    } else {
        ret = self.currentDrawable.intrinsicSize;
    }
    return ret;
}

- (CGSize)minimumSize {
    CGSize ret = CGSizeZero;
    ULKDrawableContainerConstantState *state = self.internalConstantState;
    if (state.isConstantSize) {
        ret = state.constantMinimumSize;
    } else {
        ret = self.currentDrawable.minimumSize;
    }
    return ret;
}

- (void)onStateChangeToState:(UIControlState)state {
    [super onStateChangeToState:state];
    [self.currentDrawable setState:self.state];
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    self.currentDrawable.bounds = bounds;
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    BOOL ret = FALSE;
    if (_currentDrawable != nil) {
        ret = [_currentDrawable setLevel:level];
    }
    return ret;
}

- (BOOL)isStateful {
    return self.internalConstantState.isStateful;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.padding;
}

- (BOOL)hasPadding {
    return self.internalConstantState.hasPadding;
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (ULKDrawable *)currentDrawable {
    return _currentDrawable;
}

#pragma mark - ULKDrawableDelegate

- (void)drawableDidInvalidate:(ULKDrawable *)drawable {
    if (drawable == _currentDrawable) {
        [self.delegate drawableDidInvalidate:self];
    }
}

@end
