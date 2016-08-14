//
//  LayoutParams.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ULKLayoutParamsSize {
    ULKLayoutParamsSizeMatchParent = -1,
    ULKLayoutParamsSizeWrapContent = -2
};


@interface ULKLayoutParams : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) UIEdgeInsets margin;

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams;
- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs NS_DESIGNATED_INITIALIZER;

@end


@interface UIView (ULKLayoutParams)

@property (nonatomic, assign) CGFloat layoutWidth;
@property (nonatomic, assign) CGFloat layoutHeight;
@property (nonatomic, assign) UIEdgeInsets layoutMargin;
@property (nonatomic, strong) ULKLayoutParams *layoutParams;

@end