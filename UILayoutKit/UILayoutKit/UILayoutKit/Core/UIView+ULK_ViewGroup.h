//
//  UIView+ULK_ViewGroup.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ULK_Layout.h"

@interface UIView (ULK_ViewGroup)

- (ULKLayoutParams *)ulk_generateDefaultLayoutParams;
- (ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)lp;
- (ULKLayoutParams *)ulk_generateLayoutParamsFromAttributes:(NSDictionary *)attrs;
- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams;
- (ULKLayoutMeasureSpec)ulk_childMeasureSpecWithMeasureSpec:(ULKLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension;

- (void)ulk_measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed;
-(void)ulk_measureChild:(UIView *)child withParentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec;
- (UIView *)ulk_findViewTraversal:(NSString *)identifier;

@property (nonatomic, readonly) BOOL ulk_isViewGroup;

@end
