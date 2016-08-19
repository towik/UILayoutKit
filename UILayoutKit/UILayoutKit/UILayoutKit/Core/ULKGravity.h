//
//  Gravity.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define AXIS_SPECIFIED 0x0001
#define AXIS_PULL_BEFORE 0x0002
#define AXIS_PULL_AFTER 0x0004
#define AXIS_CLIP 0x0008
#define AXIS_X_SHIFT 0
#define AXIS_Y_SHIFT 4
#define HORIZONTAL_GRAVITY_MASK (AXIS_SPECIFIED | AXIS_PULL_BEFORE | AXIS_PULL_AFTER) << AXIS_X_SHIFT
#define VERTICAL_GRAVITY_MASK  (AXIS_SPECIFIED | AXIS_PULL_BEFORE | AXIS_PULL_AFTER) << AXIS_Y_SHIFT
#define RELATIVE_HORIZONTAL_GRAVITY_MASK (ULKGravityLeft | ULKGravityRight)
#define DEFAULT_CHILD_GRAVITY ULKGravityTop | ULKGravityLeft

typedef NS_OPTIONS(NSInteger, ULKGravity) {
    ULKGravityNone = 0x0000,
    ULKGravityTop = (AXIS_PULL_BEFORE|AXIS_SPECIFIED)<<AXIS_Y_SHIFT,
    ULKGravityBottom = (AXIS_PULL_AFTER|AXIS_SPECIFIED)<<AXIS_Y_SHIFT,
    ULKGravityLeft = (AXIS_PULL_BEFORE|AXIS_SPECIFIED)<<AXIS_X_SHIFT,
    ULKGravityRight = (AXIS_PULL_AFTER|AXIS_SPECIFIED)<<AXIS_X_SHIFT,
    ULKGravityCenterVertical = AXIS_SPECIFIED<<AXIS_Y_SHIFT,
    ULKGravityFillVertical = ULKGravityTop|ULKGravityBottom,
    ULKGravityCenterHorizontal = AXIS_SPECIFIED<<AXIS_X_SHIFT,
    ULKGravityFillHorizontal = ULKGravityLeft|ULKGravityRight,
    ULKGravityCenter = ULKGravityCenterVertical|ULKGravityCenterHorizontal,
    ULKGravityFill = ULKGravityFillVertical|ULKGravityFillHorizontal
};

@interface ULKGravityUtility : NSObject

+ (ULKGravity)gravityFromAttribute:(NSString *)gravityAttribute;
+ (void)applyGravity:(ULKGravity)gravity width:(CGFloat)w height:(CGFloat)h containerRect:(CGRect *)containerCGRect xAdj:(CGFloat)xAdj yAdj:(CGFloat)yAdj outRect:(CGRect *)outCGRect;
+ (void)applyGravity:(ULKGravity)gravity width:(CGFloat)w height:(CGFloat)h containerRect:(CGRect *)container outRect:(CGRect *)outRect;

@end
