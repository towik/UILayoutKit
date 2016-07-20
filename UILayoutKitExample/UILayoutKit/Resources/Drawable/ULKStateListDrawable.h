//
//  ULKStateListDrawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawableContainer.h"
#import "ULKColorStateList.h"

@interface ULKStateListDrawable : ULKDrawableContainer

- (instancetype)initWithColorStateListe:(ULKColorStateList *)colorStateList;

@end

@interface ULKStateListDrawableConstantState : ULKDrawableContainerConstantState

@end