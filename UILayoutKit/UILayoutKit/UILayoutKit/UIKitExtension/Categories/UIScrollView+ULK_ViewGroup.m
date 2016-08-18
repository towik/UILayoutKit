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
#import "ULKLayoutParams.h"
#import "UIView+ULK_ViewGroup.h"


@implementation UIScrollView (ULK_ViewGroup)

- (void)layoutSubviews {
    [super layoutSubviews];
    
    ULKLayoutMeasureSpec widthMeasureSpec;
    ULKLayoutMeasureSpec heightMeasureSpec;
    widthMeasureSpec.size = self.frame.size.width;
    heightMeasureSpec.size = self.frame.size.height;
    widthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
    heightMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
    [self ulk_measureWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    [self ulk_layoutWithFrame:self.frame];
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
