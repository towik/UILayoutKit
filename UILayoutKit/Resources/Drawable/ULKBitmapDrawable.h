//
//  ULKBitmapDrawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawable.h"
#import "ULKGravity.h"

@interface ULKBitmapDrawable : ULKDrawable

- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@end

@interface ULKBitmapDrawableConstantState : ULKDrawableConstantState

@end
