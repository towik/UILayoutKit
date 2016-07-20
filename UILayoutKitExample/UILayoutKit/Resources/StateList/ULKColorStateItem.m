//
//  ULKColorStateItem.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKColorStateItem.h"
#import "ULKResourceStateItem+ULK_Internal.h"
#import "ULKResourceManager.h"
#import "UIColor+ULK_ColorParser.h"

@interface ULKColorStateItem ()

@property (nonatomic, strong) NSString *resourceIdentifier;

@end

@implementation ULKColorStateItem


- (instancetype)initWithControlState:(UIControlState)controlState colorResourceIdentifier:(NSString *)resourceIdentifier {
    self = [super initWithControlState:controlState];
    if (self) {
        self.resourceIdentifier = resourceIdentifier;
    }
    return self;
}

- (UIColor *)color {
    UIColor *ret = nil;
    if ([[ULKResourceManager currentResourceManager] isValidIdentifier:self.resourceIdentifier]) {
        ret = [[ULKResourceManager currentResourceManager] colorForIdentifier:self.resourceIdentifier];
    } else {
        ret = [UIColor ulk_colorFromIDLColorString:self.resourceIdentifier];
    }
    return ret;
}

@end
