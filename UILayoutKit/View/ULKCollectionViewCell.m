//
//  ULKCollectionViewCell.m
//  UILayoutKit
//
//  Created by Tom Quist on 06.12.14.
//  Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import "ULKCollectionViewCell.h"
#import "ULKLayoutBridge.h"
#import "ULKLayoutInflater.h"

@implementation ULKCollectionViewCell


- (CGSize)sizeThatFits:(CGSize)size {
    return [self.layoutBridge sizeThatFits:size];
}

- (CGSize)preferredSize {
    [self.layoutBridge ulk_measureWithWidthMeasureSpec:ULKLayoutMeasureSpecMake(CGFLOAT_MAX, ULKLayoutMeasureSpecModeAtMost) heightMeasureSpec:ULKLayoutMeasureSpecMake(CGFLOAT_MAX, ULKLayoutMeasureSpecModeAtMost)];
    return self.layoutBridge.ulk_measuredSize;
}

- (CGFloat)requiredWidthForHeight:(CGFloat)height {
    [self.layoutBridge ulk_measureWithWidthMeasureSpec:ULKLayoutMeasureSpecMake(CGFLOAT_MAX, ULKLayoutMeasureSpecModeAtMost) heightMeasureSpec:ULKLayoutMeasureSpecMake(height, ULKLayoutMeasureSpecModeExactly)];
    return self.layoutBridge.ulk_measuredSize.width;
}

- (CGFloat)requiredHeightForWidth:(CGFloat)width {
    [self.layoutBridge ulk_measureWithWidthMeasureSpec:ULKLayoutMeasureSpecMake(width, ULKLayoutMeasureSpecModeExactly) heightMeasureSpec:ULKLayoutMeasureSpecMake(CGFLOAT_MAX, ULKLayoutMeasureSpecModeAtMost)];
    return self.layoutBridge.ulk_measuredSize.height;
}

- (instancetype)initWithLayoutURL:(NSURL *)url {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        ULKLayoutBridge *bridge = [[ULKLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        self.contentView.translatesAutoresizingMaskIntoConstraints = TRUE;
        ULKLayoutInflater *inflater = [[ULKLayoutInflater alloc] init];
        [inflater inflateURL:url intoRootView:bridge attachToRoot:TRUE];

        _layoutBridge = bridge;
    }
    return self;
}

- (instancetype)initWithLayoutResource:(NSString *)resource {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        ULKLayoutBridge *bridge = [[ULKLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        ULKLayoutInflater *inflater = [[ULKLayoutInflater alloc] init];
        self.contentView.translatesAutoresizingMaskIntoConstraints = TRUE;
        [inflater inflateResource:resource intoRootView:bridge attachToRoot:YES];

        _layoutBridge = bridge;
    }
    return self;
}

@end
