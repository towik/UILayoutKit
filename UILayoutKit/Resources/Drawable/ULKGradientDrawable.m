//
//  ULKGradientDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKGradientDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "NSDictionary+ULK_ResourceManager.h"

ULKGradientDrawableShape ULKGradientDrawableShapeFromString(NSString *string) {
    ULKGradientDrawableShape ret = ULKGradientDrawableShapeRectangle;
    if ([string isEqualToString:@"rectangle"]) {
        ret = ULKGradientDrawableShapeRectangle;
    } else if ([string isEqualToString:@"oval"]) {
        ret = ULKGradientDrawableShapeOval;
    } else if ([string isEqualToString:@"line"]) {
        ret = ULKGradientDrawableShapeLine;
    } else if ([string isEqualToString:@"ring"]) {
        ret = ULKGradientDrawableShapeRing;
    }
    return ret;
}

ULKGradientDrawableGradientType ULKGradientDrawableGradientTypeFromString(NSString *string) {
    ULKGradientDrawableGradientType ret = ULKGradientDrawableGradientTypeNone;
    if ([string length] == 0 || [string isEqualToString:@"linear"]) {
        ret = ULKGradientDrawableGradientTypeLinear;
    } else if ([string isEqualToString:@"radial"]) {
        ret = ULKGradientDrawableGradientTypeRadial;
    } else if ([string isEqualToString:@"sweep"]) {
        ret = ULKGradientDrawableGradientTypeSweep;
    }
    return ret;
}

const ULKGradientDrawableCornerRadius ULKGradientDrawableCornerRadiusZero = {0,0,0,0};

BOOL ULKGradientDrawableCornerRadiusEqualsCornerRadius(ULKGradientDrawableCornerRadius r1, ULKGradientDrawableCornerRadius r2) {
    return r1.topLeft == r2.topLeft && r1.topRight == r2.topRight && r1.bottomLeft == r2.bottomLeft && r1.bottomRight == r2.bottomRight;
}

@interface ULKGradientDrawableConstantState ()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *cgColors;
@property (nonatomic, assign) CGFloat *colorPositions;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, assign) BOOL hasPadding;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat dashWidth;
@property (nonatomic, assign) CGFloat dashGap;

@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat innerRadiusRatio;
@property (nonatomic, assign) CGFloat thickness;
@property (nonatomic, assign) CGFloat thicknessRatio;

@property (nonatomic, assign) ULKGradientDrawableGradientType gradientType;
@property (nonatomic, assign) CGPoint relativeGradientCenter;
@property (nonatomic, assign) CGFloat gradientRadius;
@property (nonatomic, assign) BOOL gradientRadiusIsRelative;
@property (nonatomic, assign) ULKGradientDrawableShape shape;
@property (nonatomic, assign) ULKGradientDrawableCornerRadius corners;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat gradientAngle;

@property (nonatomic, assign) CGColorSpaceRef colorSpace;
@property (nonatomic, assign) CGGradientRef gradient;


@end

@implementation ULKGradientDrawableConstantState

- (void)dealloc {
    if (self.colorPositions != NULL) {
        free(self.colorPositions);
    }
    if (_colorSpace != NULL) {
        CGColorSpaceRelease(_colorSpace);
        _colorSpace = NULL;
    }
    if (_gradient != NULL) {
        CGGradientRelease(_gradient);
        _gradient = NULL;
    }
}

- (instancetype)initWithState:(ULKGradientDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            NSArray *colors = [[NSArray alloc] initWithArray:state.colors];
            self.colors = colors;
            
            if (state.colorPositions != NULL) {
                self.colorPositions = malloc([self.colors count] * sizeof(CGFloat));
                for (NSInteger i=0; i<[self.colors count]; i++) {
                    _colorPositions[i] = state.colorPositions[i];
                }
            }
        
            NSArray *cgColors = [[NSArray alloc] initWithArray:state.cgColors];
            self.cgColors = cgColors;
            self.padding = state.padding;
            self.hasPadding = state.hasPadding;
            self.strokeWidth = state.strokeWidth;
            self.strokeColor = state.strokeColor;
            self.dashWidth = state.dashWidth;
            self.dashGap = state.dashGap;
            
            self.innerRadius = state.innerRadius;
            self.innerRadiusRatio = state.innerRadiusRatio;
            self.thickness = state.thickness;
            self.thicknessRatio = state.thicknessRatio;
            
            self.shape = state.shape;
            self.corners = state.corners;
            self.size = state.size;
            self.gradientAngle = state.gradientAngle;
            _colorSpace = CGColorSpaceRetain(state.colorSpace);
            _gradient = CGGradientRetain(state.gradient);
            self.relativeGradientCenter = state.relativeGradientCenter;
            self.gradientRadius = state.gradientRadius;
            self.gradientRadiusIsRelative = state.gradientRadiusIsRelative;
            self.gradientType = state.gradientType;
        } else {
            _colorSpace = CGColorSpaceCreateDeviceRGB();
            _innerRadius = -1;
            _thickness = -1;
        }

    }
    return self;
}

- (NSArray *)cgColors {
    if (_cgColors == nil) {
        NSMutableArray *cgColors = [[NSMutableArray alloc] initWithCapacity:[self.colors count]];
        for (UIColor *c in self.colors) {
            CGColorRef cgColor = [c CGColor];
            if (cgColor != NULL) {
                [cgColors addObject:(__bridge id)cgColor];
            }
        }
        _cgColors = cgColors;
    }
    return _cgColors;
}

- (CGGradientRef)currentGradient {
    if (_gradient == NULL) {
        _gradient = CGGradientCreateWithColors(self.colorSpace, (CFArrayRef)self.cgColors, _colorPositions);
    }
    return _gradient;
}

@end

@interface ULKGradientDrawable ()

@property (nonatomic, strong) ULKGradientDrawableConstantState *internalConstantState;

@end

@implementation ULKGradientDrawable


- (instancetype)initWithState:(ULKGradientDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKGradientDrawableConstantState *s = [[ULKGradientDrawableConstantState alloc] initWithState:state];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)createPathInContext:(CGContextRef)context forRect:(CGRect)rect {
    ULKGradientDrawableConstantState *state = self.internalConstantState;
    ULKGradientDrawableCornerRadius corners = state.corners;
    CGContextBeginPath(context);
    switch (state.shape) {
        case ULKGradientDrawableShapeRectangle:
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + corners.topLeft);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - corners.bottomLeft);
            if (corners.bottomLeft > 0) {
                CGContextAddArc(context, rect.origin.x + corners.bottomLeft, rect.origin.y + rect.size.height - corners.bottomLeft, corners.bottomLeft, (CGFloat) M_PI, (CGFloat) (M_PI / 2), true);
            }
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - corners.bottomRight, rect.origin.y + rect.size.height);
            if (corners.bottomRight > 0) {
                CGContextAddArc(context, rect.origin.x + rect.size.width - corners.bottomRight, rect.origin.y + rect.size.height - corners.bottomRight, corners.bottomRight, (CGFloat) (M_PI / 2), 0.0f, true);
            }
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + corners.topRight);
            if (corners.topRight > 0) {
                CGContextAddArc(context, rect.origin.x + rect.size.width - corners.topRight, rect.origin.y + corners.topRight, corners.topRight, 0.0f, (CGFloat) (-M_PI / 2), true);
            }
            CGContextAddLineToPoint(context, rect.origin.x + corners.topLeft, rect.origin.y);
            if (corners.topLeft > 0) {
                CGContextAddArc(context, rect.origin.x + corners.topLeft, rect.origin.y + corners.topLeft, corners.topLeft, (CGFloat) (- M_PI / 2), (CGFloat) M_PI, true);
            }
            CGContextClosePath(context);
            break;
        case ULKGradientDrawableShapeOval:
            CGContextAddEllipseInRect(context, rect);
            break;
        case ULKGradientDrawableShapeRing: {
            CGFloat thickness = state.thickness != -1 ? state.thickness : rect.size.width / state.thicknessRatio;
            // inner radius
            CGFloat radius = state.innerRadius != -1 ? state.innerRadius : rect.size.width / state.innerRadiusRatio;
            CGFloat x = rect.size.width/2.f;
            CGFloat y = rect.size.height/2.f;
            CGRect innerRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(y - radius, x - radius, y - radius, x - radius));
            //rect = UIEdgeInsetsInsetRect(innerRect, UIEdgeInsetsMake(-thickness, -thickness, -thickness, -thickness));
            
            CGRect r = UIEdgeInsetsInsetRect(innerRect, UIEdgeInsetsMake(-thickness/2, -thickness/2, -thickness/2, -thickness/2));
            CGContextSetLineWidth(context, thickness);
            CGContextAddEllipseInRect(context, r);
            CGContextReplacePathWithStrokedPath(context);
            break;
        }
        case ULKGradientDrawableShapeLine: {
            CGFloat y = CGRectGetMidY(rect);
            CGContextMoveToPoint(context, rect.origin.x, y);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, y);
            break;
        }
        default:
            break;
    }
}

- (void)drawInContext:(CGContextRef)context {
    CGRect rect = self.bounds;
    ULKGradientDrawableConstantState *state = self.internalConstantState;
    if (state.shape != ULKGradientDrawableShapeLine) {
        if ([state.colors count] == 1) {
            [self createPathInContext:context forRect:rect];
            CGContextSetFillColorWithColor(context, [state.colors[0] CGColor]);
            CGContextDrawPath(context, kCGPathFill);
        } else if ([state.colors count] > 1) {
            [self createPathInContext:context forRect:rect];
            CGContextSaveGState(context);
            CGContextClip(context);
            
            if (state.gradientType == ULKGradientDrawableGradientTypeLinear) {
                CGGradientRef gradient = [state currentGradient];
                float cos = cosf(state.gradientAngle);
                float sin = sinf(state.gradientAngle);
                CGFloat halfWidth = CGRectGetWidth(rect)/2.f;
                CGFloat halfHeight = CGRectGetHeight(rect)/2.f;
                CGPoint startPoint = CGPointMake(rect.origin.x + halfWidth - cos * halfWidth, rect.origin.y + halfHeight + sin * halfHeight);
                CGPoint endPoint = CGPointMake(rect.origin.x + halfWidth + cos * halfWidth, rect.origin.y + halfHeight - sin * halfHeight);
                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
            } else if (state.gradientType == ULKGradientDrawableGradientTypeRadial) {
                CGGradientRef gradient = [state currentGradient];
                CGPoint relativeCenterPoint = state.relativeGradientCenter;
                CGPoint centerPoint = CGPointMake(rect.origin.x + rect.size.width * relativeCenterPoint.x, rect.origin.y + rect.size.height * relativeCenterPoint.y);
                CGFloat radius = state.gradientRadius;
                if (state.gradientRadiusIsRelative) {
                    radius *= MIN(rect.size.width, rect.size.height);
                }
                CGContextDrawRadialGradient(context, gradient, centerPoint, 0, centerPoint, radius, kCGGradientDrawsAfterEndLocation);
            } else if (state.gradientType == ULKGradientDrawableGradientTypeSweep) {
                float dim = MIN(self.bounds.size.width, self.bounds.size.height);
                int subdiv=512;
                float r=dim/4;
                float R=dim/2;
                
                CGFloat halfinteriorPerim = (CGFloat) (M_PI*r);
                CGFloat halfexteriorPerim = (CGFloat) (M_PI*R);
                CGFloat smallBase= halfinteriorPerim/subdiv;
                CGFloat largeBase= halfexteriorPerim/subdiv;

                UIBezierPath *cell = [UIBezierPath bezierPath];
                CGContextMoveToPoint(context, - smallBase/2, r);
                CGContextAddLineToPoint(context, + smallBase/2, r);
                CGContextAddLineToPoint(context, largeBase /2 , R);
                CGContextAddLineToPoint(context, -largeBase /2,  R);
                CGContextClosePath(context);

                CGFloat incr = (CGFloat) (M_PI / subdiv);
                CGContextRef ctx = context;
                CGContextTranslateCTM(ctx, +self.bounds.size.width/2, +self.bounds.size.height/2);
                
                CGContextScaleCTM(ctx, 0.9, 0.9);
                CGContextRotateCTM(ctx, (CGFloat) (M_PI/2));
                CGContextRotateCTM(ctx,-incr/2);
                
                for (int i=0;i<subdiv;i++) {
                    // replace this color with a color extracted from your gradient object
                    
                    [cell fill];
                    [cell stroke];
                    CGContextRotateCTM(ctx, -incr);
                }
            }
            CGContextRestoreGState(context);
        }
    }
    BOOL drawStroke = state.strokeWidth > 0 && state.strokeColor != nil;
    if (drawStroke) {
        [self createPathInContext:context forRect:rect];
        CGContextSetLineWidth(context, state.strokeWidth);
        if (state.dashWidth > 0.f) {
            CGFloat lengths[2] = {state.dashWidth, state.dashGap};
            CGContextSetLineDash(context, 0, lengths, 2);
        }
        CGContextSetStrokeColorWithColor(context, [state.strokeColor CGColor]);
        CGContextStrokePath(context);
    }
    OUTLINE_RECT(context, rect);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    ULKGradientDrawableConstantState *state = self.internalConstantState;
    NSMutableDictionary *attrs = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    NSString *shape = attrs[@"shape"];
    state.shape = ULKGradientDrawableShapeFromString(shape);
    
    if (state.shape == ULKGradientDrawableShapeRing) {
        state.innerRadius = [attrs ulk_dimensionFromIDLValueForKey:@"innerRadius" defaultValue:-1];
        if (state.innerRadius == -1) {
            state.innerRadiusRatio = [attrs ulk_dimensionFromIDLValueForKey:@"innerRadiusRatio" defaultValue:3];
        }
        state.thickness = [attrs ulk_dimensionFromIDLValueForKey:@"thickness" defaultValue:-1];
        if (state.thickness == -1) {
            state.thicknessRatio = [attrs ulk_dimensionFromIDLValueForKey:@"thicknessRatio" defaultValue:9];
        }
    }
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *name = [TBXML elementName:child];
        if ([name isEqualToString:@"gradient"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            
            state.gradientType = ULKGradientDrawableGradientTypeFromString(attrs[@"type"]);
            
            CGPoint gradientCenter = CGPointMake(.5f, .5f);
            NSString *centerX = attrs[@"centerX"];
            if (centerX != nil) {
                gradientCenter.x = [centerX floatValue];
            }
            NSString *centerY = attrs[@"centerY"];
            if (centerY != nil) {
                gradientCenter.y = [centerY floatValue];
            }
            
            if (state.gradientType == ULKGradientDrawableGradientTypeRadial) {
                
                if (attrs[@"gradientRadius"] == nil) {
                    state.gradientRadius = 1;
                    state.gradientRadiusIsRelative = TRUE;
                } else {
                    if ([attrs ulk_isFractionIDLValueForKey:@"gradientRadius"]) {
                        state.gradientRadiusIsRelative = TRUE;
                        state.gradientRadius = [attrs ulk_fractionValueFromIDLValueForKey:@"gradientRadius"];
                    } else {
                        state.gradientRadiusIsRelative = FALSE;
                        state.gradientRadius = [attrs ulk_dimensionFromIDLValueForKey:@"gradientRadius"];
                    }
                }
                
                state.relativeGradientCenter = gradientCenter;
            }
            else if (state.gradientType == ULKGradientDrawableGradientTypeLinear)
            {
                state.gradientAngle = (CGFloat) ([attrs[@"angle"] doubleValue] * M_PI / 180.f);
            }
            
            
            UIColor *startColor = [attrs ulk_colorFromIDLValueForKey:@"startColor"];
            UIColor *centerColor = [attrs ulk_colorFromIDLValueForKey:@"centerColor"];
            UIColor *endColor = [attrs ulk_colorFromIDLValueForKey:@"endColor"];
            if (centerColor != nil) {
                state.colors = @[startColor?startColor:[UIColor blackColor], centerColor, endColor?endColor:[UIColor blackColor]];
                if (state.gradientType == ULKGradientDrawableGradientTypeLinear) {
                    state.colorPositions = malloc(sizeof(CGFloat)*3);
                    state.colorPositions[0] = 0.f;
                    // Since 0.5f is default value, try to take the one that isn't 0.5f
                    state.colorPositions[1] = gradientCenter.x != .5f ? gradientCenter.x : gradientCenter.y;
                    state.colorPositions[2] = 1.f;
                }
            } else {
                state.colors = @[startColor?startColor:[UIColor blackColor], endColor?endColor:[UIColor blackColor]];
            }

            
        } else if ([name isEqualToString:@"padding"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            UIEdgeInsets padding = UIEdgeInsetsZero;
            padding.left = [attrs[@"left"] floatValue];
            padding.top = [attrs[@"top"] floatValue];
            padding.right = [attrs[@"right"] floatValue];
            padding.bottom = [attrs[@"bottom"] floatValue];
            state.padding = padding;
            state.hasPadding = TRUE;
        } else if ([name isEqualToString:@"corners"]) {
            ULKGradientDrawableCornerRadius radius =  ULKGradientDrawableCornerRadiusZero;
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            radius.topLeft = radius.topRight = radius.bottomLeft = radius.bottomRight = [attrs[@"radius"] floatValue];
            NSString *topLeftRadius = attrs[@"topLeftRadius"];
            NSString *topRightRadius = attrs[@"topRightRadius"];
            NSString *bottomLeftRadius = attrs[@"bottomLeftRadius"];
            NSString *bottomRightRadius = attrs[@"bottomRightRadius"];
            if (topLeftRadius != nil) radius.topLeft = [topLeftRadius floatValue];
            if (topRightRadius != nil) radius.topRight = [topRightRadius floatValue];
            if (bottomLeftRadius != nil) radius.bottomLeft = [bottomLeftRadius floatValue];
            if (bottomRightRadius != nil) radius.bottomRight = [bottomRightRadius floatValue];
            state.corners = radius;
        } else if ([name isEqualToString:@"solid"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            UIColor *color = [attrs ulk_colorFromIDLValueForKey:@"color"];
            if (color == nil) {
                color = [UIColor blackColor];
            }
            state.colors = @[color];
        } else if ([name isEqualToString:@"size"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            CGSize size = CGSizeZero;
            size.width = [attrs ulk_dimensionFromIDLValueForKey:@"width" defaultValue:-1.f];
            size.height = [attrs ulk_dimensionFromIDLValueForKey:@"height" defaultValue:-1.f];
            state.size = size;
        } else if ([name isEqualToString:@"stroke"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            state.strokeWidth = [attrs ulk_dimensionFromIDLValueForKey:@"width"];
            state.strokeColor = [attrs ulk_colorFromIDLValueForKey:@"color"];
            state.dashWidth = [attrs ulk_dimensionFromIDLValueForKey:@"dashWidth"];
            if (state.dashWidth != 0.f) {
                state.dashGap = [attrs ulk_dimensionFromIDLValueForKey:@"dashGap"];
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

- (CGSize)intrinsicSize {
    return self.internalConstantState.size;
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

@end
