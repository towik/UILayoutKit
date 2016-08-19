//
//  ULKFrameLayout.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKFrameLayout.h"

#pragma mark - import libs
#include <objc/runtime.h>

#pragma mark -



@implementation ULKFrameLayoutParams

- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams {
    self = [super initWithLayoutParams:layoutParams];
    if (self) {
        if ([layoutParams isKindOfClass:[ULKFrameLayoutParams class]]) {
            ULKFrameLayoutParams *otherLP = (ULKFrameLayoutParams *)layoutParams;
            self.gravity = otherLP.gravity;
        }
    }
    return self;
}

@end


@implementation UIView (ULK_FrameLayoutParams)

- (void)setFrameLayoutParams:(ULKFrameLayoutParams *)frameLayoutParams {
    self.layoutParams = frameLayoutParams;
}

- (ULKFrameLayoutParams *)frameLayoutParams {
    ULKLayoutParams *layoutParams = self.layoutParams;
    if (![layoutParams isKindOfClass:[ULKFrameLayoutParams class]]) {
        layoutParams = [[ULKFrameLayoutParams alloc] initWithLayoutParams:layoutParams];
        self.layoutParams = layoutParams;
    }
    
    return (ULKFrameLayoutParams *)layoutParams;
}

- (void)setUlk_layoutGravity:(ULKGravity)layoutGravity {
    self.frameLayoutParams.gravity = layoutGravity;
    [self ulk_requestLayout];
}

- (ULKGravity)ulk_layoutGravity {
    return self.frameLayoutParams.gravity;
}

@end


@implementation ULKFrameLayout

static char matchParentChildrenKey;


+ (void)setMatchParentChildren:(UIView *)measureView list:(NSMutableArray *)list {
    objc_setAssociatedObject(measureView,
                             &matchParentChildrenKey,
                             list,
                             OBJC_ASSOCIATION_RETAIN);
}

+ (NSMutableArray *)matchParentChildren:(UIView *)measureView {
    NSMutableArray *list = objc_getAssociatedObject(measureView, &matchParentChildrenKey);
    if (list == nil) {
        list = [NSMutableArray arrayWithCapacity:[measureView.subviews count]];
        [ULKFrameLayout setMatchParentChildren:measureView list:list];
    }
    return list;
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    [ULKFrameLayout onFrameLayoutMeasure:self widthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
}

- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    [ULKFrameLayout onFrameLayoutLayout:self frame:frame didFrameChange:changed];
}


+ (void)onFrameLayoutMeasure:(ULKViewGroup *)measureView widthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec
                             heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    NSInteger count = [measureView.subviews count];

    BOOL measureMatchParentChildren = widthMeasureSpec.mode != ULKLayoutMeasureSpecModeExactly || heightMeasureSpec.mode != ULKLayoutMeasureSpecModeExactly;
    NSMutableArray *matchParentChildren = [ULKFrameLayout matchParentChildren:measureView];
    [matchParentChildren removeAllObjects];
    
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;
    UIEdgeInsets padding = measureView.ulk_padding;
    ULKLayoutMeasuredWidthHeightState childState;
    childState.heightState = ULKLayoutMeasuredStateNone;
    childState.widthState = ULKLayoutMeasuredStateNone;
    
    for (int i = 0; i < count; i++) {
        UIView *child = (measureView.subviews)[i];
        if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
            continue;
        }
        
        if (child.ulk_visibility != ULKViewVisibilityGone) {
            [measureView ulk_measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
            ULKFrameLayoutParams *lp = (ULKFrameLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            maxWidth = MAX(maxWidth, child.ulk_measuredSize.width + lpMargin.left + lpMargin.right);
            maxHeight = MAX(maxHeight, child.ulk_measuredSize.height + lpMargin.top + lpMargin.bottom);
            childState = [UIView ulk_combineMeasuredStatesCurrentState:childState newState:child.ulk_measuredState];
            if (measureMatchParentChildren) {
                if (lp.width == ULKLayoutParamsSizeMatchParent || lp.height == ULKLayoutParamsSizeMatchParent) {
                    [matchParentChildren addObject:child];
                }
            }
        }
    }
    
    // Account for padding too
    maxWidth += padding.left + padding.right;
    maxHeight += padding.top + padding.bottom;
    
    // Check against our minimum height and width
    CGSize minSize = measureView.ulk_minSize;
    maxHeight = MAX(maxHeight, minSize.height);
    maxWidth = MAX(maxWidth, minSize.width);
    
    // Check against our foreground's minimum height and width
    ULKLayoutMeasuredSize measuredSize = ULKLayoutMeasuredSizeMake([UIView ulk_resolveSizeAndStateForSize:maxWidth measureSpec:widthMeasureSpec childMeasureState:childState.widthState], [UIView ulk_resolveSizeAndStateForSize:maxHeight measureSpec:heightMeasureSpec childMeasureState:childState.heightState]);
    [measureView ulk_setMeasuredDimensionSize:measuredSize];
    
    count = [matchParentChildren count];
    if (count > 1) {
        for (int i = 0; i < count; i++) {
            UIView *child = matchParentChildren[i];
            
            if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
                continue;
            }
            
            ULKLayoutParams *lp = (ULKLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            ULKLayoutMeasureSpec childWidthMeasureSpec;
            ULKLayoutMeasureSpec childHeightMeasureSpec;
            
            if (lp.width == ULKLayoutParamsSizeMatchParent) {
                childWidthMeasureSpec.size = measureView.ulk_measuredSize.width - padding.left - padding.right - lpMargin.left - lpMargin.right;
                childWidthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
            } else {
                childWidthMeasureSpec = [measureView ulk_childMeasureSpecWithMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right + lpMargin.left + lpMargin.right) childDimension:lp.width];
            }
            
            if (lp.height == ULKLayoutParamsSizeMatchParent) {
                childHeightMeasureSpec.size = measureView.ulk_measuredSize.height - padding.top - padding.bottom - lpMargin.top - lpMargin.bottom;
                childHeightMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
            } else {
                childHeightMeasureSpec = [measureView ulk_childMeasureSpecWithMeasureSpec:heightMeasureSpec padding:(padding.top + padding.bottom + lpMargin.top + lpMargin.bottom) childDimension:lp.height];
            }
            [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
        }
    }
    
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    if (heightMode == ULKLayoutMeasureSpecModeUnspecified) {
        return;
    }
    
    /*if ([self.subviews count] > 0) {
     UIView *child = [self.subviews objectAtIndex:0];
     CGFloat height = self.measuredSize.height;
     CGSize childMeasuredSize = child.measuredSize;
     if (child.measuredSize.height < height) {
     FrameLayoutLayoutParams *lp = (FrameLayoutLayoutParams *) child.layoutParams;
     
     ULKLayoutMeasureSpec childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right) childDimension:lp.width];
     height -= padding.top;
     height -= padding.bottom;
     ULKLayoutMeasureSpec childHeightMeasureSpec = ULKLayoutMeasureSpecMake(height, ULKLayoutMeasureSpecModeExactly);
     
     [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
     }
     }*/
}

+ (CGSize)onFrameLayoutLayout:(ULKViewGroup *)measureView frame:(CGRect)frame didFrameChange:(BOOL)changed {
    NSInteger count = [measureView.subviews count];
    
    UIEdgeInsets padding = measureView.ulk_padding;
    CGFloat parentLeft = padding.left;
    CGFloat parentRight = frame.size.width - padding.right;
    
    CGFloat parentTop = padding.top;
    CGFloat parentBottom = frame.size.height - padding.bottom;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (int i = 0; i < count; i++) {
        UIView *child = (measureView.subviews)[i];
        
        if (child.ulk_visibility != ULKViewVisibilityGone && ![NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
            ULKFrameLayoutParams *lp = (ULKFrameLayoutParams *)child.layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            CGFloat width = child.ulk_measuredSize.width;
            CGFloat height = child.ulk_measuredSize.height;
            
            CGFloat childLeft;
            CGFloat childTop;
            
            NSInteger gravity = lp.gravity;
            if (gravity == -1) {
                gravity = DEFAULT_CHILD_GRAVITY;
            }
            
            ULKGravity verticalGravity = gravity & VERTICAL_GRAVITY_MASK;
            ULKGravity horizontalGravity = gravity & HORIZONTAL_GRAVITY_MASK;
            
            switch (horizontalGravity) {
                case ULKGravityLeft:
                    childLeft = parentLeft + lpMargin.left;
                    break;
                case ULKGravityCenterHorizontal:
                    childLeft = parentLeft + (parentRight - parentLeft - width) / 2 + lpMargin.left - lpMargin.right;
                    break;
                case ULKGravityRight:
                    childLeft = parentRight - width - lpMargin.right;
                    break;
                default:
                    childLeft = parentLeft + lpMargin.left;
            }
            
            switch (verticalGravity) {
                case ULKGravityTop:
                    childTop = parentTop + lpMargin.top;
                    break;
                case ULKGravityCenterVertical:
                    childTop = parentTop + (parentBottom - parentTop - height) / 2 + lpMargin.top - lpMargin.bottom;
                    break;
                case ULKGravityBottom:
                    childTop = parentBottom - height - lpMargin.bottom;
                    break;
                default:
                    childTop = parentTop + lpMargin.top;
            }
            
            [child ulk_setFrame:CGRectMake(childLeft, childTop, width, height)];
            maxX = MAX(maxX, childLeft + width);
            maxY = MAX(maxY, childTop + height);
        }
    }
    
    return CGSizeMake(maxX + padding.right, maxY + padding.bottom);
}


- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams {
    return [layoutParams isKindOfClass:[ULKFrameLayoutParams class]];
}

- (ULKLayoutParams *)ulk_generateDefaultLayoutParams {
    return [[ULKFrameLayoutParams alloc] initWithWidth:ULKLayoutParamsSizeMatchParent height:ULKLayoutParamsSizeMatchParent];
}

-(ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)layoutParams {
    return [[ULKFrameLayoutParams alloc] initWithLayoutParams:layoutParams];
}

@end