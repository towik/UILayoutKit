//
//  UIView+ULK_ViewGroup.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UIView+ULK_ViewGroup.h"
#import "ULKLayoutParams.h"

@implementation UIView (ULK_ViewGroup)

- (ULKLayoutParams *)ulk_generateDefaultLayoutParams {
    return [[ULKLayoutParams alloc] initWithWidth:ULKLayoutParamsSizeWrapContent height:ULKLayoutParamsSizeWrapContent];
}

- (ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)lp {
    return lp;
}

- (ULKLayoutParams *)ulk_generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[ULKLayoutParams alloc] initUlk_WithAttributes:attrs];
}

- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams {
    return  layoutParams != nil;
}

- (BOOL)ulk_isViewGroup {
    return FALSE;
}

- (ULKLayoutMeasureSpec)ulk_childMeasureSpecWithMeasureSpec:(ULKLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension {
    ULKLayoutMeasureSpecMode specMode = spec.mode;
    CGFloat specSize = spec.size;
    
    CGFloat size = MAX(0, specSize - padding);
    
    ULKLayoutMeasureSpec result;
    result.size = 0;
    result.mode = ULKLayoutMeasureSpecModeUnspecified;
    
    switch (specMode) {
            // Parent has imposed an exact size on us
        case ULKLayoutMeasureSpecModeExactly:
            if (childDimension >= 0) {
                result.size = childDimension;
                result.mode = ULKLayoutMeasureSpecModeExactly;
            } else if (childDimension == ULKLayoutParamsSizeMatchParent) {
                // Child wants to be our size. So be it.
                result.size = size;
                result.mode = ULKLayoutMeasureSpecModeExactly;
            } else if (childDimension == ULKLayoutParamsSizeWrapContent) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                result.size = size;
                result.mode = ULKLayoutMeasureSpecModeAtMost;
            }
            break;
            
            // Parent has imposed a maximum size on us
        case ULKLayoutMeasureSpecModeAtMost:
            if (childDimension >= 0) {
                // Child wants a specific size... so be it
                result.size = childDimension;
                result.mode = ULKLayoutMeasureSpecModeExactly;
            } else if (childDimension == ULKLayoutParamsSizeMatchParent) {
                // Child wants to be our size, but our size is not fixed.
                // Constrain child to not be bigger than us.
                result.size = size;
                result.mode = ULKLayoutMeasureSpecModeAtMost;
            } else if (childDimension == ULKLayoutParamsSizeWrapContent) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                result.size = size;
                result.mode = ULKLayoutMeasureSpecModeAtMost;
            }
            break;
            
            // Parent asked to see how big we want to be
        case ULKLayoutMeasureSpecModeUnspecified:
            if (childDimension >= 0) {
                // Child wants a specific size... let him have it
                result.size = childDimension;
                result.mode = ULKLayoutMeasureSpecModeExactly;
            } else if (childDimension == ULKLayoutParamsSizeMatchParent) {
                // Child wants to be our size... find out how big it should
                // be
                result.size = 0;
                result.mode = ULKLayoutMeasureSpecModeUnspecified;
            } else if (childDimension == ULKLayoutParamsSizeWrapContent) {
                // Child wants to determine its own size.... find out how
                // big it should be
                result.size = 0;
                result.mode = ULKLayoutMeasureSpecModeUnspecified;
            }
            break;
    }
    return result;
}

- (void)ulk_measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed {
    ULKLayoutParams *lp = (ULKLayoutParams *) child.layoutParams;
    UIEdgeInsets lpMargin = lp.margin;
    UIEdgeInsets padding = self.ulk_padding;
    ULKLayoutMeasureSpec childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:padding.left + padding.right + lpMargin.left + lpMargin.right + widthUsed childDimension:lp.width];
    ULKLayoutMeasureSpec childHeightMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentHeightMeasureSpec padding:padding.top + padding.bottom + lpMargin.top + lpMargin.bottom + heightUsed childDimension:lp.height];
    
    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

/**
 * Ask one of the children of this view to measure itself, taking into
 * account both the MeasureSpec requirements for this view and its padding.
 * The heavy lifting is done in getChildMeasureSpec.
 *
 * @param child The child to measure
 * @param parentWidthMeasureSpec The width requirements for this view
 * @param parentHeightMeasureSpec The height requirements for this view
 */
-(void)ulk_measureChild:(UIView *)child withParentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec {
    ULKLayoutParams *lp = child.layoutParams;
    UIEdgeInsets padding = self.ulk_padding;
    ULKLayoutMeasureSpec childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:(padding.left + padding.right) childDimension:lp.width];
    ULKLayoutMeasureSpec childHeightMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentHeightMeasureSpec padding:(padding.top + padding.bottom) childDimension:lp.height];
    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (UIView *)ulk_findViewTraversal:(NSString *)identifier {
    if ([self.ulk_identifier isEqualToString:identifier]) {
        return self;
    }
    
    NSArray *where = self.subviews;
    NSInteger len = [where count];
    
    for (NSInteger i = 0; i < len; i++) {
        UIView *v = where[i];
        
        v = [v ulk_findViewById:identifier];
        if (v != nil) {
            return v;
        }
    }
    return nil;
}

- (void)ulk_addView:(UIView *)child {
    ULKLayoutParams *params = child.layoutParams;
    if (params == nil) {
        params = [self ulk_generateDefaultLayoutParams];
        if (params == nil) {
            @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:@"ulk_generateDefaultLayoutParams() cannot return nil" userInfo:nil];
        }
    }
    
    if (!self.ulk_isViewGroup) {
        @throw [NSException exceptionWithName:@"UnsuportedOperationException" reason:@"Views can only be added on ViewGroup objects" userInfo:nil];
    }
    if (![self ulk_checkLayoutParams:params]) {
        if (params != nil) {
            params = [self ulk_generateLayoutParamsFromLayoutParams:params];
        }
        if (params == nil || ![self ulk_checkLayoutParams:params]) {
            params = [self ulk_generateDefaultLayoutParams];
        }
    }
    child.layoutParams = params;
    [self addSubview:child];

    [self ulk_requestLayout];
}

- (void)ulk_removeView:(UIView *)view {
    if (!self.ulk_isViewGroup) {
        @throw [NSException exceptionWithName:@"UnsuportedOperationException" reason:@"Views can only be removed from ViewGroup objects" userInfo:nil];
    }
    if (view.superview == self) {
        [view removeFromSuperview];
    }
    
    [self ulk_requestLayout];
    [self setNeedsDisplay];
}

@end
