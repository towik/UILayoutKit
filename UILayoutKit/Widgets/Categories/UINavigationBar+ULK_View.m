//
//  UINavigationBar+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UINavigationBar+ULK_View.h"
#import "UIToolbar+ULK_View.h"
#import "UIView+ULK_Layout.h"
#import "NSDictionary+ULK_ResourceManager.h"

@implementation UINavigationBar (ULK_View)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    UIColor *tintColor = [attrs ulk_colorFromIDLValueForKey:@"tintColor"];
    if (tintColor != nil) {
        self.tintColor = tintColor;
    }
    NSString *barStyle = attrs[@"barStyle"];
    if (barStyle != nil) {
        self.barStyle = ULKUIBarStyleFromString(barStyle);
    }
    NSString *translucent = attrs[@"translucent"];
    if (translucent != nil) {
        self.translucent = ULKBOOLFromString(translucent);
    }
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    ULKLayoutMeasuredSize measuredSize;
    measuredSize.width.state = ULKLayoutMeasuredStateNone;
    measuredSize.height.state = ULKLayoutMeasuredStateNone;
    
    switch (widthMode) {
        case ULKLayoutMeasureSpecModeAtMost:
        case ULKLayoutMeasureSpecModeExactly:
            measuredSize.width.size = widthSize;
            break;
        default:
            measuredSize.width.size = 320.f;
            break;
    }
    switch (heightMode) {
        case ULKLayoutMeasureSpecModeExactly:
            measuredSize.height.size = heightSize;
            break;
        default:
            measuredSize.height.size = 44.f;
            break;
    }
    measuredSize.width.size = MAX(measuredSize.width.size, self.ulk_minSize.width);
    
    [self ulk_setMeasuredDimensionSize:measuredSize];
}

@end
