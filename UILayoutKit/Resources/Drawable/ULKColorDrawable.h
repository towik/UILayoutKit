//
//  ULKColorDrawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKDrawable.h"

@interface ULKColorDrawable : ULKDrawable

- (instancetype)initWithColor:(UIColor *)color;

@property (strong, nonatomic, readonly) UIColor *color;

@end

@interface ULKColorDrawableConstantState : ULKDrawableConstantState

@end