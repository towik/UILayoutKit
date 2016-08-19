//
//  Gravity.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDefine.h"


NSString *const ULKViewAttributeActionTarget = @"__actionTarget";

ULKLayoutMeasureSpec ULKLayoutMeasureSpecMake(CGFloat size, ULKLayoutMeasureSpecMode mode) {
    ULKLayoutMeasureSpec measureSpec;
    measureSpec.size = size;
    measureSpec.mode = mode;
    return measureSpec;
}

ULKLayoutMeasuredSize ULKLayoutMeasuredSizeMake(ULKLayoutMeasuredDimension width, ULKLayoutMeasuredDimension height) {
    ULKLayoutMeasuredSize ret = {width, height};
    return ret;
}


