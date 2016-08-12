//
//  FrameLayoutLayoutParams.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKFrameLayoutParams.h"
#import "UIView+ULK_Layout.h"

@implementation ULKFrameLayoutParams

- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams {
    self = [super initWithLayoutParams:layoutParams];
    if (self) {
        if ([layoutParams isKindOfClass:[ULKFrameLayoutParams class]]) {
            ULKFrameLayoutParams *otherLP = (ULKFrameLayoutParams *)layoutParams;
            self.gravity = otherLP.gravity;
        }
    }
    return self;
}

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs {
    self = [super initUlk_WithAttributes:attrs];
    if (self) {
        NSString *gravityString = attrs[@"layout_gravity"];
        _gravity = [ULKGravity gravityFromAttribute:gravityString];
    }
    return self;
}

@end


@implementation UIView (ULK_FrameLayoutParams)

- (void)setFrameLayoutParams:(ULKFrameLayoutParams *)frameLayoutParams {
    self.layoutParams = frameLayoutParams;
}

- (ULKFrameLayoutParams *)frameLayoutParams {
    ULKLayoutParams *layoutParams = self.layoutParams;
    if (![layoutParams isKindOfClass:[ULKFrameLayoutParams class]]) {
        layoutParams = [[ULKFrameLayoutParams alloc] initWithLayoutParams:layoutParams];
        self.layoutParams = layoutParams;
    }
    
    return (ULKFrameLayoutParams *)layoutParams;
}

- (void)setUlk_layoutGravity:(ULKViewContentGravity)layoutGravity {
    self.frameLayoutParams.gravity = layoutGravity;
    [self ulk_requestLayout];
}

- (ULKViewContentGravity)ulk_layoutGravity {
    return self.frameLayoutParams.gravity;
}

@end
