//
//  Gravity.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKGravity.h"

typedef struct Frame {
    CGFloat top;
    CGFloat left;
    CGFloat bottom;
    CGFloat right;
} Frame;

@implementation ULKGravity

+ (ULKViewContentGravity)gravityFromString:(NSString *)gravityString {
    ULKViewContentGravity ret = ULKViewContentGravityNone;
    if ([gravityString isEqualToString:@"top"]) {
        ret = ULKViewContentGravityTop;
    } else if ([gravityString isEqualToString:@"bottom"]) {
        ret = ULKViewContentGravityBottom;
    } else if ([gravityString isEqualToString:@"left"]) {
        ret = ULKViewContentGravityLeft;
    } else if ([gravityString isEqualToString:@"right"]) {
        ret = ULKViewContentGravityRight;
    } else if ([gravityString isEqualToString:@"center_vertical"]) {
        ret = ULKViewContentGravityCenterVertical;
    } else if ([gravityString isEqualToString:@"fill_vertical"]) {
        ret = ULKViewContentGravityFillVertical;
    } else if ([gravityString isEqualToString:@"center_horizontal"]) {
        ret = ULKViewContentGravityCenterHorizontal;
    } else if ([gravityString isEqualToString:@"fill_horizontal"]) {
        ret = ULKViewContentGravityFillHorizontal;
    } else if ([gravityString isEqualToString:@"center"]) {
        ret = ULKViewContentGravityCenter;
    } else if ([gravityString isEqualToString:@"fill"]) {
        ret = ULKViewContentGravityFill;
    }
    return ret;
}

+ (ULKViewContentGravity)gravityFromAttribute:(NSString *)gravityAttribute {
    ULKViewContentGravity ret = ULKViewContentGravityNone;
    if (gravityAttribute != nil) {
        NSArray *components = [gravityAttribute componentsSeparatedByString:@"|"];
        for (NSString *comp in components) {
            ret |= [ULKGravity gravityFromString:comp];
        }
    }
    return ret;
}

/**
 * Apply a gravity constant to an object.
 * 
 * @param gravity The desired placement of the object, as defined by the
 *                constants in this class.
 * @param w The horizontal size of the object.
 * @param h The vertical size of the object.
 * @param container The frame of the containing space, in which the object
 *                  will be placed.  Should be large enough to contain the
 *                  width and height of the object.
 * @param xAdj Offset to apply to the X axis.  If gravity is LEFT this
 *             pushes it to the right; if gravity is RIGHT it pushes it to
 *             the left; if gravity is CENTER_HORIZONTAL it pushes it to the
 *             right or left; otherwise it is ignored.
 * @param yAdj Offset to apply to the Y axis.  If gravity is TOP this pushes
 *             it down; if gravity is BOTTOM it pushes it up; if gravity is
 *             CENTER_VERTICAL it pushes it down or up; otherwise it is
 *             ignored.
 * @param outRect Receives the computed frame of the object in its
 *                container.
 */
+ (void)applyGravity:(ULKViewContentGravity)gravity width:(CGFloat)w height:(CGFloat)h containerRect:(CGRect *)containerCGRect xAdj:(CGFloat)xAdj yAdj:(CGFloat)yAdj outRect:(CGRect *)outCGRect {
    Frame container = {
        (*containerCGRect).origin.y,
        (*containerCGRect).origin.x,
        (*containerCGRect).origin.y + (*containerCGRect).size.height,
        (*containerCGRect).origin.x + (*containerCGRect).size.width
    };
    Frame outRect = {
        (*outCGRect).origin.y,
        (*outCGRect).origin.x,
        (*outCGRect).origin.y + (*outCGRect).size.height,
        (*outCGRect).origin.x + (*outCGRect).size.width
    };
    
    switch (gravity&((AXIS_PULL_BEFORE|AXIS_PULL_AFTER)<<AXIS_X_SHIFT)) {
        case 0:
            outRect.left = container.left
            + ((container.right - container.left - w)/2) + xAdj;
            outRect.right = outRect.left + w;
            if ((gravity&(AXIS_CLIP<<AXIS_X_SHIFT))
                == (AXIS_CLIP<<AXIS_X_SHIFT)) {
                if (outRect.left < container.left) {
                    outRect.left = container.left;
                }
                if (outRect.right > container.right) {
                    outRect.right = container.right;
                }
            }
            break;
        case AXIS_PULL_BEFORE<<AXIS_X_SHIFT:
            outRect.left = container.left + xAdj;
            outRect.right = outRect.left + w;
            if ((gravity&(AXIS_CLIP<<AXIS_X_SHIFT))
                == (AXIS_CLIP<<AXIS_X_SHIFT)) {
                if (outRect.right > container.right) {
                    outRect.right = container.right;
                }
            }
            break;
        case AXIS_PULL_AFTER<<AXIS_X_SHIFT:
            outRect.right = container.right - xAdj;
            outRect.left = outRect.right - w;
            if ((gravity&(AXIS_CLIP<<AXIS_X_SHIFT))
                == (AXIS_CLIP<<AXIS_X_SHIFT)) {
                if (outRect.left < container.left) {
                    outRect.left = container.left;
                }
            }
            break;
        default:
            outRect.left = container.left + xAdj;
            outRect.right = container.right + xAdj;
            break;
    }
    
    switch (gravity&((AXIS_PULL_BEFORE|AXIS_PULL_AFTER)<<AXIS_Y_SHIFT)) {
        case 0:
            outRect.top = container.top
            + ((container.bottom - container.top - h)/2) + yAdj;
            outRect.bottom = outRect.top + h;
            if ((gravity&(AXIS_CLIP<<AXIS_Y_SHIFT))
                == (AXIS_CLIP<<AXIS_Y_SHIFT)) {
                if (outRect.top < container.top) {
                    outRect.top = container.top;
                }
                if (outRect.bottom > container.bottom) {
                    outRect.bottom = container.bottom;
                }
            }
            break;
        case AXIS_PULL_BEFORE<<AXIS_Y_SHIFT:
            outRect.top = container.top + yAdj;
            outRect.bottom = outRect.top + h;
            if ((gravity&(AXIS_CLIP<<AXIS_Y_SHIFT))
                == (AXIS_CLIP<<AXIS_Y_SHIFT)) {
                if (outRect.bottom > container.bottom) {
                    outRect.bottom = container.bottom;
                }
            }
            break;
        case AXIS_PULL_AFTER<<AXIS_Y_SHIFT:
            outRect.bottom = container.bottom - yAdj;
            outRect.top = outRect.bottom - h;
            if ((gravity&(AXIS_CLIP<<AXIS_Y_SHIFT))
                == (AXIS_CLIP<<AXIS_Y_SHIFT)) {
                if (outRect.top < container.top) {
                    outRect.top = container.top;
                }
            }
            break;
        default:
            outRect.top = container.top + yAdj;
            outRect.bottom = container.bottom + yAdj;
            break;
    }
    
    (*outCGRect).origin = CGPointMake(outRect.left, outRect.top);
    (*outCGRect).size = CGSizeMake(outRect.right - outRect.left, outRect.bottom - outRect.top);
    (*containerCGRect).origin = CGPointMake(container.left, container.top);
    (*containerCGRect).size = CGSizeMake(container.right - container.left, container.bottom - container.top);
    
}

/**
 * Apply a gravity constant to an object. This suppose that the layout direction is LTR.
 * 
 * @param gravity The desired placement of the object, as defined by the
 *                constants in this class.
 * @param w The horizontal size of the object.
 * @param h The vertical size of the object.
 * @param container The frame of the containing space, in which the object
 *                  will be placed.  Should be large enough to contain the
 *                  width and height of the object.
 * @param outRect Receives the computed frame of the object in its
 *                container.
 */
+ (void)applyGravity:(ULKViewContentGravity)gravity width:(CGFloat)w height:(CGFloat)h containerRect:(CGRect *)container outRect:(CGRect *)outRect {
    [self applyGravity:gravity width:w height:h containerRect:container xAdj:0.f yAdj:0.f outRect:outRect];
}

@end
