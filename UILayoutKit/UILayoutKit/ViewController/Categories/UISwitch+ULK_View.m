//
//  UISwitch+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UISwitch+ULK_View.h"
#import "UIView+ULK_Layout.h"

@implementation UISwitch (ULK_View)

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasuredSize size;
    size.width.state = ULKLayoutMeasuredStateNone;
    size.width.size = self.frame.size.width;
    size.height.state = ULKLayoutMeasuredStateNone;
    size.height.size = self.frame.size.height;
    
    [self ulk_setMeasuredDimensionSize:size];
}

@end
