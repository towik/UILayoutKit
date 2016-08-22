//
//  LayoutBridge.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKLayoutBridge.h"
#import "UIView+ULK_Layout.h"
#import "ULKLayoutInflater.h"

@implementation UIView (ULKLayoutBridge)

- (UIView *)findAndScrollToFirstResponder {
    UIView *ret = nil;
    if (self.isFirstResponder) {
        ret = self;
    }
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findAndScrollToFirstResponder];
        if (firstResponder) {
            if ([self isKindOfClass:[UIScrollView class]]) {
                UIScrollView *sv = (UIScrollView *)self;
                CGRect r = [self convertRect:firstResponder.frame fromView:firstResponder];
                [sv scrollRectToVisible:r animated:FALSE];
                ret = self;
            } else {
                ret = firstResponder;
            }
            break;
        }
    }
    return ret;
}

@end

@implementation ULKLayoutBridge {
    BOOL _resizeOnKeyboard;
    BOOL _scrollToTextField;
}

- (void)dealloc {
	if (_resizeOnKeyboard) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    if (_scrollToTextField) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    }
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIView *lastChild = self.subviews.lastObject;
    ULKLayoutParams *layoutParams = (ULKLayoutParams *)lastChild.ulk_layoutParams;
    ULKLayoutMeasureSpec widthSpec;
    ULKLayoutMeasureSpec heightSpec;
    widthSpec.mode = ULKLayoutMeasureSpecModeUnspecified;
    widthSpec.size = size.width;
    heightSpec.mode = ULKLayoutMeasureSpecModeUnspecified;
    heightSpec.size = size.height;
    if (layoutParams.width == ULKLayoutParamsSizeMatchParent) {
        widthSpec.mode = ULKLayoutMeasureSpecModeExactly;
    }
    if (layoutParams.height == ULKLayoutParamsSizeMatchParent) {
        heightSpec.mode = ULKLayoutMeasureSpecModeExactly;
    }
    [self ulk_measureWithWidthMeasureSpec:widthSpec heightMeasureSpec:heightSpec];
    return self.ulk_measuredSize;
}

- (void)addSubview:(UIView *)view {
    for (UIView *subviews in [self subviews]) {
        [subviews removeFromSuperview];
    }
    [super addSubview:view];
}

- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    UIView *firstChild = [self.subviews lastObject];
    if (firstChild != nil) {
        CGSize size = firstChild.ulk_measuredSize;
        ULKLayoutParams *lp = (ULKLayoutParams *)firstChild.ulk_layoutParams;
        UIEdgeInsets margin = lp.margin;
        [firstChild ulk_setFrame:CGRectMake(margin.left, margin.top, size.width, size.height)];
    }
}

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    CGSize lastChildSize = CGSizeZero;
    UIView *lastChild = self.subviews.lastObject;
    if (lastChild.ulk_visibility != ULKViewVisibilityGone)
    {
        [self ulk_measureChildWithMargins:lastChild parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
        lastChildSize = lastChild.ulk_measuredSize;
        ULKLayoutParams *layoutParams = lastChild.ulk_layoutParams;
        if ([layoutParams isKindOfClass:[ULKLayoutParams class]])
        {
            ULKLayoutParams *marginParams = (ULKLayoutParams *)layoutParams;
            lastChildSize.width += marginParams.margin.left + marginParams.margin.right;
            lastChildSize.height += marginParams.margin.top + marginParams.margin.bottom;
        }
    }
    ULKLayoutMeasuredDimension width;
    ULKLayoutMeasuredDimension height;
    width.state = ULKLayoutMeasuredStateNone;
    height.state = ULKLayoutMeasuredStateNone;
    UIEdgeInsets padding = self.ulk_padding;
    width.size = lastChildSize.width + padding.left + padding.right;
    height.size = lastChildSize.height + padding.top + padding.bottom;
    [self ulk_setMeasuredDimensionSize:ULKLayoutMeasuredSizeMake(width, height)];
}

- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams {
    return [layoutParams isKindOfClass:[ULKLayoutParams class]];
}

-(ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)layoutParams {
    return [[ULKLayoutParams alloc] initWithLayoutParams:layoutParams];
}

- (void)willShowKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbLocalFrame = [self convertRect:keyboardFrame fromView:self.window];
    NSLog(@"Show: %@", NSStringFromCGRect(kbLocalFrame));
    CGRect f = self.frame;
    f.size.height = kbLocalFrame.origin.y;
    self.frame = f;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
        
    }];
}

- (void)didShowKeyboard:(NSNotification *)notification {

}

- (void)willHideKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbLocalFrame = [self convertRect:keyboardFrame fromView:self.window];
    NSLog(@"Hide: %@", NSStringFromCGRect(kbLocalFrame));
    CGRect f = self.frame;
    f.size.height = kbLocalFrame.origin.y;
    self.frame = f;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)didBeginEditing:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        [self findAndScrollToFirstResponder];        
    }];
}

- (void)didEndEditing:(NSNotification *)notification {
    
}

- (void)setScrollToTextField:(BOOL)scrollToTextField {
    if (scrollToTextField && !_scrollToTextField) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [center addObserver:self selector:@selector(didEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        [center addObserver:self selector:@selector(didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [center addObserver:self selector:@selector(didEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    } else if (!scrollToTextField && _scrollToTextField) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    }
    _scrollToTextField = scrollToTextField;
}

- (void)setResizeOnKeyboard:(BOOL)resizeOnKeyboard {
    if (resizeOnKeyboard && !_resizeOnKeyboard) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    } else if (!resizeOnKeyboard && _resizeOnKeyboard) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    _resizeOnKeyboard = resizeOnKeyboard;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"layout"]) {
        NSString *pathExtension = [value pathExtension];
        if ([pathExtension length] == 0) {
            pathExtension = @"xml";
        }
        NSURL *url = [[NSBundle mainBundle] URLForResource:[value stringByDeletingPathExtension] withExtension:pathExtension];
        if (url != nil) {
            ULKLayoutInflater *inflater = [[ULKLayoutInflater alloc] init];
            [inflater inflateURL:url intoRootView:self attachToRoot:TRUE];
        }
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end
