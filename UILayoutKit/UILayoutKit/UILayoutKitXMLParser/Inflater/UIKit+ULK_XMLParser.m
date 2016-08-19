//
//  UIKit+ULK_XMLParser.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKFrameLayout.h"
#import "ULKLinearLayout.h"
#import "UIButton+ULK_View.h"
#import "UILabel+ULK_View.h"
#import "UIView+ULK_Layout.h"
#import "UIToolbar+ULK_View.h"
#import "ULKLinearLayout.h"
#import "ULKGravity.h"
#import "UIColor+ULK_ColorParser.h"
#import "UIImage+ULK_FromColor.h"
#import "ULKResourceManager.h"
#import "NSDictionary+ULK_ResourceManager.h"


@implementation ULKFrameLayoutParams (ULK_XMLParser)

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs {
    self = [super initUlk_WithAttributes:attrs];
    if (self) {
        NSString *gravityString = attrs[@"layout_gravity"];
        self.gravity = [ULKGravityUtility gravityFromAttribute:gravityString];
    }
    return self;
}

@end


@implementation UIScrollView (ULK_XMLParser)

- (ULKLayoutParams *)ulk_generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[ULKFrameLayoutParams alloc] initUlk_WithAttributes:attrs];
}

@end


@implementation ULKLinearLayoutParams (ULK_XMLParser)

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs {
    self = [super initUlk_WithAttributes:attrs];
    if (self) {
        self.weight = [attrs[@"layout_weight"] floatValue];
    }
    return self;
}

@end


@implementation UIView (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    
    // visibility
    NSString *visibilityString = attrs[@"visibility"];
    self.ulk_visibility = ULKViewVisibilityFromString(visibilityString);
    
    // backgroundColor
    UIColor *backgroundColor = [attrs ulk_colorFromIDLValueForKey:@"backgroundColor"];
    if (backgroundColor != nil) {
        self.backgroundColor = backgroundColor;
    }
    
    // padding
    NSString *paddingString = attrs[@"padding"];
    if (paddingString != nil) {
        CGFloat padding = [paddingString floatValue];
        self.ulk_padding = UIEdgeInsetsMake(padding, padding, padding, padding);
    } else {
        UIEdgeInsets padding = self.ulk_padding;
        UIEdgeInsets initialPadding = padding;
        NSString *paddingTopString = attrs[@"paddingTop"];
        NSString *paddingLeftString = attrs[@"paddingLeft"];
        NSString *paddingBottomString = attrs[@"paddingBottom"];
        NSString *paddingRightString = attrs[@"paddingRight"];
        if ([paddingTopString length] > 0) padding.top = [paddingTopString floatValue];
        if ([paddingLeftString length] > 0) padding.left = [paddingLeftString floatValue];
        if ([paddingBottomString length] > 0) padding.bottom = [paddingBottomString floatValue];
        if ([paddingRightString length] > 0) padding.right = [paddingRightString floatValue];
        if (!UIEdgeInsetsEqualToEdgeInsets(padding, initialPadding)) {
            self.ulk_padding = padding;
        }
    }
    
    // alpha
    NSString *alphaString = attrs[@"alpha"];
    if (alphaString != nil) {
        CGFloat alpha = MIN(1.0, MAX(0.0, [alphaString floatValue]));
        self.alpha = alpha;
    }
    
    // minSize
    CGFloat minWidth = [attrs[@"minWidth"] floatValue];
    CGFloat minHeight = [attrs[@"minHeight"] floatValue];
    self.ulk_minSize = CGSizeMake(minWidth, minHeight);
    
    // identifier
    NSString *identifier = attrs[@"id"];
    if (identifier != nil) {
        NSRange range = [identifier rangeOfString:@"@id/"];
        if (range.location == NSNotFound) {
            range = [identifier rangeOfString:@"@+id/"];
        }
        if (range.location == 0) {
            identifier = [NSString stringWithFormat:@"%@", [identifier substringFromIndex:range.location + range.length]];
        }
        self.ulk_identifier = identifier;
    }
    
    // nuiClass (if available)
    static BOOL nuiAvailable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nuiAvailable = NSClassFromString(@"NUISettings") != nil;
    });
    if (nuiAvailable) {
        NSString *nuiClass = attrs[@"nuiClass"];
        if ([nuiClass length] > 0) {
            [self setValue:nuiClass forKey:@"nuiClass"];
        }
    }
    
    // border
    NSString *borderWidth = attrs[@"borderWidth"];
    if (borderWidth != nil) {
        self.layer.borderWidth = [borderWidth floatValue];
    }
    UIColor *borderColor = [attrs ulk_colorFromIDLValueForKey:@"borderColor"];
    if (borderColor != nil) {
        self.layer.borderColor = borderColor.CGColor;
    }
    NSString *cornerRadius = attrs[@"cornerRadius"];
    if (cornerRadius != nil) {
        self.layer.cornerRadius = [cornerRadius floatValue];
    }
}

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs {
    self = [self init];
    if (self) {
        [self ulk_setupFromAttributes:attrs];
    }
    return self;
}

@end


@implementation UIButton (ULK_XMLParser)

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

@end


@implementation UIControl (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    id delegate = attrs[ULKViewAttributeActionTarget];
    if (delegate != nil) {
        NSString *onClickKeyPath = [attrs ulk_stringFromIDLValueForKey:@"onClickKeyPath"];
        NSString *onClickSelector = [attrs ulk_stringFromIDLValueForKey:@"onClick"];
        SEL selector = NULL;
        if (onClickSelector != nil && (selector = NSSelectorFromString(onClickSelector)) != NULL) {
            if ([onClickKeyPath length] > 0) {
                [self addTarget:[delegate valueForKeyPath:onClickKeyPath] action:selector forControlEvents:UIControlEventTouchUpInside];
            } else {
                [self addTarget:delegate action:selector forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

@end


@implementation UIImageView (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    NSString *imageRes = attrs[@"src"];
    ULKDrawableStateList *drawableStateList = [[ULKResourceManager currentResourceManager] drawableStateListForIdentifier:imageRes];
    if (drawableStateList != nil) {
        self.image = [drawableStateList imageForControlState:UIControlStateNormal];
        UIImage *highlightedImage = [drawableStateList imageForControlState:UIControlStateHighlighted];
        if (highlightedImage != nil) {
            self.highlightedImage = highlightedImage;
        }
    }
    
    NSString *scaleType = attrs[@"scaleType"];
    if (scaleType != nil) {
        if ([scaleType isEqualToString:@"center"]) {
            self.contentMode = UIViewContentModeCenter;
        } else if ([scaleType isEqualToString:@"centerCrop"]) {
            self.contentMode = UIViewContentModeScaleAspectFill;
            self.clipsToBounds = TRUE;
        } else if ([scaleType isEqualToString:@"centerInside"]) {
            self.contentMode = UIViewContentModeScaleAspectFit;
        } else if ([scaleType isEqualToString:@"fitXY"]) {
            self.contentMode = UIViewContentModeScaleToFill;
        } else if ([scaleType isEqualToString:@"top"]) {
            self.contentMode = UIViewContentModeTop;
        } else if ([scaleType isEqualToString:@"topLeft"]) {
            self.contentMode = UIViewContentModeTopLeft;
        } else if ([scaleType isEqualToString:@"topRight"]) {
            self.contentMode = UIViewContentModeTopRight;
        } else if ([scaleType isEqualToString:@"left"]) {
            self.contentMode = UIViewContentModeLeft;
        } else if ([scaleType isEqualToString:@"right"]) {
            self.contentMode = UIViewContentModeRight;
        } else if ([scaleType isEqualToString:@"bottom"]) {
            self.contentMode = UIViewContentModeBottom;
        } else if ([scaleType isEqualToString:@"bottomLeft"]) {
            self.contentMode = UIViewContentModeBottomLeft;
        } else if ([scaleType isEqualToString:@"bottomRight"]) {
            self.contentMode = UIViewContentModeBottomRight;
        }
    }
}

@end


@implementation UILabel (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    
    self.text = [attrs ulk_stringFromIDLValueForKey:@"text"];
    
    ULKGravity gravity = [ULKGravityUtility gravityFromAttribute:attrs[@"gravity"]];
    if ((gravity & ULKGravityRight) == ULKGravityRight) {
        self.textAlignment = NSTextAlignmentRight;
    }
    else if ((gravity & ULKGravityCenterHorizontal) == ULKGravityCenterHorizontal) {
        self.textAlignment = NSTextAlignmentCenter;
    }
    else if ((gravity & ULKGravityFillHorizontal) == ULKGravityFillHorizontal) {
        self.textAlignment = NSTextAlignmentJustified;
    }
    else {
        self.textAlignment = NSTextAlignmentLeft;
    }
    
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

@end

UIBarStyle ULKUIBarStyleFromString(NSString *barStyle) {
    UIBarStyle ret = UIBarStyleDefault;
    if ([barStyle isEqualToString:@"black"]) {
        ret = UIBarStyleBlack;
    } else if ([barStyle isEqualToString:@"default"]) {
        ret = UIBarStyleDefault;
    }
    return ret;
}

@implementation UINavigationBar (ULK_XMLParser)

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

@end


@implementation UISearchBar (ULK_XMLParser)

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

@end


@implementation UISwitch (ULK_XMLParser)

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

@end


@implementation UIToolbar (ULK_XMLParser)

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

@end


@implementation UIWebView (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    NSString *src = attrs[@"src"];
    if (src != nil) {
        NSURL *url = [NSURL URLWithString:src];
        [self loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end


@implementation ULKLinearLayout (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    self.gravity = [ULKGravityUtility gravityFromAttribute:attrs[@"gravity"]];
    NSString *orientationString = attrs[@"orientation"];
    if ([orientationString isEqualToString:@"horizontal"]) {
        self.orientation = LinearLayoutOrientationHorizontal;
    } else {
        self.orientation = LinearLayoutOrientationVertical;
    }
}

@end

