//
//  ViewGroup.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKViewGroup.h"
#import "ULKLayoutParams.h"


@implementation ULKViewGroup

- (void)setUlk_padding:(UIEdgeInsets)padding {
    _ulk_padding = padding;
    [self ulk_requestLayout];
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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ULKLayoutParams *layoutParams = [[ULKLayoutParams alloc] initWithWidth:ULKLayoutParamsSizeMatchParent height:ULKLayoutParamsSizeMatchParent];
        self.layoutParams = layoutParams;
    }
    return self;
}

/**
 * Does the hard part of measureChildren: figuring out the MeasureSpec to
 * pass to a particular child. This method figures out the right MeasureSpec
 * for one dimension (height or width) of one child view.
 *
 * The goal is to combine information from our MeasureSpec with the
 * LayoutParams of the child to get the best possible results. For example,
 * if the this view knows its size (because its MeasureSpec has a mode of
 * EXACTLY), and the child has indicated in its LayoutParams that it wants
 * to be the same size as the parent, the parent should ask the child to
 * layout given an exact size.
 *
 * @param spec The requirements for this view
 * @param padding The padding of this view for the current dimension and
 *        margins, if applicable
 * @param childDimension How big the child wants to be in the current
 *        dimension
 * @return a MeasureSpec integer for the child
 */
+ (ULKLayoutMeasureSpec)childMeasureSpecForMeasureSpec:(ULKLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension {
    ULKLayoutMeasureSpecMode specMode = spec.mode;
    CGFloat specSize = spec.size;
    
    CGFloat size = MAX(0, specSize - padding);
    
    ULKLayoutMeasureSpec result = ULKLayoutMeasureSpecMake(0.f, ULKLayoutMeasureSpecModeUnspecified);
    
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

- (BOOL)ulk_isViewGroup {
    return TRUE;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    ULKLayoutMeasureSpec widthMeasureSpec;
    ULKLayoutMeasureSpec heightMeasureSpec;
    widthMeasureSpec.size = self.frame.size.width;
    heightMeasureSpec.size = self.frame.size.height;
    widthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
    heightMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
    if (!self.ulk_hadMeasured) {
        [self ulk_measureWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
    [self ulk_layoutWithFrame:self.frame];
}

- (void)didAddSubview:(UIView *)subview {
    ULKLayoutParams *params = subview.layoutParams;
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
    subview.layoutParams = params;
    
    [subview ulk_requestLayout];
    
    if ([subview isKindOfClass:[UILabel class]]
        || [subview isKindOfClass:[UITextField class]]
        || [subview isKindOfClass:[UITextView class]]) {
        [subview addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [subview addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    if ([subview isKindOfClass:[UILabel class]]) {
        [subview addObserver:self forKeyPath:@"lineBreakMode" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)willRemoveSubview:(UIView *)subview {
    if (!self.ulk_isViewGroup) {
        @throw [NSException exceptionWithName:@"UnsuportedOperationException" reason:@"Views can only be removed from ViewGroup objects" userInfo:nil];
    }
    
    [subview ulk_requestLayout];
    
    if ([subview isKindOfClass:[UILabel class]]
        || [subview isKindOfClass:[UITextField class]]
        || [subview isKindOfClass:[UITextView class]]) {
        [subview removeObserver:self forKeyPath:@"text"];
        [subview removeObserver:self forKeyPath:@"font"];
    }
    
    if ([subview isKindOfClass:[UILabel class]]) {
        [subview removeObserver:self forKeyPath:@"lineBreakMode"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView*)object change:(NSDictionary *)change context:(void *)context
{
    [object ulk_requestLayout];
}

@end
