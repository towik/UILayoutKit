//
//  UITextView+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UITextView+ULK_View.h"
#import "UIView+ULK_ViewGroup.h"

@implementation UITextView (ULK_View)

- (void)setUlk_padding:(UIEdgeInsets)padding {
    [super setUlk_padding:padding];
    self.contentInset = padding;
}

- (BOOL)ulk_isViewGroup {
    return FALSE;
}

- (void)ulk_setText:(NSString *)text {
    [self setText:text];
    [self ulk_requestLayout];
}

- (void)ulk_setFont:(UIFont *)font {
    [self setFont:font];
    [self ulk_requestLayout];
}

@end