//
//  ULKFrameLayout.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKViewGroup.h"
#import "ULKFrameLayoutParams.h"

@interface ULKFrameLayout : ULKViewGroup

+ (void)onFrameLayoutMeasure:(UIView *)measureView widthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec
                             heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec;

+ (CGSize)onFrameLayoutLayout:(UIView *)measureView frame:(CGRect)frame didFrameChange:(BOOL)changed;

@end