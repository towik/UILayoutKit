//
//  UIControl+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UIControl+ULK_View.h"
#import "UIView+ULK_Layout.h"
#import "NSDictionary+ULK_ResourceManager.h"

@implementation UIControl (ULK_View)

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

- (void)setUlk_gravity:(ULKViewContentGravity)gravity {
    if ((gravity & ULKViewContentGravityTop) == ULKViewContentGravityTop) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    } else if ((gravity & ULKViewContentGravityBottom) == ULKViewContentGravityBottom) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    } else if ((gravity & ULKViewContentGravityFillVertical) == ULKViewContentGravityFillVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    } else if ((gravity & ULKViewContentGravityCenterVertical) == ULKViewContentGravityCenterVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    if ((gravity & ULKViewContentGravityLeft) == ULKViewContentGravityLeft) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    } else if ((gravity & ULKViewContentGravityRight) == ULKViewContentGravityRight) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    } else if ((gravity & ULKViewContentGravityFillHorizontal) == ULKViewContentGravityFillHorizontal) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    } else if ((gravity & ULKViewContentGravityCenterHorizontal) == ULKViewContentGravityCenterHorizontal) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
}

- (ULKViewContentGravity)ulk_gravity {
    ULKViewContentGravity ret = ULKViewContentGravityNone;
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            ret |= ULKViewContentGravityTop;
            break;
        case UIControlContentVerticalAlignmentBottom:
            ret |= ULKViewContentGravityBottom;
            break;
        case UIControlContentVerticalAlignmentCenter:
            ret |= ULKViewContentGravityCenterVertical;
            break;
        case UIControlContentVerticalAlignmentFill:
            ret |= ULKViewContentGravityFillVertical;
            break;
    }
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft:
            ret |= ULKViewContentGravityLeft;
            break;
        case UIControlContentHorizontalAlignmentRight:
            ret |= ULKViewContentGravityRight;
            break;
        case UIControlContentHorizontalAlignmentCenter:
            ret |= ULKViewContentGravityCenterHorizontal;
            break;
        case UIControlContentHorizontalAlignmentFill:
            ret |= ULKViewContentGravityFillHorizontal;
            break;
    }
    return ret;
}

@end
 