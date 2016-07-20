//
//  ULKRotateDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 13.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKRotateDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "NSDictionary+ULK_ResourceManager.h"

@interface ULKRotateDrawableConstantState ()

@property (nonatomic, strong) ULKDrawable *drawable;
@property (nonatomic, assign) CGPoint pivot;
@property (nonatomic, assign) BOOL pivotXRelative;
@property (nonatomic, assign) BOOL pivotYRelative;
@property (nonatomic, assign) CGFloat fromDegrees;
@property (nonatomic, assign) CGFloat toDegrees;
@property (nonatomic, assign) CGFloat currentDegrees;

@end

@implementation ULKRotateDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
}

- (instancetype)initWithState:(ULKRotateDrawableConstantState *)state owner:(ULKRotateDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            ULKDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
            
            self.pivot = state.pivot;
            self.pivotXRelative = state.pivotXRelative;
            self.pivotYRelative = state.pivotYRelative;
            
            self.fromDegrees = self.currentDegrees = state.fromDegrees;
            self.toDegrees = state.toDegrees;
        } else {
            
        }
    }
    return self;
}

@end

@interface ULKRotateDrawable ()

@property (nonatomic, strong) ULKRotateDrawableConstantState *internalConstantState;

@end

@implementation ULKRotateDrawable


- (instancetype)initWithState:(ULKRotateDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKRotateDrawableConstantState *s = [[ULKRotateDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    ULKRotateDrawableConstantState *state = self.internalConstantState;
    CGRect bounds = self.bounds;
    
    // Calculate pivot point
    CGFloat px = state.pivotXRelative ? (bounds.size.width * state.pivot.x) : state.pivot.x;
    CGFloat py = state.pivotYRelative ? (bounds.size.height * state.pivot.y) : state.pivot.y;
    
    // Save context state
    CGContextSaveGState(context);
    
    // Rotate
    CGContextTranslateCTM(context, px, py);
    CGContextRotateCTM(context, state.currentDegrees*M_PI/180.f);
    CGContextTranslateCTM(context, -px, -py);
    
    // Draw child
    [state.drawable drawInContext:context];
    
    // Restore context state
    CGContextRestoreGState(context);
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    ULKRotateDrawableConstantState *state = self.internalConstantState;
    
    NSDictionary *attrs = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    
    CGPoint pivot = CGPointMake(0.5f, 0.5f);
    BOOL pivotXRelative = TRUE;
    BOOL pivotYRelative = TRUE;
    if ([attrs ulk_isFractionIDLValueForKey:@"pivotX"]) {
        pivot.x = [attrs ulk_fractionValueFromIDLValueForKey:@"pivotX"];
    } else if (attrs[@"pivotX"] != nil) {
        pivot.x = [attrs ulk_dimensionFromIDLValueForKey:@"pivotX" defaultValue:0.5f];
        pivotXRelative = FALSE;
    }
    if ([attrs ulk_isFractionIDLValueForKey:@"pivotY"]) {
        pivot.y = [attrs ulk_fractionValueFromIDLValueForKey:@"pivotY"];
    } else if (attrs[@"pivotY"] != nil) {
        pivot.y = [attrs ulk_dimensionFromIDLValueForKey:@"pivotY" defaultValue:0.5f];
        pivotYRelative = FALSE;
    }
    state.pivot = pivot;
    state.pivotXRelative = pivotXRelative;
    state.pivotYRelative = pivotYRelative;
    
    CGFloat fromDegrees = [attrs ulk_dimensionFromIDLValueForKey:@"fromDegrees" defaultValue:0.f];
    CGFloat toDegrees = [attrs ulk_dimensionFromIDLValueForKey:@"toDegrees" defaultValue:360.f];
    
    toDegrees = MAX(fromDegrees, toDegrees);
    state.fromDegrees = state.currentDegrees = fromDegrees;
    state.toDegrees = toDegrees;
    
    NSString *drawableResId = attrs[@"drawable"];
    ULKDrawable *drawable = nil;
    if (drawableResId != nil) {
        drawable = [[ULKResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
    } else if (element->firstChild != NULL) {
        drawable = [ULKDrawable createFromXMLElement:element->firstChild];
    } else {
        NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
    }
    if (drawable != nil) {
        drawable.delegate = self;
        drawable.state = self.state;
        state.drawable = drawable;
    }
    
}

- (void)onStateChangeToState:(UIControlState)state {
    [self.internalConstantState.drawable setState:state];
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    ULKRotateDrawableConstantState *state = self.internalConstantState;
    [state.drawable setLevel:level];
    state.currentDegrees = state.fromDegrees + (state.toDegrees - state.fromDegrees) * ((CGFloat)level / ULKDrawableMaxLevel);
    [self invalidateSelf];
    return TRUE;
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    self.internalConstantState.drawable.bounds = bounds;
}

- (BOOL)isStateful {
    return self.internalConstantState.drawable.isStateful;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.drawable.padding;
}

- (BOOL)hasPadding {
    return self.internalConstantState.drawable.hasPadding;
}

#pragma mark - ULKDrawableDelegate

- (void)drawableDidInvalidate:(ULKDrawable *)drawable {
    [self.delegate drawableDidInvalidate:self];
}

@end
