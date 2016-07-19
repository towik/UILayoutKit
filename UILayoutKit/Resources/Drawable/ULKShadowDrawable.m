//
//  ULKShadowDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 15.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKShadowDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "NSDictionary+ULK_ResourceManager.h"

@interface ULKShadowDrawableConstantState ()

@property (nonatomic, strong) ULKDrawable *drawable;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGSize offset;
@property (nonatomic, assign) CGFloat blur;
@property (nonatomic, strong) UIColor *shadowColor;

@end

@implementation ULKShadowDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
}

- (instancetype)initWithState:(ULKShadowDrawableConstantState *)state owner:(ULKShadowDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            ULKDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
            
            self.alpha = state.alpha;
            self.blur = state.blur;
            self.offset = state.offset;
            self.shadowColor = state.shadowColor;
        } else {
            self.alpha = 1.f;
            
        }
    }
    return self;
}

@end

@interface ULKShadowDrawable ()

@property (nonatomic, strong) ULKShadowDrawableConstantState *internalConstantState;

@end

@implementation ULKShadowDrawable


- (instancetype)initWithState:(ULKShadowDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKShadowDrawableConstantState *s = [[ULKShadowDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    ULKShadowDrawableConstantState *state = self.internalConstantState;
    
    CGContextSetAlpha(context, state.alpha);
    if (state.shadowColor != nil) {
        CGContextSetShadowWithColor(context, state.offset, state.blur, state.shadowColor.CGColor);
    } else if (state.blur > 0 || !CGSizeEqualToSize(CGSizeZero, state.offset)) {
        CGContextSetShadow(context, state.offset, state.blur);
    }
    CGContextBeginTransparencyLayerWithRect(context, self.bounds, NULL);
    // Draw child
    [state.drawable drawInContext:context];
    CGContextEndTransparencyLayer(context);
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    ULKShadowDrawableConstantState *state = self.internalConstantState;
    
    NSDictionary *attrs = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    
    state.alpha = [attrs ulk_fractionValueFromIDLValueForKey:@"alpha" defaultValue:1];
    CGSize offset = CGSizeMake(0, 0);
    offset.width = [attrs ulk_dimensionFromIDLValueForKey:@"shadowHorizontalOffset" defaultValue:0];
    offset.height = [attrs ulk_dimensionFromIDLValueForKey:@"shadowVerticalOffset" defaultValue:0];
    state.offset = offset;
    
    state.blur = ABS([attrs ulk_dimensionFromIDLValueForKey:@"blur" defaultValue:0]);
    state.shadowColor = [attrs ulk_colorFromIDLValueForKey:@"shadowColor"];
    
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
    return [self.internalConstantState.drawable setLevel:level];
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    ULKShadowDrawableConstantState *state = self.internalConstantState;
    if (state.offset.width > 0) {
        bounds.size.width -= state.offset.width;
    } else if (state.offset.width < 0) {
        bounds.origin.x -= state.offset.width;
        bounds.size.width += state.offset.width;
    }
    
    if (state.offset.height > 0) {
        bounds.size.height -= state.offset.height;
    } else if (state.offset.width < 0) {
        bounds.origin.y -= state.offset.width;
        bounds.size.height += state.offset.height;
    }
    
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
