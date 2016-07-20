//
//  ULKDrawableLayer.m
//  UILayoutKit
//
//  Created by Tom Quist on 30.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawableLayer.h"

@implementation ULKDrawableLayer

- (void)dealloc {
    self.drawable = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.needsDisplayOnBoundsChange = TRUE;
        //self.contentsGravity = kCAGravityTop;
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], kCAOnOrderIn,
                                           [NSNull null], kCAOnOrderOut,
                                           [NSNull null], @"sublayers",
                                           [NSNull null], @"contents",
                                           nil];
        self.actions = newActions;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.needsDisplayOnBoundsChange = TRUE;
        //self.contentsGravity = kCAGravityTop;
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], kCAOnOrderIn,
                                           [NSNull null], kCAOnOrderOut,
                                           [NSNull null], @"sublayers",
                                           [NSNull null], @"contents",
                                           nil];
        self.actions = newActions;
    }
    return self;
}

- (id<CAAction>)actionForKey:(NSString *)event {
    return nil;
}

- (instancetype)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        ULKDrawableLayer *l = layer;
        self.drawable = [l.drawable copy];
        self.drawable.delegate = self;
        self.drawable.level = l.drawable.level;
        self.drawable.bounds = l.drawable.bounds;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:@"drawable"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void)setDrawable:(ULKDrawable *)drawable {
    if (_drawable != drawable) {
        _drawable.delegate = nil;
        _drawable = drawable;
        _drawable.delegate = self;
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    [self.drawable drawInContext:ctx];
}

- (void)drawableDidInvalidate:(ULKDrawable *)drawable {
    [self setNeedsDisplay];
}

- (void)layoutSublayers {
    [super layoutSublayers];
    self.drawable.bounds = self.bounds;
}

@end
