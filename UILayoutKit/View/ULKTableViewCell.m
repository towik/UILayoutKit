//
//  ULKTableViewCell.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKTableViewCell.h"
#import "ULKLayoutInflater.h"

@implementation ULKTableViewCell

- (instancetype)initWithLayoutURL:(NSURL *)url reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        ULKLayoutBridge *bridge = [[ULKLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        ULKLayoutInflater *inflater = [[ULKLayoutInflater alloc] init];
        [inflater inflateURL:url intoRootView:bridge attachToRoot:TRUE];

        _layoutBridge = bridge;
    }
    return self;
}

- (instancetype)initWithLayoutResource:(NSString *)resource reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        ULKLayoutBridge *bridge = [[ULKLayoutBridge alloc] initWithFrame:self.contentView.bounds];
        bridge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:bridge];
        ULKLayoutInflater *inflater = [[ULKLayoutInflater alloc] init];
        [inflater inflateResource:resource intoRootView:bridge attachToRoot:TRUE];

        _layoutBridge = bridge;
    }
    return self;
}

- (BOOL)ulk_isViewGroup {
    return TRUE;
}

- (CGFloat)requiredHeightInView:(UIView *)view {
    [self.layoutBridge ulk_measureWithWidthMeasureSpec:ULKLayoutMeasureSpecMake(view.bounds.size.width, ULKLayoutMeasureSpecModeExactly) heightMeasureSpec:ULKLayoutMeasureSpecMake(CGFLOAT_MAX, ULKLayoutMeasureSpecModeAtMost)];
    return self.layoutBridge.ulk_measuredSize.height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.layoutBridge sizeThatFits:size];
}

@end
