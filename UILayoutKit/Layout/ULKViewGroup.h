//
//  ViewGroup.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ULKLayoutParams.h"
#import "UIView+ULK_Layout.h"
#import "UIView+ULK_ViewGroup.h"

@interface ULKViewGroup : UIView

+ (ULKLayoutMeasureSpec)childMeasureSpecForMeasureSpec:(ULKLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension;

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs NS_DESIGNATED_INITIALIZER;

@end
