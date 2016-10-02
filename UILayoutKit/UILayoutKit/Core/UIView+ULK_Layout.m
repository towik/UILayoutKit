//
//  UIView+ULK.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ULKViewGroup.h"

#pragma mark - import libs
#include <objc/runtime.h>

#pragma mark -



@implementation ULKLayoutParams

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height {
    self = [super init];
    if (self) {
        _width = width;
        _height = height;
    }
    return self;
}

- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams {
    self = [super init];
    if (self) {
        _width = layoutParams.width;
        _height = layoutParams.height;
        _margin = layoutParams.margin;
    }
    return self;
}

@end


@implementation UIView (ULK_Layout)

- (ULKLayoutMeasuredDimension)ulk_defaultSizeForSize:(CGFloat)size measureSpec:(ULKLayoutMeasureSpec)measureSpec {
    CGFloat result = size;
    ULKLayoutMeasureSpecMode specMode = measureSpec.mode;
    CGFloat specSize = measureSpec.size;
    
    switch (specMode) {
        case ULKLayoutMeasureSpecModeUnspecified:
            result = size;
            break;
        case ULKLayoutMeasureSpecModeAtMost:
        case ULKLayoutMeasureSpecModeExactly:
            result = specSize;
            break;
    }
    ULKLayoutMeasuredDimension ret = {result, ULKLayoutMeasuredStateNone};
    return ret;
}

+ (ULKLayoutMeasuredWidthHeightState)ulk_combineMeasuredStatesCurrentState:(ULKLayoutMeasuredWidthHeightState)curState newState:(ULKLayoutMeasuredWidthHeightState)newState {
    curState.widthState |= newState.widthState;
    curState.heightState |= newState.heightState;
    return curState;
}

/**
 * Utility to reconcile a desired size and state, with constraints imposed
 * by a MeasureSpec.  Will take the desired size, unless a different size
 * is imposed by the constraints.  The returned value is a compound integer,
 * with the resolved size in the {@link #MEASURED_SIZE_MASK} bits and
 * optionally the bit {@link #MEASURED_STATE_TOO_SMALL} set if the resulting
 * size is smaller than the size the view wants to be.
 *
 * @param size How big the view wants to be
 * @param measureSpec Constraints imposed by the parent
 * @return Size information bit mask as defined by
 * {@link #MEASURED_SIZE_MASK} and {@link #MEASURED_STATE_TOO_SMALL}.
 */
+ (ULKLayoutMeasuredDimension)ulk_resolveSizeAndStateForSize:(CGFloat)size measureSpec:(ULKLayoutMeasureSpec)measureSpec childMeasureState:(ULKLayoutMeasuredState)childMeasuredState {
    ULKLayoutMeasuredDimension result = {size, ULKLayoutMeasuredStateNone};
    switch (measureSpec.mode) {
        case ULKLayoutMeasureSpecModeUnspecified:
            result.size = size;
            break;
        case ULKLayoutMeasureSpecModeAtMost:
            if (measureSpec.size < size) {
                result.size = measureSpec.size;
                result.state = ULKLayoutMeasuredStateTooSmall;
            } else {
                result.size = size;
            }
            break;
        case ULKLayoutMeasureSpecModeExactly:
            result.size = measureSpec.size;
            break;
    }
    result.state |= childMeasuredState;
    return result;
}

+ (CGFloat)ulk_resolveSizeForSize:(CGFloat)size measureSpec:(ULKLayoutMeasureSpec)measureSpec {
    return [self ulk_resolveSizeAndStateForSize:size measureSpec:measureSpec childMeasureState:ULKLayoutMeasuredStateNone].size;
}

- (void)setUlk_identifier:(NSString *)identifier {
    objc_setAssociatedObject(self,
                             @selector(ulk_identifier),
                             identifier,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    static BOOL hasPixateFreestyle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hasPixateFreestyle = (NSClassFromString(@"PixateFreestyle") != NULL);
    });
    if (hasPixateFreestyle) {
        [self setValue:identifier forKey:@"styleId"];
    }
}

- (NSString *)ulk_identifier {
    return objc_getAssociatedObject(self, @selector(ulk_identifier));
}

- (void)setUlk_visibility:(ULKViewVisibility)visibility {
    ULKViewVisibility curVisibility = self.ulk_visibility;
    [self setHidden:(visibility != ULKViewVisibilityVisible)];
    NSValue *newVisibilityObj = nil;
    switch (visibility) {
        case ULKViewVisibilityGone: {
            static NSValue *visibilityGone;
            if (!visibilityGone) {
                visibilityGone = [[NSValue alloc] initWithBytes:&visibility objCType:@encode(ULKViewVisibility)];
            }
            newVisibilityObj = visibilityGone;
        break;
        }
        case ULKViewVisibilityVisible: {
            static NSValue *visibilityVisible;
            if (!visibilityVisible) {
                visibilityVisible = [[NSValue alloc] initWithBytes:&visibility objCType:@encode(ULKViewVisibility)];
            }
            newVisibilityObj = visibilityVisible;
            break;
        }
        case ULKViewVisibilityInvisible: {
            static NSValue *visibilityInvisible;
            if (!visibilityInvisible) {
                visibilityInvisible = [[NSValue alloc] initWithBytes:&visibility objCType:@encode(ULKViewVisibility)];
            }
            newVisibilityObj = visibilityInvisible;
            break;
        }
    }

    objc_setAssociatedObject(self,
                             @selector(ulk_visibility),
                             newVisibilityObj,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ((curVisibility != visibility) && (curVisibility == ULKViewVisibilityGone || visibility == ULKViewVisibilityGone)) {
        [self ulk_requestLayout];
    }
}

- (ULKViewVisibility)ulk_visibility {
    ULKViewVisibility visibility = ULKViewVisibilityVisible;
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_visibility));
    [value getValue:&visibility];
    if (visibility == ULKViewVisibilityVisible && self.isHidden) {
        // Visibility has been set independently
        visibility = ULKViewVisibilityInvisible;
    }
    return visibility;
}

- (CGSize)ulk_minSize {
    CGSize ret = CGSizeZero;
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_minSize));
    [value getValue:&ret];
    return ret;

}

- (void)setUlk_minSize:(CGSize)size {
    NSValue *v = [[NSValue alloc] initWithBytes:&size objCType:@encode(CGSize)];
    objc_setAssociatedObject(self,
                             @selector(ulk_minSize),
                             v,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)ulk_maxSize {
    CGSize ret = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_maxSize));
    [value getValue:&ret];
    return ret;
    
}

- (void)setUlk_maxSize:(CGSize)size {
    NSValue *v = [[NSValue alloc] initWithBytes:&size objCType:@encode(CGSize)];
    objc_setAssociatedObject(self,
                             @selector(ulk_maxSize),
                             v,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ulk_setMeasuredDimensionSize:(ULKLayoutMeasuredSize)size {
    NSValue *value = [[NSValue alloc] initWithBytes:&size objCType:@encode(ULKLayoutMeasuredSize)];
    objc_setAssociatedObject(self,
                             @selector(ulk_measuredDimensionSize),
                             value,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ULKLayoutMeasuredSize)ulk_measuredDimensionSize {
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_measuredDimensionSize));
    ULKLayoutMeasuredSize ret;
    ULKLayoutMeasuredDimension dimension;
    dimension.size = CGFLOAT_MAX;
    dimension.state = ULKLayoutMeasuredStateNone;
    ret.width = dimension;
    ret.height = dimension;
    [value getValue:&ret];
    return ret;
}

- (CGSize)ulk_measuredSize {
    ULKLayoutMeasuredSize size = [self ulk_measuredDimensionSize];
    return CGSizeMake(size.width.size, size.height.size);
}

- (void)ulk_clearMeasuredDimensionSize
{
    objc_setAssociatedObject(self,
                             @selector(ulk_measuredDimensionSize),
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ulk_hadMeasured {
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_measuredDimensionSize));
    return value != nil;
}

- (void)ulk_setWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec {
    NSValue *value = [[NSValue alloc] initWithBytes:&widthMeasureSpec objCType:@encode(ULKLayoutMeasureSpec)];
    objc_setAssociatedObject(self,
                             @selector(ulk_widthMeasureSpec),
                             value,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ULKLayoutMeasureSpec)ulk_widthMeasureSpec {
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_widthMeasureSpec));
    ULKLayoutMeasureSpec ret;
    ret.size = CGFLOAT_MAX;
    ret.mode = ULKLayoutMeasureSpecModeUnspecified;
    [value getValue:&ret];
    return ret;
}

- (void)ulk_setHeightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    NSValue *value = [[NSValue alloc] initWithBytes:&heightMeasureSpec objCType:@encode(ULKLayoutMeasureSpec)];
    objc_setAssociatedObject(self,
                             @selector(ulk_heightMeasureSpec),
                             value,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ULKLayoutMeasureSpec)ulk_heightMeasureSpec {
    NSValue *value = objc_getAssociatedObject(self, @selector(ulk_heightMeasureSpec));
    ULKLayoutMeasureSpec ret;
    ret.size = CGFLOAT_MAX;
    ret.mode = ULKLayoutMeasureSpecModeUnspecified;
    [value getValue:&ret];
    return ret;
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    CGSize minSize = self.ulk_minSize;
    ULKLayoutMeasuredSize size;
    size.width = [self ulk_defaultSizeForSize:minSize.width measureSpec:widthMeasureSpec];
    size.height = [self ulk_defaultSizeForSize:minSize.height measureSpec:heightMeasureSpec];
    [self ulk_setMeasuredDimensionSize:size];
}

- (void)ulk_measureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasureSpec oldWidthMeasureSpec = [self ulk_widthMeasureSpec];
    ULKLayoutMeasureSpec oldHeightMeasureSpec = [self ulk_heightMeasureSpec];
    if (![self ulk_hadMeasured]
        || oldWidthMeasureSpec.mode != widthMeasureSpec.mode
        || oldWidthMeasureSpec.size != widthMeasureSpec.size
        || oldHeightMeasureSpec.mode != heightMeasureSpec.mode
        || oldHeightMeasureSpec.size != heightMeasureSpec.size)
    {
        [self ulk_onMeasureWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }

    if (oldWidthMeasureSpec.mode != widthMeasureSpec.mode
        || oldWidthMeasureSpec.size != widthMeasureSpec.size) {
        [self ulk_setWidthMeasureSpec:widthMeasureSpec];
    }
    if (oldHeightMeasureSpec.mode != heightMeasureSpec.mode
        || oldHeightMeasureSpec.size != heightMeasureSpec.size) {
        [self ulk_setHeightMeasureSpec:heightMeasureSpec];
    }
}

- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    
}

- (CGRect)ulk_roundFrame:(CGRect)frame {
    frame.origin.x = ceilf(frame.origin.x);
    frame.origin.y = ceilf(frame.origin.y);
    frame.size.width = ceilf(frame.size.width);
    frame.size.height = ceilf(frame.size.height);
    return frame;
}

- (BOOL)ulk_setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    CGRect newFrame = [self ulk_roundFrame:frame];
    BOOL changed = !CGRectEqualToRect(oldFrame, newFrame);
    if (changed) {
        self.frame = newFrame;
    }
    
    return changed;
}

- (void)ulk_layoutWithFrame:(CGRect)frame {
    BOOL changed = [self ulk_setFrame:frame];
    [self ulk_onLayoutWithFrame:frame didFrameChange:changed];
    if (changed) {
        NSString *identifier = self.ulk_identifier;
        if (identifier != nil) {
        }
        else {
        }
    }
}

/**
 * <p>Return the offset of the widget's text baseline from the widget's top
 * boundary. If this widget does not support baseline alignment, this
 * method returns -1. </p>
 *
 * @return the offset of the baseline within the widget's bounds or -1
 *         if baseline alignment is not supported
 */
- (CGFloat)ulk_baseline {
    return -1;
}

- (ULKLayoutMeasuredWidthHeightState)ulk_measuredState {
    ULKLayoutMeasuredWidthHeightState ret;
    ULKLayoutMeasuredSize measuredSize = [self ulk_measuredDimensionSize];
    ret.widthState = measuredSize.width.state;
    ret.heightState = measuredSize.height.state;
    return ret;
}

- (void)ulk_requestLayout {
    [self setNeedsLayout];
    [self ulk_clearMeasuredDimensionSize];
    UIView *superView = self.superview;
    if (superView != nil && [superView isKindOfClass:[ULKViewGroup class]]) {
        [superView setNeedsLayout];
        [superView ulk_clearMeasuredDimensionSize];
        
        UIView *tmpSuperView = superView.superview;
        while (tmpSuperView != nil && [tmpSuperView isKindOfClass:[ULKViewGroup class]]
            && (tmpSuperView.ulk_layoutWidth == ULKLayoutParamsSizeWrapContent
                || tmpSuperView.ulk_layoutHeight == ULKLayoutParamsSizeWrapContent))
        {
            [tmpSuperView setNeedsLayout];
            [tmpSuperView ulk_clearMeasuredDimensionSize];
            tmpSuperView = tmpSuperView.superview;
        }
    }
}

- (void)ulk_onFinishInflate {
    
}

- (UIView *)ulk_findViewById:(NSString *)identifier {
    UIView *ret = nil;
    if (self.ulk_isViewGroup) {
        ret = [self ulk_findViewTraversal:identifier];
    } else if ([self.ulk_identifier isEqualToString:identifier]) {
        ret = self;
    }
    return ret;
}

@end


@implementation UIView (ULK_Layout_ViewGroup)

- (ULKLayoutParams *)ulk_generateDefaultLayoutParams {
    return [[ULKLayoutParams alloc] initWithWidth:ULKLayoutParamsSizeWrapContent height:ULKLayoutParamsSizeWrapContent];
}

- (ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)lp {
    return lp;
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
    ULKLayoutParams *lp = (ULKLayoutParams *) child.ulk_layoutParams;
    UIEdgeInsets lpMargin = lp.margin;
    //    UIEdgeInsets padding = self.ulk_padding;
    UIEdgeInsets padding = UIEdgeInsetsZero;
    ULKLayoutMeasureSpec childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:padding.left + padding.right + lpMargin.left + lpMargin.right + widthUsed childDimension:lp.width];
    ULKLayoutMeasureSpec childHeightMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentHeightMeasureSpec padding:padding.top + padding.bottom + lpMargin.top + lpMargin.bottom + heightUsed childDimension:lp.height];
    
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

@end


@implementation UIView (ULKLayoutParams)

- (void)setUlk_layoutParams:(ULKLayoutParams *)layoutParams {
    objc_setAssociatedObject(self,
                             @selector(ulk_layoutParams),
                             layoutParams,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self ulk_requestLayout];
    
}

- (ULKLayoutParams *)ulk_layoutParams {
    ULKLayoutParams *layoutParams = objc_getAssociatedObject(self, @selector(ulk_layoutParams));
    if (layoutParams == nil) {
        layoutParams = [self ulk_generateDefaultLayoutParams];
        if (layoutParams == nil) {
            @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:@"ulk_generateDefaultLayoutParams() cannot return nil" userInfo:nil];
        }
        
        self.ulk_layoutParams = layoutParams;
    }
    
    return (ULKLayoutParams *)layoutParams;
}

- (void)setUlk_layoutWidth:(CGFloat)layoutWidth {
    self.ulk_layoutParams.width = layoutWidth;
    [self ulk_requestLayout];
}

- (CGFloat)ulk_layoutWidth {
    return self.ulk_layoutParams.width;
}

- (void)setUlk_layoutHeight:(CGFloat)layoutHeight {
    self.ulk_layoutParams.height = layoutHeight;
    [self ulk_requestLayout];
}

- (CGFloat)ulk_layoutHeight {
    return self.ulk_layoutParams.height;
}

- (void)setUlk_layoutMargin:(UIEdgeInsets)layoutMargin {
    self.ulk_layoutParams.margin = layoutMargin;
    [self ulk_requestLayout];
}

- (UIEdgeInsets)ulk_layoutMargin {
    return self.ulk_layoutParams.margin;
}

@end
