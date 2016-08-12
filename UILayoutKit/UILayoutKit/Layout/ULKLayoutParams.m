//
//  LayoutParams.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKLayoutParams.h"
#import "UIView+ULK_Layout.h"

#pragma mark - import libs
#include <objc/runtime.h>

#pragma mark -

#define LAYOUT_SIZE_MATCH_PARENT @"match_parent"
#define LAYOUT_SIZE_FILL_PARENT @"fill_parent"
#define LAYOUT_SIZE_WRAP_CONTENT @"wrap_content"


@implementation ULKLayoutParams

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height {
    self = [super init];
    if (self) {
        _width = width;
        _height = height;
    }
    return self;
}

+ (CGFloat)sizeForLayoutSizeAttribute:(NSString *)sizeAttr {
    CGFloat ret = 0;
    if ([sizeAttr isEqualToString:LAYOUT_SIZE_MATCH_PARENT] || [sizeAttr isEqualToString:LAYOUT_SIZE_FILL_PARENT]) {
        ret = ULKLayoutParamsSizeMatchParent;
    } else if ([sizeAttr isEqualToString:LAYOUT_SIZE_WRAP_CONTENT]) {
        ret = ULKLayoutParamsSizeWrapContent;
    } else {
        ret = [sizeAttr floatValue];
    }
    return ret;
}

- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams {
    self = [super init];
    if (self) {
        _width = layoutParams.width;
        _height = layoutParams.height;
        _margin = layoutParams.margin;
    }
    return self;
}

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs {
    self = [super init];
    if (self) {
        NSString *widthAttr = attrs[@"layout_width"];
        NSString *heightAttr = attrs[@"layout_height"];
//        if (widthAttr == nil || heightAttr == nil) {
//            NSAssert(0, @"You have to set the layout_width and layout_height parameters.");
//            return nil;
//        }
        _width = [ULKLayoutParams sizeForLayoutSizeAttribute:widthAttr];
        _height = [ULKLayoutParams sizeForLayoutSizeAttribute:heightAttr];
        
        NSString *marginString = attrs[@"layout_margin"];
        if (marginString != nil) {
            CGFloat margin = [marginString floatValue];
            _margin = UIEdgeInsetsMake(margin, margin, margin, margin);
        } else {
            NSString *marginLeftString = attrs[@"layout_marginLeft"];
            NSString *marginTopString = attrs[@"layout_marginTop"];
            NSString *marginBottomString = attrs[@"layout_marginBottom"];
            NSString *marginRightString = attrs[@"layout_marginRight"];
            _margin = UIEdgeInsetsMake([marginTopString floatValue], [marginLeftString floatValue], [marginBottomString floatValue], [marginRightString floatValue]);
        }
    }
    return self;
}

@end


@implementation UIView (ULKLayoutParams)

static char layoutParamsKey;


- (void)setLayoutParams:(ULKLayoutParams *)layoutParams {
    objc_setAssociatedObject(self,
                             &layoutParamsKey,
                             layoutParams,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self ulk_requestLayout];
    
}

- (ULKLayoutParams *)layoutParams {
    ULKLayoutParams *layoutParams = objc_getAssociatedObject(self, &layoutParamsKey);
    
//    if (![layoutParams isKindOfClass:[ULKLayoutParams class]]) {
//        layoutParams = [[ULKLayoutParams alloc] initWithLayoutParams:layoutParams];
//        self.layoutParams = layoutParams;
//    }
    
    return (ULKLayoutParams *)layoutParams;
}

- (void)setLayoutWidth:(CGFloat)layoutWidth {
    self.layoutParams.width = layoutWidth;
    [self ulk_requestLayout];
}

- (CGFloat)layoutWidth {
    return self.layoutParams.width;
}

- (void)setLayoutHeight:(CGFloat)layoutHeight {
    self.layoutParams.height = layoutHeight;
    [self ulk_requestLayout];
}

- (CGFloat)layoutHeight {
    return self.layoutParams.height;
}

- (void)setLayoutMargin:(UIEdgeInsets)layoutMargin {
    self.layoutParams.margin = layoutMargin;
    [self ulk_requestLayout];
}

- (UIEdgeInsets)layoutMargin {
    return self.layoutParams.margin;
}

@end
