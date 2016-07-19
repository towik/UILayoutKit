//
//  FrameLayoutLayoutParams.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKLayoutParams.h"
#import "ULKGravity.h"

@interface ULKFrameLayoutParams : ULKLayoutParams

@property (nonatomic, assign) ULKViewContentGravity gravity;

@end


@interface UIView (ULK_FrameLayoutParams)

@property (nonatomic, assign) ULKViewContentGravity ulk_layoutGravity;

@end
