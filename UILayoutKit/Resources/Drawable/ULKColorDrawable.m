//
//  ULKColorDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKColorDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "ULKResourceManager.h"
#import "UIColor+ULK_ColorParser.h"

@interface ULKColorDrawableConstantState ()

@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithState:(ULKColorDrawableConstantState *)state;

@end

@interface ULKColorDrawable ()

@property (nonatomic, strong) ULKColorDrawableConstantState *internalConstantState;

@end

@implementation ULKColorDrawableConstantState


- (instancetype)initWithState:(ULKColorDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            self.color = state.color;
        } else {
            self.color = [UIColor clearColor];
        }
    }
    return self;
}

@end

@implementation ULKColorDrawable


- (instancetype)initWithState:(ULKColorDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKColorDrawableConstantState *s = [[ULKColorDrawableConstantState alloc] initWithState:state];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        ULKColorDrawableConstantState *state = [[ULKColorDrawableConstantState alloc] init];
        self.internalConstantState = state;
        self.internalConstantState.color = color;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    [self.internalConstantState.color set];
    CGContextFillRect(context, self.bounds);
    UIGraphicsPopContext();
    OUTLINE_RECT(context, self.bounds);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    NSString *colorString = attrs[@"color"];
    if (colorString != nil) {
        UIColor *color = [[ULKResourceManager currentResourceManager] colorForIdentifier:colorString];
        if (color == nil) {
            color = [UIColor ulk_colorFromIDLColorString:colorString];
        }
        self.internalConstantState.color = color;
    }
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

- (UIColor *)color {
    return self.internalConstantState.color;
}

@end
