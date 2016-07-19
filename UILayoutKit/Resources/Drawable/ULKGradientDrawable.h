//
//  ULKGradientDrawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKDrawable.h"

typedef NS_ENUM(NSInteger, ULKGradientDrawableShape) {
    ULKGradientDrawableShapeRectangle = 0,
    ULKGradientDrawableShapeOval,
    ULKGradientDrawableShapeLine,
    ULKGradientDrawableShapeRing
};

typedef NS_ENUM(NSInteger, ULKGradientDrawableGradientType) {
    ULKGradientDrawableGradientTypeNone = 0,
    ULKGradientDrawableGradientTypeLinear,
    ULKGradientDrawableGradientTypeRadial,
    ULKGradientDrawableGradientTypeSweep
};

typedef struct ULKGradientDrawableCornerRadius {
    CGFloat topLeft;
    CGFloat topRight;
    CGFloat bottomLeft;
    CGFloat bottomRight;
} ULKGradientDrawableCornerRadius;

UIKIT_EXTERN const ULKGradientDrawableCornerRadius ULKGradientDrawableCornerRadiusZero;

@interface ULKGradientDrawable : ULKDrawable

@end

@interface ULKGradientDrawableConstantState : ULKDrawableConstantState

@end
