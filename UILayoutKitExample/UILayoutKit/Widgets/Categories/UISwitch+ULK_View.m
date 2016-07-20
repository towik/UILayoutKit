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
#import "NSDictionary+ULK_ResourceManager.h"

@implementation UISwitch (ULK_View)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    
    UIColor *tintColor = [attrs ulk_colorFromIDLValueForKey:@"tintColor"];
    if (tintColor != nil) {
        if ([self respondsToSelector:@selector(setTintColor:)]) {
            self.tintColor = tintColor;
        }
    }
    
    UIColor *onTintColor = [attrs ulk_colorFromIDLValueForKey:@"onTintColor"];
    if (onTintColor != nil) {
        if ([self respondsToSelector:@selector(setOnTintColor:)]) {
            self.onTintColor = onTintColor;
        }
    }

    UIColor *thumbTintColor = [attrs ulk_colorFromIDLValueForKey:@"thumbTintColor"];
    if (thumbTintColor != nil) {
        if ([self respondsToSelector:@selector(setThumbTintColor:)]) {
            self.thumbTintColor = thumbTintColor;
        }
    }
    
    NSString *isOn = attrs[@"isOn"];
    if (isOn != nil) {
        self.on = ULKBOOLFromString(isOn);
    }
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasuredSize size;
    size.width.state = ULKLayoutMeasuredStateNone;
    size.width.size = self.frame.size.width;
    size.height.state = ULKLayoutMeasuredStateNone;
    size.height.size = self.frame.size.height;
    
    [self ulk_setMeasuredDimensionSize:size];
}

@end
