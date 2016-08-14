//
//  UIScrollView+ULK_ViewGroup.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "UIScrollView+ULK_ViewGroup.h"
#import "UIView+ULK_Layout.h"
#import "ULKLayoutParams.h"
#import "UIView+ULK_ViewGroup.h"
#import "NSObject+ULK_KVOObserver.h"
#import "ULKFrameLayout.h"

#pragma mark - import libs
#include <objc/runtime.h>

#pragma mark -

@implementation UIScrollView (ULK_ViewGroup)

//+ (void)load {
//    Class c = self;
//    SEL origSEL = @selector(drawRect:);
//    SEL overrideSEL = @selector(ulk_drawRect:);
//    Method origMethod = class_getInstanceMethod(c, origSEL);
//    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
//    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
//        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
//    } else {
//        method_exchangeImplementations(origMethod, overrideMethod);
//    }
//}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    [ULKFrameLayout onFrameLayoutMeasure:self widthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
}

- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    self.contentSize = [ULKFrameLayout onFrameLayoutLayout:self frame:frame didFrameChange:changed];
}

- (void)ulk_measureChild:(UIView *)child withParentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec {
    if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
        return;
    }
    ULKLayoutParams *lp = child.layoutParams;
    
    ULKLayoutMeasureSpec childWidthMeasureSpec;
    ULKLayoutMeasureSpec childHeightMeasureSpec;
    
    UIEdgeInsets padding = self.ulk_padding;
    childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:padding.left + padding.right childDimension:lp.width];
    
    childHeightMeasureSpec.size = 0;
    childHeightMeasureSpec.mode = ULKLayoutMeasureSpecModeUnspecified;
    
    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

//- (void)ulk_measureChildWithMargins:(UIView *)child parentWidthMeasureSpec:(ULKLayoutMeasureSpec)parentWidthMeasureSpec widthUsed:(CGFloat)widthUsed parentHeightMeasureSpec:(ULKLayoutMeasureSpec)parentHeightMeasureSpec heightUsed:(CGFloat)heightUsed {
//    if ([NSStringFromClass([child class]) isEqualToString:@"UIWebDocumentView"]) {
//        return;
//    }
//    ULKLayoutParams *lp = (ULKLayoutParams *)child.layoutParams;
//    UIEdgeInsets lpMargin = lp.margin;
//    UIEdgeInsets padding = self.ulk_padding;
//    ULKLayoutMeasureSpec childWidthMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:parentWidthMeasureSpec padding:(padding.left + padding.right + lpMargin.left + lpMargin.right + widthUsed) childDimension:lp.width];
//    ULKLayoutMeasureSpec childHeightMeasureSpec;
//    childHeightMeasureSpec.size = lpMargin.top + lpMargin.bottom + parentHeightMeasureSpec.size;
//    childHeightMeasureSpec.mode = ULKLayoutMeasureSpecModeUnspecified;
//    
//    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
//}

- (BOOL)ulk_isViewGroup {
    BOOL ret = FALSE;
    if ([self class] == [UIScrollView class] || [NSStringFromClass([self class]) hasSuffix:@"UIScrollView"]) {
        ret = TRUE;
    }
    return ret;
}

- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams {
    return [layoutParams isKindOfClass:[ULKFrameLayoutParams class]];
}

- (ULKLayoutParams *)ulk_generateDefaultLayoutParams {
    return [[ULKFrameLayoutParams alloc] initWithWidth:ULKLayoutParamsSizeMatchParent height:ULKLayoutParamsSizeMatchParent];
}

-(ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)layoutParams {
    return [[ULKFrameLayoutParams alloc] initWithLayoutParams:layoutParams];
}

@end
