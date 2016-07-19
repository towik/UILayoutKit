//
//  UIView+ULKDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIView+ULKDrawable.h"
#import "UIView+ULK_Layout.h"
#import "NSObject+ULK_KVOObserver.h"
#import "ULKDrawableLayer.h"
#include <objc/runtime.h>

@interface ULKBackgroundDrawableLayer : CALayer

@end

@implementation ULKBackgroundDrawableLayer

@end

@interface UIView ()

@property (nonatomic, readonly) NSMutableDictionary *observerHacks;

@end

@implementation UIView (ULKDrawable)

static char backgroundDrawableKey;

- (void)setUlk_backgroundDrawable:(ULKDrawable *)backgroundDrawable {
    objc_setAssociatedObject(self,
                             &backgroundDrawableKey,
                             backgroundDrawable,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (backgroundDrawable.hasPadding) {
        self.ulk_padding = backgroundDrawable.padding;
    }
    [self ulk_onBackgroundDrawableChanged];
}

- (ULKDrawable *)ulk_backgroundDrawable {
    return objc_getAssociatedObject(self, &backgroundDrawableKey);
}

- (void)ulk_onBackgroundDrawableChanged {
    ULKDrawableLayer *existingBackgroundLayer = nil;
    CALayer *layer = self.layer;
    for (CALayer *sublayer in layer.sublayers) {
        if ([sublayer isKindOfClass:[ULKDrawableLayer class]]) {
            existingBackgroundLayer = (ULKDrawableLayer *)sublayer;
            break;
        }
    }
    ULKDrawable *drawable = self.ulk_backgroundDrawable;
    drawable.bounds = self.bounds;
    static NSString *BackgroundDrawableFrameTag = @"backgroundDrawableFrame";
    static NSString *BackgroundDrawableStateTag = @"backgroundDrawableState";
    if (drawable != nil) {
        if ([self isKindOfClass:[UIControl class]]) {
            UIControl *control = (UIControl *)self;
            drawable.state = control.state;
        } else {
            drawable.state = UIControlStateNormal;
        }
        if (existingBackgroundLayer == nil) {
            existingBackgroundLayer = [[ULKDrawableLayer alloc] init];
            [self.layer insertSublayer:existingBackgroundLayer atIndex:0];
        }
        existingBackgroundLayer.drawable = drawable;
        existingBackgroundLayer.frame = self.bounds;
        [existingBackgroundLayer setNeedsDisplay];
        
        if (![self ulk_hasObserverWithIdentifier:BackgroundDrawableFrameTag]) {
            __weak UIView *selfRef = self;
            __weak ULKDrawableLayer *layer = existingBackgroundLayer;
            [self ulk_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
                layer.frame = selfRef.bounds;
            } withIdentifier:BackgroundDrawableFrameTag forKeyPaths:@[@"frame"] options:NSKeyValueObservingOptionNew];
            
            if ([self isKindOfClass:[UIControl class]] && ![self ulk_hasObserverWithIdentifier:BackgroundDrawableStateTag]) {
                [self ulk_addObserver:^(NSString *keyPath, id object, NSDictionary *change) {
                    selfRef.ulk_backgroundDrawable.state = ((UIControl *)selfRef).state;
                } withIdentifier:BackgroundDrawableStateTag forKeyPaths:@[@"highlighted", @"enabled", @"selected"] options:NSKeyValueObservingOptionNew];
            }
        }
    } else {
        [self ulk_removeObserverWithIdentifier:BackgroundDrawableFrameTag];
        [self ulk_removeObserverWithIdentifier:BackgroundDrawableStateTag];
        [existingBackgroundLayer removeFromSuperlayer];
    }
}

@end
