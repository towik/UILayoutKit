//
//  ULKDrawableStateItem.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawableStateItem.h"
#import "ULKResourceStateItem+ULK_Internal.h"
#import "ULKResourceManager.h"
#import "UIColor+ULK_ColorParser.h"
#import "UIImage+ULK_FromColor.h"

@interface ULKDrawableStateItem ()

@property (nonatomic, strong) NSString *resourceIdentifier;

@end

@implementation ULKDrawableStateItem


- (instancetype)initWithControlState:(UIControlState)controlState drawableResourceIdentifier:(NSString *)resourceIdentifier {
    self = [super initWithControlState:controlState];
    if (self) {
        self.resourceIdentifier = resourceIdentifier;
    }
    return self;
}

- (UIImage *)image {
    UIImage *ret = nil;
    if ([[ULKResourceManager currentResourceManager] isValidIdentifier:self.resourceIdentifier]) {
        ret = [[ULKResourceManager currentResourceManager] imageForIdentifier:self.resourceIdentifier];
    } else {
        // Try to parse color string
        UIColor *color = [UIColor ulk_colorFromIDLColorString:self.resourceIdentifier];
        if (color != nil) {
            ret = [UIImage ulk_imageFromColor:color withSize:CGSizeMake(1, 1)];
        }
    }
    return ret;
}

@end
