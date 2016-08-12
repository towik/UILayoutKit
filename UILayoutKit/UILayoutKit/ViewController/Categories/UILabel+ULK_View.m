//
//  UILabel+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UILabel+ULK_View.h"
#import "UIView+ULK_Layout.h"
#import "UIColor+ULK_ColorParser.h"
#import "ULKResourceManager.h"
#import "NSDictionary+ULK_ResourceManager.h"
#import "NSObject+ULK_KVOObserver.h"

#include "objc/runtime.h"
#include "objc/message.h"

@implementation UILabel (Layout)

//+ (void)load {
//    Class c = self;
//    SEL origSEL = @selector(drawRect:);
//    SEL overrideSEL = @selector(ulk_drawRect:);
//    Method origMethod = class_getInstanceMethod(c, origSEL);
//    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
//    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
//        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
//    } else {
//        method_exchangeImplementations(origMethod, overrideMethod);
//    }
//}

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    
    self.text = [attrs ulk_stringFromIDLValueForKey:@"text"];
    
    self.ulk_gravity = [ULKGravity gravityFromAttribute:attrs[@"gravity"]];
    NSString *lines = attrs[@"lines"];
    self.numberOfLines = [lines integerValue];
    
    ULKColorStateList *textColorStateList = [attrs ulk_colorStateListFromIDLValueForKey:@"textColor"];
    if (textColorStateList != nil) {
        self.textColor = [textColorStateList colorForControlState:UIControlStateNormal];
        UIColor *highlightedColor = [textColorStateList colorForControlState:UIControlStateHighlighted];
        if (highlightedColor != nil) {
            self.highlightedTextColor = highlightedColor;
        }
    } else {
        UIColor *color = [attrs ulk_colorFromIDLValueForKey:@"textColor"];
        if (color != nil) {
            self.textColor = color;
        }
    }
    
    NSString *fontName = attrs[@"font"];
    NSString *textSize = attrs[@"textSize"];
    if (fontName != nil) {
        CGFloat size = self.font.pointSize;
        if (textSize != nil) size = [textSize floatValue];
        self.font = [UIFont fontWithName:fontName size:size];
    } else if (textSize != nil) {
        CGFloat size = [textSize floatValue];
        self.font = [UIFont systemFontOfSize:size];
    }
}

- (ULKViewContentGravity)ulk_gravity {
    ULKViewContentGravity ret;
    switch (self.textAlignment) {
        case NSTextAlignmentLeft:
            ret = ULKViewContentGravityLeft;
            break;
        case NSTextAlignmentRight:
            ret = ULKViewContentGravityRight;
            break;
        case NSTextAlignmentCenter:
            ret = ULKViewContentGravityCenterHorizontal;
            break;
        case NSTextAlignmentJustified:
            ret = ULKViewContentGravityFillHorizontal;
            break;
        default:
            ret = ULKViewContentGravityNone;
            break;
    }
    return ret;
}

- (void)setUlk_gravity:(ULKViewContentGravity)gravity {
    if ((gravity & ULKViewContentGravityLeft) == ULKViewContentGravityLeft) {
        self.textAlignment = NSTextAlignmentLeft;
    } else if ((gravity & ULKViewContentGravityRight) == ULKViewContentGravityRight) {
        self.textAlignment = NSTextAlignmentRight;
    } else {
        self.textAlignment = NSTextAlignmentCenter;
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
    
    if (widthMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: self.font}
                                                        context:nil].size;
        measuredSize.width.size = ceilf(size.width);
        if (widthMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.ulk_minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        //CGSize size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(measuredSize.width.size, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
        CGSize size = [self.text boundingRectWithSize:CGSizeMake(measuredSize.width.size, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: self.font}
                                              context:nil].size;
        measuredSize.height.size = MAX(ceilf(size.height), self.numberOfLines * self.font.lineHeight);
        if (heightMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    
    [self ulk_setMeasuredDimensionSize:measuredSize];
}

//- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
//    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
//    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
//    CGFloat widthSize = widthMeasureSpec.size;
//    CGFloat heightSize = heightMeasureSpec.size;
//    
//    ULKLayoutMeasuredSize measuredSize;
//    measuredSize.width.state = ULKLayoutMeasuredStateNone;
//    measuredSize.height.state = ULKLayoutMeasuredStateNone;
//    UIEdgeInsets padding = self.ulk_padding;
//    
//    
//    if (widthMode == ULKLayoutMeasureSpecModeExactly) {
//        measuredSize.width.size = widthSize;
//    } else {
//        CGSize size;
//        if ([self respondsToSelector:@selector(attributedText)]) {
//            size = [self.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
//                                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                                     context:nil].size;
//        } else {
//            [self.text sizeWithFont:self.font];
//        }
//        measuredSize.width.size = ceilf(size.width) + padding.left + padding.right;
//        if (widthMode == ULKLayoutMeasureSpecModeAtMost) {
//            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
//        }
//    }
//    CGSize minSize = self.ulk_minSize;
//    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
//    
//    if (heightMode == ULKLayoutMeasureSpecModeExactly) {
//        measuredSize.height.size = heightSize;
//    } else {
//        CGSize size;
//        if ([self respondsToSelector:@selector(attributedText)]) {
//            size = [self.text boundingRectWithSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil].size;
//        } else {
//            size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
//        }
//        measuredSize.height.size = MAX(ceilf(size.height), self.numberOfLines * self.font.lineHeight) + padding.top + padding.bottom;
//        if (heightMode == ULKLayoutMeasureSpecModeAtMost) {
//            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
//        }
//    }
//    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
//    
//    [self ulk_setMeasuredDimensionSize:measuredSize];
//}

- (void)ulk_setText:(NSString *)text {
    [self setText:text];
    [self ulk_requestLayout];
}

- (void)ulk_setFont:(UIFont *)font {
    [self setFont:font];
    [self ulk_requestLayout];
}

- (void)ulk_setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self setLineBreakMode:lineBreakMode];
    [self ulk_requestLayout];
}

@end
