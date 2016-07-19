//
//  UIButton+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIButton+ULK_View.h"
#import "UIView+ULK_Layout.h"
#import "ULKGravity.h"
#import "ULKResourceManager.h"
#import "UIColor+ULK_ColorParser.h"
#import "UIImage+ULK_FromColor.h"

@implementation UIButton (Layout)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    /*NSString *backgroundString = [attrs objectForKey:@"background"];
    if (backgroundString != nil) {
        NSMutableDictionary *mutableAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        [mutableAttrs removeObjectForKey:@"background"];
        attrs = mutableAttrs;
    }*/
    
    [super ulk_setupFromAttributes:attrs];
    NSString *text = attrs[@"text"];
    if ([[ULKResourceManager currentResourceManager] isValidIdentifier:text]) {
        NSString *title = [[ULKResourceManager currentResourceManager] stringForIdentifier:text];
        [self setTitle:title forState:UIControlStateNormal];
    } else {
        [self setTitle:text forState:UIControlStateNormal];
    }
    NSString *textColor = attrs[@"textColor"];
    if ([textColor length] > 0) {
        ULKColorStateList *colorStateList = [[ULKResourceManager currentResourceManager] colorStateListForIdentifier:textColor];
        if (colorStateList != nil) {
            for (NSInteger i=[colorStateList.items count]-1; i>=0; i--) {
                ULKColorStateItem *item = (colorStateList.items)[i];
                [self setTitleColor:item.color forState:item.controlState];
            }
        } else {
            UIColor *color = [UIColor ulk_colorFromIDLColorString:textColor];
            if (color != nil) {
                [self setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
    
    NSString *fontName = attrs[@"font"];
    NSString *textSize = attrs[@"textSize"];
    if (fontName != nil) {
        CGFloat size = self.titleLabel.font.pointSize;
        if (textSize != nil) size = [textSize floatValue];
        self.titleLabel.font = [UIFont fontWithName:fontName size:size];
    } else if (textSize != nil) {
        CGFloat size = [textSize floatValue];
        self.titleLabel.font = [UIFont systemFontOfSize:size];
    }

    
    /*if ([backgroundString length] > 0) {
        ULKDrawableStateList *drawableStateList = [[ULKResourceManager currentResourceManager] drawableStateListForIdentifier:backgroundString];
        if (drawableStateList != nil) {
            for (NSInteger i=[drawableStateList.items count]-1; i>=0; i--) {
                ULKDrawableStateItem *item = [drawableStateList.items objectAtIndex:i];
                [self setBackgroundImage:item.image forState:item.controlState];
            }
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:backgroundString];
            if (color != nil) {
                UIImage *image = [UIImage ulk_imageFromColor:color withSize:CGSizeMake(1, 1)];
                [self setBackgroundImage:image forState:UIControlStateNormal];
            }
        }
    }*/
    
    NSString *imageString = attrs[@"image"];
    if ([imageString length] > 0) {
        ULKDrawableStateList *drawableStateList = [[ULKResourceManager currentResourceManager] drawableStateListForIdentifier:imageString];
        if (drawableStateList != nil) {
            for (NSInteger i=[drawableStateList.items count]-1; i>=0; i--) {
                ULKDrawableStateItem *item = (drawableStateList.items)[i];
                [self setBackgroundImage:item.image forState:item.controlState];
            }
        }
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
    UIEdgeInsets padding = self.ulk_padding;
    
    
    if (widthMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font];
        measuredSize.width.size = ceilf(size.width) + padding.left + padding.right;
        if (widthMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.ulk_minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX) lineBreakMode:self.titleLabel.lineBreakMode];
        measuredSize.height.size = ceilf(size.height) + padding.top + padding.bottom;
        if (heightMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    
    [self ulk_setMeasuredDimensionSize:measuredSize];
}

- (void)setUlk_gravity:(ULKViewContentGravity)gravity {
    if ((gravity & ULKViewContentGravityTop) == ULKViewContentGravityTop) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    } else if ((gravity & ULKViewContentGravityBottom) == ULKViewContentGravityBottom) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    } else if ((gravity & ULKViewContentGravityFillVertical) == ULKViewContentGravityFillVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    }
}

- (void)setUlk_padding:(UIEdgeInsets)padding {
    [super setUlk_padding:padding];
    self.contentEdgeInsets = padding;
}


@end
