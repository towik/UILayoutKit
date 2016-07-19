//
//  ULKDrawable+ULK_Internal.h
//  UILayoutKit
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UILayoutKit.h"
#import "TBXML.h"

#if OUTLINE_DRAWABLE
#define OUTLINE_RECT(context, rect) [self outlineRect:rect inContext:context]
#else
#define OUTLINE_RECT(context, rect) 
#endif

@interface ULKDrawable (ULK_Internal)

- (instancetype)initWithState:(ULKDrawableConstantState *)state;

- (void)inflateWithElement:(TBXMLElement *)element;
+ (ULKDrawable *)createFromXMLElement:(TBXMLElement *)element;
- (void)outlineRect:(CGRect)rect inContext:(CGContextRef)context;
- (void)onBoundsChangeToRect:(CGRect)bounds;
- (void)onStateChangeToState:(UIControlState)state;
- (BOOL)onLevelChangeToLevel:(NSUInteger)level;
- (void)invalidateSelf;

@end
