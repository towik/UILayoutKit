//
//  LinearLayoutLayoutParams.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKLinearLayoutParams.h"


@implementation ULKLinearLayoutParams

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height {
	self = [super initWithWidth:width height:height];
	if (self != nil) {
		
	}
	return self;
}

- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams {
    self = [super initWithLayoutParams:layoutParams];
    if (self) {
        if ([layoutParams isKindOfClass:[ULKLinearLayoutParams class]]) {
            ULKLinearLayoutParams *otherLP = (ULKLinearLayoutParams *)layoutParams;
            self.gravity = otherLP.gravity;
            self.weight = otherLP.weight;
        }
    }
    return self;
}

@end


@implementation UIView (ULK_LinearLayoutParams)

- (void)setLinearLayoutParams:(ULKLinearLayoutParams *)linearLayoutParams {
    self.layoutParams = linearLayoutParams;
}

- (ULKLinearLayoutParams *)linearLayoutParams {
    ULKLayoutParams *layoutParams = self.layoutParams;
    if (![layoutParams isKindOfClass:[ULKLinearLayoutParams class]]) {
        layoutParams = [[ULKLinearLayoutParams alloc] initWithLayoutParams:layoutParams];
        self.layoutParams = layoutParams;
    }
    
    return (ULKLinearLayoutParams *)layoutParams;
}

- (void)setLayoutWeight:(float)layoutWeight {
    self.linearLayoutParams.weight = layoutWeight;
    [self ulk_requestLayout];
}

- (float)layoutWeight {
    return self.linearLayoutParams.weight;
}

@end
