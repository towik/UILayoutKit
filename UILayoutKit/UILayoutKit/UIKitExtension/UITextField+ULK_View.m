//
//  UITextField+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UITextField+ULK_View.h"
#import "UIView+ULK_Layout.h"

@implementation UITextField (ULK_View)

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    ULKLayoutMeasuredSize measuredSize;
    measuredSize.width.state = ULKLayoutMeasuredStateNone;
    measuredSize.height.state = ULKLayoutMeasuredStateNone;
//    UIEdgeInsets padding = self.ulk_padding;
    UIEdgeInsets padding = UIEdgeInsetsZero;
    
    if (widthMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font];
        measuredSize.width.size = ceilf(size.width) + padding.left + padding.right;
        if (widthMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.ulk_minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    measuredSize.width.size = MIN(measuredSize.width.size, maxSize.width);
    
    if (heightMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX)];
        measuredSize.height.size = MAX(ceilf(size.height), self.font.lineHeight) + padding.top + padding.bottom;
        if (heightMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    measuredSize.height.size = MIN(measuredSize.height.size, maxSize.height);
    
    [self ulk_setMeasuredDimensionSize:measuredSize];
}

@end
