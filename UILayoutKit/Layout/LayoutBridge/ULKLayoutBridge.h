//
//  LayoutBridge.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKLinearLayout.h"

@interface ULKLayoutBridge : ULKViewGroup

@property (nonatomic, assign, getter = isResizingOnKeyboard) BOOL resizeOnKeyboard;
@property (nonatomic, assign, getter = isScrollingToTextField) BOOL scrollToTextField;

@end
