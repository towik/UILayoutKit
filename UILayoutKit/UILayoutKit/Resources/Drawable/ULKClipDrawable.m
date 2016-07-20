//
//  ULKClipDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 07.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKClipDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "ULKGravity.h"

ULKClipDrawableOrientation ULKClipDrawableOrientationFromString(NSString *string) {
    ULKClipDrawableOrientation ret = ULKClipDrawableOrientationHorizontal;
    if ([string isEqualToString:@"vertical"]) {
        ret = ULKClipDrawableOrientationVertical;
    }
    return ret;
}

@interface ULKClipDrawableConstantState ()

@property (nonatomic, strong) ULKDrawable *drawable;
@property (nonatomic, assign) ULKClipDrawableOrientation orientation;
@property (nonatomic, assign) ULKViewContentGravity gravity;

@end

@implementation ULKClipDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
}

- (instancetype)initWithState:(ULKClipDrawableConstantState *)state owner:(ULKClipDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            ULKDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
            
            self.orientation = state.orientation;
            self.gravity = state.gravity;
        } else {
            self.gravity = ULKViewContentGravityLeft;
        }
    }
    return self;
}

@end

@interface ULKClipDrawable ()

@property (nonatomic, strong) ULKClipDrawableConstantState *internalConstantState;

@end

@implementation ULKClipDrawable


- (instancetype)initWithState:(ULKClipDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKClipDrawableConstantState *s = [[ULKClipDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    NSUInteger level = self.level;
    if (level > 0) {
        ULKClipDrawableConstantState *state = self.internalConstantState;
        ULKClipDrawableOrientation orientation = state.orientation;
        CGRect r = CGRectZero;
        CGRect bounds = self.bounds;
        CGFloat w = bounds.size.width;
        CGFloat iw = 0; //mClipState.mDrawable.getIntrinsicWidth();
        if ((orientation & ULKClipDrawableOrientationHorizontal) != 0) {
            w -= (w - iw) * (10000 - level) / 10000;
        }
        int h = bounds.size.height;
        CGFloat ih = 0; //mClipState.mDrawable.getIntrinsicHeight();
        if ((orientation & ULKClipDrawableOrientationVertical) != 0) {
            h -= (h - ih) * (10000 - level) / 10000;
        }
        [ULKGravity applyGravity:state.gravity width:w height:h containerRect:&bounds outRect:&r];
        if (w > 0 && h > 0) {
            CGContextSaveGState(context);
            CGContextClipToRect(context, r);
            [state.drawable drawInContext:context];
            CGContextRestoreGState(context);
        }
    }
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    ULKClipDrawableConstantState *state = self.internalConstantState;
    
    NSDictionary *attrs = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    NSString *orientationString = attrs[@"clipOrientation"];
    state.orientation = ULKClipDrawableOrientationFromString(orientationString);
    
    NSString *gravityString = attrs[@"gravity"];
    if (gravityString != nil) {
        state.gravity = [ULKGravity gravityFromAttribute:gravityString];
    }
    
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
    [self.internalConstantState.drawable setLevel:level];
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
