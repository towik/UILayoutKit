//
//  UIImageView+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UIImageView+ULK_View.h"
#import "UIView+ULK_Layout.h"

@implementation UIImageView (ULK_View)

- (BOOL)ulk_isImageScaling {
    return self.contentMode == UIViewContentModeScaleAspectFill || self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeScaleToFill;
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    CGSize imageSize = self.image.size;
    ULKLayoutMeasuredSize measuredSize;
    measuredSize.width.size = imageSize.width;
    measuredSize.width.state = ULKLayoutMeasuredStateNone;
    measuredSize.height.size = imageSize.height;
    measuredSize.height.state = ULKLayoutMeasuredStateNone;
    //UIEdgeInsets padding = self.padding;
    switch (widthMode) {
        case ULKLayoutMeasureSpecModeExactly: {
            measuredSize.width.size = widthSize;
            if ([self ulk_isImageScaling]) {
                if (imageSize.width <= 0.f) {
                    measuredSize.height.size = 0;
                } else {
                    measuredSize.height.size = (measuredSize.width.size/imageSize.width)*imageSize.height;
                }
            }
            break;
        }
        case ULKLayoutMeasureSpecModeAtMost: {
            if (widthSize < imageSize.width) {
                measuredSize.width.size = widthSize;
                if ([self ulk_isImageScaling]) {
                    if (imageSize.width <= 0.f) {
                        measuredSize.height.size = 0.f;
                    } else {
                        measuredSize.height.size = (measuredSize.width.size/imageSize.width)*imageSize.height;
                    }
                }
            }
            break;
        }
        case ULKLayoutMeasureSpecModeUnspecified:
        default:
            break;
    }
    switch (heightMode) {
        case ULKLayoutMeasureSpecModeExactly:
            measuredSize.height.size = heightSize;
            break;
        case ULKLayoutMeasureSpecModeAtMost:
            measuredSize.height.size = MIN(heightSize, measuredSize.height.size);
            break;
        case ULKLayoutMeasureSpecModeUnspecified:
        default:
            break;
    }
    //if (widthMode == ULKLayoutMeasureSpecModeAtMost || widthMode == ULKLayoutMeasureSpecModeUnspecified) {
//    measuredSize.width.size = MIN(measuredSize.width.size, (imageSize.height>0.f?(measuredSize.height.size/imageSize.height) * imageSize.width:0.f));
    //}
    [self ulk_setMeasuredDimensionSize:measuredSize];
}

@end
