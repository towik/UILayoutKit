//
//  RelativeLayoutLayoutParams.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKRelativeLayoutParams.h"
#import "UIView+ULK_Layout.h"

@interface ULKRelativeLayoutParams ()

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

@implementation ULKRelativeLayoutParams

@end


@implementation UIView (ULK_RelativeLayoutParams)

- (void)setRelativeLayoutParams:(ULKRelativeLayoutParams *)relativeLayoutLayoutParams {
    self.layoutParams = relativeLayoutLayoutParams;
}

- (ULKRelativeLayoutParams *)relativeLayoutParams {
    ULKLayoutParams *layoutParams = self.layoutParams;
    if (![layoutParams isKindOfClass:[ULKRelativeLayoutParams class]]) {
        layoutParams = [[ULKRelativeLayoutParams alloc] initWithLayoutParams:layoutParams];
        self.layoutParams = layoutParams;
    }
    
    return (ULKRelativeLayoutParams *)layoutParams;
}

@end
