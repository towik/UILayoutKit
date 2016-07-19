//
//  UIView+ULKDrawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ULKDrawable.h"

@interface UIView (ULKDrawable)

@property (nonatomic, retain) ULKDrawable *ulk_backgroundDrawable;

- (void)ulk_onBackgroundDrawableChanged;

@end
