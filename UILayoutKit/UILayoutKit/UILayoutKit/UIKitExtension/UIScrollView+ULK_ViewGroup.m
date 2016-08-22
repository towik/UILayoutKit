//
//  UIScrollView+ULK_ViewGroup.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UIScrollView+ULK_ViewGroup.h"
#import "UIView+ULK_Layout.h"


@implementation UIScrollView (ULK_ViewGroup)

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.ulk_isViewGroup) {
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
}

- (void)ulk_measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed {
    ULKLayoutParams *lp = (ULKLayoutParams *) child.ulk_layoutParams;
    UIEdgeInsets lpMargin = lp.margin;
    UIEdgeInsets padding = self.contentInset;
    ULKLayoutMeasureSpec childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:padding.left + padding.right + lpMargin.left + lpMargin.right + widthUsed childDimension:lp.width];
    ULKLayoutMeasureSpec childHeightMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentHeightMeasureSpec padding:padding.top + padding.bottom + lpMargin.top + lpMargin.bottom + heightUsed childDimension:lp.height];
    
    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec
{
    if (self.subviews.count > 0) {
        UIView *child = self.subviews[0];
        CGFloat width = child.ulk_measuredSize.width;
        CGFloat height = child.ulk_measuredSize.height;
        
        [self ulk_measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
        
        ULKLayoutMeasuredSize measuredSize = ULKLayoutMeasuredSizeMake([UIView ulk_resolveSizeAndStateForSize:width measureSpec:widthMeasureSpec childMeasureState:ULKLayoutMeasuredStateNone], [UIView ulk_resolveSizeAndStateForSize:height measureSpec:heightMeasureSpec childMeasureState:ULKLayoutMeasuredStateNone]);
        [self ulk_setMeasuredDimensionSize:measuredSize];
    }
}

- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    if (self.subviews.count > 0) {
        UIView *child = self.subviews[0];
        CGFloat width = child.ulk_measuredSize.width;
        CGFloat height = child.ulk_measuredSize.height;
        
        [child ulk_setFrame:CGRectMake(0, 0, width, height)];
        self.contentSize = CGSizeMake(width, height);
    }
}

- (BOOL)ulk_isViewGroup {
    BOOL ret = FALSE;
    if ([self class] == [UIScrollView class] || [NSStringFromClass([self class]) hasSuffix:@"UIScrollView"]) {
        ret = TRUE;
    }
    return ret;
}

@end
