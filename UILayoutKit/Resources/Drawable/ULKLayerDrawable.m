//
//  ULKLayerDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKLayerDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "ULKResourceManager.h"
#import "TBXML+ULK.h"

@interface ULKLayerDrawableItem : NSObject

@property (nonatomic, strong) ULKDrawable *drawable;
@property (nonatomic, assign) UIEdgeInsets insets;

@end

@implementation ULKLayerDrawableItem


@end

@interface ULKLayerDrawableConstantState ()

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign, getter = isPaddingComputed) BOOL paddingComputed;
@property (nonatomic, assign) BOOL hasPadding;
@property (nonatomic, assign) UIEdgeInsets padding;

@end

@implementation ULKLayerDrawableConstantState

- (void)dealloc {
    for (ULKLayerDrawableItem *item in self.items) {
        item.drawable.delegate = nil;
    }
}

- (instancetype)initWithState:(ULKLayerDrawableConstantState *)state owner:(ULKLayerDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[state.items count]];
            for (ULKLayerDrawableItem *origItem in state.items) {
                ULKLayerDrawableItem *item = [[ULKLayerDrawableItem alloc] init];
                ULKDrawable *drawable = [origItem.drawable copy];
                drawable.delegate = owner;
                item.drawable = drawable;
                item.insets = origItem.insets;
                [items addObject:item];
            }
            self.items = items;

        } else {
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:10];
            self.items = items;

        }
    }
    return self;
}

- (void)addLayer:(ULKDrawable *)drawable insets:(UIEdgeInsets)insets owner:(ULKLayerDrawable *)owner {
    ULKLayerDrawableItem *item = [[ULKLayerDrawableItem alloc] init];
    item.drawable = drawable;
    item.insets = insets;
    [self.items addObject:item];
    _paddingComputed = FALSE;
}

- (void)computePadding {
    UIEdgeInsets padding = UIEdgeInsetsZero;
    BOOL hasPadding = FALSE;
    for (ULKLayerDrawableItem *item in self.items) {
        ULKDrawable *drawable = item.drawable;
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
    UIEdgeInsets padding = UIEdgeInsetsZero;
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    padding = _padding;
    return padding;
}

- (BOOL)hasPadding {
    if (!self.isPaddingComputed) {
        [self computePadding];
    }
    return _hasPadding;
}


@end

@interface ULKLayerDrawable ()

@property (nonatomic, strong) ULKLayerDrawableConstantState *internalConstantState;

@end

@implementation ULKLayerDrawable


- (instancetype)initWithState:(ULKLayerDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKLayerDrawableConstantState *s = [[ULKLayerDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)onStateChangeToState:(UIControlState)state {
    [super onStateChangeToState:state];
    for (ULKLayerDrawableItem *item in self.internalConstantState.items) {
        item.drawable.state = self.state;
    }
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    [super onBoundsChangeToRect:bounds];
    for (ULKLayerDrawableItem *item in self.internalConstantState.items) {
        CGRect insetRect = UIEdgeInsetsInsetRect(bounds, item.insets);
        item.drawable.bounds = insetRect;
    }
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    ULKLayerDrawableConstantState *state = self.internalConstantState;
    BOOL changed = FALSE;
    for (ULKLayerDrawableItem *item in state.items) {
        if ([item.drawable setLevel:level]) {
            changed = TRUE;
        }
    }
    return changed;
}

- (void)drawInContext:(CGContextRef)context {
    for (ULKLayerDrawableItem *item in self.internalConstantState.items) {
        CGContextSaveGState(context);
        [item.drawable drawInContext:context];
        CGContextRestoreGState(context);
    }
    OUTLINE_RECT(context, self.bounds);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = nil;
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            
            UIEdgeInsets insets = UIEdgeInsetsZero;
            insets.left = [attrs[@"left"] floatValue];
            insets.top = [attrs[@"top"] floatValue];
            insets.right = [attrs[@"right"] floatValue];
            insets.bottom = [attrs[@"bottom"] floatValue];
            
            NSString *drawableResId = attrs[@"drawable"];
            ULKDrawable *drawable = nil;
            if (drawableResId != nil) {
                drawable = [[ULKResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
            } else if (child->firstChild != NULL) {
                drawable = [ULKDrawable createFromXMLElement:child->firstChild];
            } else {
                NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
            }
            if (drawable != nil) {
                [self.internalConstantState addLayer:drawable insets:insets owner:self];
            }
        }
        child = child->nextSibling;
    }
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

- (CGSize)intrinsicSize {
    CGSize size = CGSizeMake(-1, -1);
    for (ULKLayerDrawableItem *item in self.internalConstantState.items) {
        UIEdgeInsets insets = item.insets;
        CGSize s = item.drawable.intrinsicSize;
        s.width += insets.left + insets.right;
        s.height += insets.top + insets.bottom;
        if (s.width > size.width) {
            size.width = s.width;
        }
        if (s.height > size.height) {
            size.height = s.height;
        }
    }
    return size;
}

#pragma mark - ULKDrawableDelegate

- (void)drawableDidInvalidate:(ULKDrawable *)drawable {
    [self.delegate drawableDidInvalidate:drawable];
}

@end
