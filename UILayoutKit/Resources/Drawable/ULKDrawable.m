//
//  ULKDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 16.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKDrawable.h"
#import "ULKXMLCache.h"
#import "ULKStateListDrawable.h"
#import "ULKLayerDrawable.h"
#import "ULKColorDrawable.h"
#import "ULKInsetDrawable.h"
#import "ULKBitmapDrawable.h"
#import "ULKNinePatchDrawable.h"
#import "ULKGradientDrawable.h"
#import "ULKClipDrawable.h"
#import "ULKRotateDrawable.h"
#import "ULKShadowDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "ULKResourceManager+ULK_Internal.h"

NSUInteger const ULKDrawableMaxLevel = 10000;

@implementation ULKDrawableConstantState

@end

@interface ULKDrawable ()

@property (nonatomic, assign) BOOL stateInitialized;

@end

@implementation ULKDrawable

- (instancetype)initWithState:(ULKDrawableConstantState *)state {
    self = [super init];
    if (self) {

    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)onStateChangeToState:(UIControlState)state {
    
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    return FALSE;
}

- (CGSize)intrinsicSize {
    return CGSizeMake(-1, -1);
}

- (CGSize)minimumSize {
    CGSize size = self.intrinsicSize;
    size.width = MAX(size.width, 0);
    size.height = MAX(size.height, 0);
    return size;
}

- (void)drawInContext:(CGContextRef)context {
    OUTLINE_RECT(context, self.bounds);
}

#if OUTLINE_DRAWABLE
- (void)outlineRect:(CGRect)rect inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 1);
/*    CGFloat lengths[] = {5.f};
    CGContextSetLineDash(context, 1.f, lengths, 1);*/
    CGContextStrokeRect(context, rect);
    CGContextRestoreGState(context);
}
#endif

- (BOOL)isStateful {
    return FALSE;
}

- (void)invalidateSelf {
    [self.delegate drawableDidInvalidate:self];
}

- (UIImage *)renderToImage {
    UIGraphicsBeginImageContext(_bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    
}

- (BOOL)hasPadding {
    return FALSE;
}

- (UIEdgeInsets)padding {
    return UIEdgeInsetsZero;
}

- (void)setBounds:(CGRect)bounds {
    if (!CGRectEqualToRect(_bounds, bounds)) {
        _bounds = bounds;
        [self onBoundsChangeToRect:bounds];
    }
}

- (void)setState:(UIControlState)state {
    if (_state != state || !_stateInitialized) {
        _stateInitialized = TRUE;
        _state = state;
        [self onStateChangeToState:state];
    }
}

- (BOOL)setLevel:(NSUInteger)level {
    BOOL ret = FALSE;
    if (_level != level) {
        _level = level;
        ret = [self onLevelChangeToLevel:level];
    }
    return ret;
}

+ (ULKDrawable *)createFromXMLElement:(TBXMLElement *)element {
    ULKDrawable *drawable = nil;
    NSString *tagName = [TBXML elementName:element];
    Class drawableClass = NULL;
    if ([tagName isEqualToString:@"selector"]) {
        drawableClass = [ULKStateListDrawable class];
    } else if ([tagName isEqualToString:@"layer-list"]) {
        drawableClass = [ULKLayerDrawable class];
    } else if ([tagName isEqualToString:@"color"]) {
        drawableClass = [ULKColorDrawable class];
    } else if ([tagName isEqualToString:@"bitmap"]) {
        drawableClass = [ULKBitmapDrawable class];
    } else if ([tagName isEqualToString:@"inset"]) {
        drawableClass = [ULKInsetDrawable class];
    } else if ([tagName isEqualToString:@"nine-patch"]) {
        drawableClass = [ULKNinePatchDrawable class];
    } else if ([tagName isEqualToString:@"shape"]) {
        drawableClass = [ULKGradientDrawable class];
    } else if ([tagName isEqualToString:@"clip"]) {
        drawableClass = [ULKClipDrawable class];
    } else if ([tagName isEqualToString:@"rotate"]) {
        drawableClass = [ULKRotateDrawable class];
    } else if ([tagName isEqualToString:@"shadow"]) {
        drawableClass = [ULKShadowDrawable class];
    } else {
        drawableClass = NSClassFromString(tagName);
    }
    if (drawableClass != NULL && [drawableClass isSubclassOfClass:[ULKDrawable class]]) {
        drawable = [[drawableClass alloc] init];
        [drawable inflateWithElement:element];
    }
    return drawable;
}

+ (ULKDrawable *)createFromXMLData:(NSData *)data {
    if (data == nil) return nil;
    ULKDrawable *ret = nil;
    NSError *error = nil;
    TBXML *xml = [TBXML tbxmlWithXMLData:data error:&error];
    if (error == nil) {
        ret = [self createFromXMLElement:xml.rootXMLElement];
    } else {
        NSLog(@"Could not parse drawable: %@", error);
    }
    return ret;
}

+ (ULKDrawable *)createFromXMLURL:(NSURL *)url {
    NSError *error = nil;
    TBXML *xml = [[ULKResourceManager currentResourceManager].xmlCache xmlForUrl:url error:&error];
    ULKDrawable *ret = nil;
    if (xml == nil || error != nil) {
        NSLog(@"Could not parse drawable %@: %@", [url absoluteString], error);
    } else {
        ret = [self createFromXMLElement:xml.rootXMLElement];
    }
    return ret;
}

- (ULKDrawableConstantState *)constantState {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    ULKDrawableConstantState *state = self.constantState;
    if (state != nil) {
        return [[[self class] allocWithZone:zone] initWithState:state];
    } else {
        return nil;
    }
}

- (ULKDrawable *)currentDrawable {
    return self;
}

@end
