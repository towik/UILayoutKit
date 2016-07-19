//
//  ULKResourceStateItem.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKResourceStateItem.h"

@interface ULKResourceStateItem ()

@property (nonatomic, assign) UIControlState internalControlState;

@end

@implementation ULKResourceStateItem

- (instancetype)initWithControlState:(UIControlState)controlState {
    self = [super init];
    if (self) {
        self.internalControlState = controlState;
    }
    return self;
}

- (UIControlState)controlState {
    return self.internalControlState;
}

@end
