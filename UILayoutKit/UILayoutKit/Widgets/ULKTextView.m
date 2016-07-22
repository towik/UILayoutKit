//
//  ULKTextView.m
//  UILayoutKit
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKTextView.h"
#import "UIView+ULK_Layout.h"
#import "UILabel+ULK_View.h"

@implementation ULKTextView

- (void)setText:(NSString *)text {
    [super setText:text];
    [self ulk_requestLayout];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self ulk_requestLayout];
}

@end
