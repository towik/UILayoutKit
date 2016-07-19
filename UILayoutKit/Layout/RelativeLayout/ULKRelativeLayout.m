//
//  RelativeLayout.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKRelativeLayout.h"
#import "ULKDependencyGraphNode.h"


@interface ULKRelativeLayoutParams ()

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

@implementation ULKRelativeLayout {
    NSMutableArray *_sortedVerticalChildren;
    NSMutableArray *_sortedHorizontalChildren;
    ULKDependencyGraph *_graph;
    UIView *_baselineView;
    CGRect _selfBounds;
    CGRect _contentBounds;
    
    BOOL _dirtyHierarchy;
    BOOL _hasBaselineAlignedChild;
}

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    _gravity = [ULKGravity gravityFromAttribute:attrs[@"gravity"]];
    _ignoreGravity = attrs[@"ignoreGravity"];
}

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs {
    self = [super initUlk_WithAttributes:attrs];
    if (self) {
        _dirtyHierarchy = TRUE;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dirtyHierarchy = TRUE;
        _graph = [[ULKDependencyGraph alloc] init];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dirtyHierarchy = TRUE;
    }
    return self;
}

- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams {
    return [layoutParams isKindOfClass:[ULKRelativeLayoutParams class]];
}

- (ULKLayoutParams *)ulk_generateDefaultLayoutParams {
    return [[ULKRelativeLayoutParams alloc] initWithWidth:ULKLayoutParamsSizeWrapContent height:ULKLayoutParamsSizeWrapContent];
}

- (ULKLayoutParams *)ulk_generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[ULKRelativeLayoutParams alloc] initUlk_WithAttributes:attrs];
}

- (ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)lp {
    return [[ULKRelativeLayoutParams alloc] initWithLayoutParams:lp];
}

- (void)sortChildren {
    NSUInteger count = [self.subviews count];
    if ([_sortedVerticalChildren count] != count) {
        if (_sortedVerticalChildren == nil) _sortedVerticalChildren = [[NSMutableArray alloc] initWithCapacity:count];
        else [_sortedVerticalChildren removeAllObjects];
        for (NSInteger i=0;i<count;i++) {
            [_sortedVerticalChildren addObject:[NSNull null]];
        }
    }
    if ([_sortedHorizontalChildren count] != count) {
        if (_sortedHorizontalChildren == nil) _sortedHorizontalChildren = [[NSMutableArray alloc] initWithCapacity:count];
        else [_sortedHorizontalChildren removeAllObjects];
        for (NSInteger i=0;i<count;i++) {
            [_sortedHorizontalChildren addObject:[NSNull null]];
        }
    }
    
    ULKDependencyGraph *graph = _graph;
    [graph clear];
    
    for (int i = 0; i < count; i++) {
        UIView *child = (self.subviews)[i];
        [graph addView:child];
    }
    
    [graph getSortedViews:_sortedVerticalChildren forRules:@[@(ULKRelativeLayoutRuleAbove), @(ULKRelativeLayoutRuleBelow), @(ULKRelativeLayoutRuleAlignBaseline), @(ULKRelativeLayoutRuleAlignTop), @(ULKRelativeLayoutRuleAlignBottom)]];
    [graph getSortedViews:_sortedHorizontalChildren forRules:@[@(ULKRelativeLayoutRuleLeftOf), @(ULKRelativeLayoutRuleRightOf), @(ULKRelativeLayoutRuleAlignLeft), @(ULKRelativeLayoutRuleAlignRight)]];
    
}

- (UIView *)relatedViewForRules:(NSArray *)rules relation:(ULKRelativeLayoutRule)relation {
    NSString *identifier = rules[relation];
    if (identifier != nil && ![identifier isKindOfClass:[NSNull class]]) {
        ULKDependencyGraphNode *node = _graph.keyNodes[identifier];
        if (node == nil) return nil;
        UIView *v = node.view;
        
        // Find the first non-GONE view up the chain
        while (v.ulk_visibility == ULKViewVisibilityGone) {
            rules = ((ULKRelativeLayoutParams *) v.layoutParams).rules;
            node = _graph.keyNodes[rules[relation]];
            if (node == nil) return nil;
            v = node.view;
        }
        
        return v;
    }
    
    return nil;
}

- (ULKRelativeLayoutParams *)relatedViewParamsWithRules:(NSArray *)rules relation:(ULKRelativeLayoutRule)relation {
    UIView *v = [self relatedViewForRules:rules relation:relation];
    if (v != nil) {
        ULKLayoutParams *params = v.layoutParams;
        if ([params isKindOfClass:[ULKRelativeLayoutParams class]]) {
            return (ULKRelativeLayoutParams *)v.layoutParams;
        }
    }
    return nil;
}

- (void)applyHorizontalSizeRulesWithChildLayoutParams:(ULKRelativeLayoutParams *)childParams myWidth:(CGFloat)myWidth {
    UIEdgeInsets childParamsMargin = childParams.margin;
    
    NSArray *rules = childParams.rules;
    ULKRelativeLayoutParams *anchorParams;
    
    // -1 indicated a "soft requirement" in that direction. For example:
    // left=10, right=-1 means the view must start at 10, but can go as far as it wants to the right
    // left =-1, right=10 means the view must end at 10, but can go as far as it wants to the left
    // left=10, right=20 means the left and right ends are both fixed
    childParams.left = -1;
    childParams.right = -1;
    UIEdgeInsets padding = self.ulk_padding;
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleLeftOf];
    if (anchorParams != nil) {
        childParams.right = anchorParams.left - (anchorParams.margin.left +
                                                 childParamsMargin.right);
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleLeftOf] != [NSNull null]) {
        if (myWidth >= 0) {
            childParams.right = myWidth - padding.right - childParamsMargin.right;
        } else {
            // FIXME uh oh...
        }
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleRightOf];
    if (anchorParams != nil) {
        childParams.left = anchorParams.right + (anchorParams.margin.right +
                                                 childParamsMargin.left);
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleRightOf] != [NSNull null]) {
        childParams.left = padding.left + childParamsMargin.left;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleAlignLeft];
    if (anchorParams != nil) {
        childParams.left = anchorParams.left + childParamsMargin.left;
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleAlignLeft] != [NSNull null]) {
        childParams.left = padding.left + childParamsMargin.left;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleAlignRight];
    if (anchorParams != nil) {
        childParams.right = anchorParams.right - childParamsMargin.right;
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleAlignRight] != [NSNull null]) {
        if (myWidth >= 0) {
            childParams.right = myWidth - padding.right - childParamsMargin.right;
        } else {
            // FIXME uh oh...
        }
    }
    
    id alignParentLeft = rules[ULKRelativeLayoutRuleAlignParentLeft];
    if ([NSNull null] != alignParentLeft && [alignParentLeft boolValue]) {
        childParams.left = padding.left + childParamsMargin.left;
    }
    
    id alignParentRight = rules[ULKRelativeLayoutRuleAlignParentRight];
    if ([NSNull null] != alignParentRight && [alignParentRight boolValue]) {
        if (myWidth >= 0) {
            childParams.right = myWidth - padding.right - childParamsMargin.right;
        } else {
            // FIXME uh oh...
        }
    }
}

/**
 * Get a measure spec that accounts for all of the constraints on this view.
 * This includes size contstraints imposed by the RelativeLayout as well as
 * the View's desired dimension.
 *
 * @param childStart The left or top field of the child's layout params
 * @param childEnd The right or bottom field of the child's layout params
 * @param childSize The child's desired size (the width or height field of
 *        the child's layout params)
 * @param startMargin The left or top margin
 * @param endMargin The right or bottom margin
 * @param startPadding mPaddingLeft or mPaddingTop
 * @param endPadding mPaddingRight or mPaddingBottom
 * @param mySize The width or height of this view (the RelativeLayout)
 * @return MeasureSpec for the child
 */
- (ULKLayoutMeasureSpec)childMeasureSpecForChildStart:(CGFloat)childStart childEnd:(CGFloat)childEnd childSize:(CGFloat)childSize startMargin:(CGFloat)startMargin endMargin:(CGFloat)endMargin startPadding:(CGFloat)startPadding endPadding:(CGFloat)endPadding mySize:(CGFloat)mySize {
    ULKLayoutMeasureSpecMode childSpecMode = ULKLayoutMeasureSpecModeUnspecified;
    CGFloat childSpecSize = 0.f;
    
    // Figure out start and end bounds.
    CGFloat tempStart = childStart;
    CGFloat tempEnd = childEnd;
    
    // If the view did not express a layout constraint for an edge, use
    // view's margins and our padding
    if (tempStart < 0) {
        tempStart = startPadding + startMargin;
    }
    if (tempEnd < 0) {
        tempEnd = mySize - endPadding - endMargin;
    }
    
    // Figure out maximum size available to this view
    CGFloat maxAvailable = tempEnd - tempStart;
    
    if (childStart >= 0 && childEnd >= 0) {
        // Constraints fixed both edges, so child must be an exact size
        childSpecMode = ULKLayoutMeasureSpecModeExactly;
        childSpecSize = maxAvailable;
    } else {
        if (childSize >= 0) {
            // Child wanted an exact size. Give as much as possible
            childSpecMode = ULKLayoutMeasureSpecModeExactly;
            
            if (maxAvailable >= 0) {
                // We have a maxmum size in this dimension.
                childSpecSize = MIN(maxAvailable, childSize);
            } else {
                // We can grow in this dimension.
                childSpecSize = childSize;
            }
        } else if (childSize == ULKLayoutParamsSizeMatchParent) {
            // Child wanted to be as big as possible. Give all availble
            // space
            childSpecMode = ULKLayoutMeasureSpecModeExactly;
            childSpecSize = maxAvailable;
        } else if (childSize == ULKLayoutParamsSizeWrapContent) {
            // Child wants to wrap content. Use AT_MOST
            // to communicate available space if we know
            // our max size
            if (maxAvailable >= 0) {
                // We have a maxmum size in this dimension.
                childSpecMode = ULKLayoutMeasureSpecModeAtMost;
                childSpecSize = maxAvailable;
            } else {
                // We can grow in this dimension. Child can be as big as it
                // wants
                childSpecMode = ULKLayoutMeasureSpecModeUnspecified;
                childSpecSize = 0;
            }
        }
    }
    
    return ULKLayoutMeasureSpecMake(childSpecSize, childSpecMode);
}

- (void)ulk_measureChild:(UIView *)child horizontalWithLayoutParams:(ULKRelativeLayoutParams *)params myWidth:(CGFloat)myWidth myHeight:(CGFloat)myHeight {
    UIEdgeInsets paramsMargin = params.margin;
    UIEdgeInsets padding = self.ulk_padding;
    ULKLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecForChildStart:params.left childEnd:params.right childSize:params.width startMargin:paramsMargin.left endMargin:paramsMargin.right startPadding:padding.left endPadding:padding.right mySize:myWidth];
    ULKLayoutMeasureSpec childHeightMeasureSpec;
    if (params.width == ULKLayoutParamsSizeMatchParent) {
        childHeightMeasureSpec = ULKLayoutMeasureSpecMake(myHeight - padding.top - padding.bottom, ULKLayoutMeasureSpecModeExactly);
    } else {
        childHeightMeasureSpec = ULKLayoutMeasureSpecMake(myHeight - padding.top - padding.bottom, ULKLayoutMeasureSpecModeAtMost);
    }
    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

/**
 * Measure a child. The child should have left, top, right and bottom information
 * stored in its LayoutParams. If any of these values is -1 it means that the view
 * can extend up to the corresponding edge.
 *
 * @param child Child to measure
 * @param params LayoutParams associated with child
 * @param myWidth Width of the the RelativeLayout
 * @param myHeight Height of the RelativeLayout
 */
- (void)ulk_measureChild:(UIView *)child withLayoutParams:(ULKRelativeLayoutParams *)params myWidth:(CGFloat)myWidth myHeight:(CGFloat)myHeight {
    UIEdgeInsets paramsMargin = params.margin;
    UIEdgeInsets padding = self.ulk_padding;
    ULKLayoutMeasureSpec childWidthMeasureSpec = [self childMeasureSpecForChildStart:params.left childEnd:params.right childSize:params.width startMargin:paramsMargin.left endMargin:paramsMargin.right startPadding:padding.left endPadding:padding.right mySize:myWidth];
    ULKLayoutMeasureSpec childHeightMeasureSpec = [self childMeasureSpecForChildStart:params.top childEnd:params.bottom childSize:params.height startMargin:paramsMargin.top endMargin:paramsMargin.bottom startPadding:padding.top endPadding:padding.bottom mySize:myHeight];
    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
}

- (void)centerChild:(UIView *)child horizontalWithLayoutParams:(ULKRelativeLayoutParams *)params myWidth:(CGFloat)myWidth {
    CGFloat childWidth = child.ulk_measuredSize.width;
    CGFloat left = (myWidth - childWidth) / 2.f;
    
    params.left = left;
    params.right = left + childWidth;
}

- (void)centerChild:(UIView *)child verticalWithLayoutParams:(ULKRelativeLayoutParams *)params myHeight:(CGFloat)myHeight {
    CGFloat childHeight = child.ulk_measuredSize.height;
    CGFloat top = (myHeight - childHeight) / 2.f;
    
    params.top = top;
    params.bottom = top + childHeight;
}


- (BOOL)positionChild:(UIView *)child horizontalWithLayoutParams:(ULKRelativeLayoutParams *)params myWidth:(CGFloat)myWidth wrapContent:(BOOL)wrapContent {
    
    NSArray *rules = params.rules;
    UIEdgeInsets padding = self.ulk_padding;
    
    if (params.left < 0 && params.right >= 0) {
        // Right is fixed, but left varies
        params.left = params.right - child.ulk_measuredSize.width;
    } else if (params.left >= 0 && params.right < 0) {
        // Left is fixed, but right varies
        params.right = params.left + child.ulk_measuredSize.width;
    } else if (params.left < 0 && params.right < 0) {
        // Both left and right vary
        id centerInParent = rules[ULKRelativeLayoutRuleCenterInParent];
        id centerHorizontal = rules[ULKRelativeLayoutRuleCenterHorizontal];
        if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerHorizontal != [NSNull null] && [centerHorizontal boolValue])) {
            if (!wrapContent) {
                [self centerChild:child horizontalWithLayoutParams:params myWidth:myWidth];
            } else {
                params.left = padding.left + params.margin.left;
                params.right = params.left + child.ulk_measuredSize.width;
            }
            return TRUE;
        } else {
            params.left = padding.left + params.margin.left;
            params.right = params.left + child.ulk_measuredSize.width;
        }
    }
    id alignParentRight = rules[ULKRelativeLayoutRuleAlignParentRight];
    return  (alignParentRight != [NSNull null] && [alignParentRight boolValue]);
}

- (BOOL)positionChild:(UIView *)child verticalWithLayoutParams:(ULKRelativeLayoutParams *)params myHeight:(CGFloat)myHeight wrapContent:(BOOL)wrapContent {
    
    NSArray *rules = params.rules;
    UIEdgeInsets padding = self.ulk_padding;
    
    if (params.top < 0 && params.bottom >= 0) {
        // Bottom is fixed, but top varies
        params.top = params.bottom - child.ulk_measuredSize.height;
    } else if (params.top >= 0 && params.bottom < 0) {
        // Top is fixed, but bottom varies
        params.bottom = params.top + child.ulk_measuredSize.height;
    } else if (params.top < 0 && params.bottom < 0) {
        // Both top and bottom vary
        id centerInParent = rules[ULKRelativeLayoutRuleCenterInParent];
        id centerVertical = rules[ULKRelativeLayoutRuleCenterVertical];
        if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerVertical != [NSNull null] && [centerVertical boolValue])) {
            if (!wrapContent) {
                [self centerChild:child verticalWithLayoutParams:params myHeight:myHeight];
            } else {
                params.top = padding.top + params.margin.top;
                params.bottom = params.top + child.ulk_measuredSize.height;
            }
            return true;
        } else {
            params.top = padding.top + params.margin.top;
            params.bottom = params.top + child.ulk_measuredSize.height;
        }
    }
    id alignParentBottom = rules[ULKRelativeLayoutRuleAlignParentBottom];
    return  (alignParentBottom != [NSNull null] && [alignParentBottom boolValue]);
}

- (void)applyVerticalSizeRulesWithChildLayoutParams:(ULKRelativeLayoutParams *)childParams myHeight:(CGFloat)myHeight {
    NSArray *rules = childParams.rules;
    ULKRelativeLayoutParams *anchorParams;
    UIEdgeInsets childParamsMargin = childParams.margin;
    UIEdgeInsets padding = self.ulk_padding;
    
    childParams.top = -1;
    childParams.bottom = -1;
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleAbove];
    if (anchorParams != nil) {
        childParams.bottom = anchorParams.top - (anchorParams.margin.top +
                                                 childParamsMargin.bottom);
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleAbove] != [NSNull null]) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - padding.bottom - childParamsMargin.bottom;
        } else {
            // FIXME uh oh...
        }
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleBelow];
    if (anchorParams != nil) {
        childParams.top = anchorParams.bottom + (anchorParams.margin.bottom +
                                                 childParamsMargin.top);
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleBelow] != [NSNull null]) {
        childParams.top = padding.top + childParamsMargin.top;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleAlignTop];
    if (anchorParams != nil) {
        childParams.top = anchorParams.top + childParamsMargin.top;
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleAlignTop] != [NSNull null]) {
        childParams.top = padding.top + childParamsMargin.top;
    }
    
    anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleAlignBottom];
    if (anchorParams != nil) {
        childParams.bottom = anchorParams.bottom - childParamsMargin.bottom;
    } else if (childParams.alignWithParent && rules[ULKRelativeLayoutRuleAlignBottom] != [NSNull null]) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - padding.bottom - childParamsMargin.bottom;
        } else {
            // FIXME uh oh...
        }
    }
    
    id alignParentTop = rules[ULKRelativeLayoutRuleAlignParentTop];
    if ([NSNull null] != alignParentTop && [alignParentTop boolValue]) {
        childParams.top = padding.top + childParamsMargin.top;
    }
    
    id alignParentBottom = rules[ULKRelativeLayoutRuleAlignParentBottom];
    if ([NSNull null] != alignParentBottom && [alignParentBottom boolValue]) {
        if (myHeight >= 0) {
            childParams.bottom = myHeight - padding.bottom - childParamsMargin.bottom;
        } else {
            // FIXME uh oh...
        }
    }
    
    id alignBaseline = rules[ULKRelativeLayoutRuleAlignBaseline];
    if (alignBaseline != [NSNull null] && [alignBaseline boolValue]) {
        _hasBaselineAlignedChild = true;
    }
}

- (CGFloat)relatedViewBaselineForRules:(NSArray *)rules relation:(ULKRelativeLayoutRule)relation {
    UIView *v = [self relatedViewForRules:rules relation:relation];
    if (v != nil) {
        return v.ulk_baseline;
    }
    return -1;
}

- (void)alignChild:(UIView *)child baselineWithLayoutParams:(ULKRelativeLayoutParams *)params {
    NSArray *rules = params.rules;
    CGFloat anchorBaseline = [self relatedViewBaselineForRules:rules relation:ULKRelativeLayoutRuleAlignBaseline];
    
    if (anchorBaseline != -1) {
        ULKRelativeLayoutParams *anchorParams = [self relatedViewParamsWithRules:rules relation:ULKRelativeLayoutRuleAlignBaseline];
        if (anchorParams != nil) {
            CGFloat offset = anchorParams.top + anchorBaseline;
            CGFloat baseline = child.ulk_baseline;
            if (baseline != -1) {
                offset -= baseline;
            }
            CGFloat height = params.bottom - params.top;
            params.top = offset;
            params.bottom = params.top + height;
        }
    }
    
    if (_baselineView == nil) {
        _baselineView = child;
    } else {
        ULKRelativeLayoutParams *lp = (ULKRelativeLayoutParams *)_baselineView.layoutParams;
        if (params.top < lp.top || (params.top == lp.top && params.left < lp.left)) {
            _baselineView = child;
        }
    }
}


- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    if (_dirtyHierarchy) {
        _dirtyHierarchy = false;
        [self sortChildren];
    }
    
    CGFloat myWidth = -1;
    CGFloat myHeight = -1;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    // Record our dimensions if they are known;
    if (widthMode != ULKLayoutMeasureSpecModeUnspecified) {
        myWidth = widthSize;
    }
    
    if (heightMode != ULKLayoutMeasureSpecModeUnspecified) {
        myHeight = heightSize;
    }
    
    if (widthMode == ULKLayoutMeasureSpecModeExactly) {
        width = myWidth;
    }
    
    if (heightMode == ULKLayoutMeasureSpecModeExactly) {
        height = myHeight;
    }
    
    _hasBaselineAlignedChild = FALSE;
    
    UIView *ignore = nil;
    ULKViewContentGravity gravity = _gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    BOOL horizontalGravity = gravity != ULKViewContentGravityLeft && gravity != 0;
    gravity = _gravity & VERTICAL_GRAVITY_MASK;
    BOOL verticalGravity = gravity != ULKViewContentGravityTop && gravity != 0;
    
    CGFloat left = CGFLOAT_MAX;
    CGFloat top = CGFLOAT_MAX;
    CGFloat right = CGFLOAT_MIN;
    CGFloat bottom = CGFLOAT_MIN;
    
    BOOL offsetHorizontalAxis = FALSE;
    BOOL offsetVerticalAxis = FALSE;
    
    if ((horizontalGravity || verticalGravity) && _ignoreGravity != nil) {
        ignore = [self ulk_findViewById:_ignoreGravity];
    }
    
    BOOL isWrapContentWidth = widthMode != ULKLayoutMeasureSpecModeExactly;
    BOOL isWrapContentHeight = heightMode != ULKLayoutMeasureSpecModeExactly;
    
    NSArray *views = _sortedHorizontalChildren;
    NSInteger count = [views count];
    for (int i = 0; i < count; i++) {
        UIView *child = views[i];
        if (child.ulk_visibility != ULKViewVisibilityGone) {
            ULKRelativeLayoutParams *params = (ULKRelativeLayoutParams *)child.layoutParams;
            
            [self applyHorizontalSizeRulesWithChildLayoutParams:params myWidth:myWidth];
            [self ulk_measureChild:child horizontalWithLayoutParams:params myWidth:myWidth myHeight:myHeight];
            if ([self positionChild:child horizontalWithLayoutParams:params myWidth:myWidth wrapContent:isWrapContentWidth]) {
                offsetHorizontalAxis = TRUE;
            }
        }
    }
    
    views = _sortedVerticalChildren;
    count = [views count];
    
    for (int i = 0; i < count; i++) {
        UIView *child = views[i];
        
        if (child.ulk_visibility != ULKViewVisibilityGone) {
            ULKRelativeLayoutParams *params = (ULKRelativeLayoutParams *)child.layoutParams;
            UIEdgeInsets paramsMargin = params.margin;
            
            [self applyVerticalSizeRulesWithChildLayoutParams:params myHeight:myHeight];
            [self ulk_measureChild:child withLayoutParams:params myWidth:myWidth myHeight:myHeight];
            if ([self positionChild:child verticalWithLayoutParams:params myHeight:myHeight wrapContent:isWrapContentHeight]) {
                offsetVerticalAxis = TRUE;
            }
            
            if (isWrapContentWidth) {
                width = MAX(width, params.right);
            }
            
            if (isWrapContentHeight) {
                height = MAX(height, params.bottom);
            }
            
            if (child != ignore || verticalGravity) {
                left = MIN(left, params.left - paramsMargin.left);
                top = MIN(top, params.top - paramsMargin.top);
            }
            
            if (child != ignore || horizontalGravity) {
                right = MAX(right, params.right + paramsMargin.right);
                bottom = MAX(bottom, params.bottom + paramsMargin.bottom);
            }
        }
    }
    
    if (_hasBaselineAlignedChild) {
        for (int i = 0; i < count; i++) {
            UIView *child = (self.subviews)[i];
            
            if (child.ulk_visibility != ULKViewVisibilityGone) {
                ULKRelativeLayoutParams *params = (ULKRelativeLayoutParams *)child.layoutParams;
                [self alignChild:child baselineWithLayoutParams:params];
                
                UIEdgeInsets paramsMargin = params.margin;
                if (child != ignore || verticalGravity) {
                    left = MIN(left, params.left - paramsMargin.left);
                    top = MIN(top, params.top - paramsMargin.top);
                }
                
                if (child != ignore || horizontalGravity) {
                    right = MAX(right, params.right + paramsMargin.right);
                    bottom = MAX(bottom, params.bottom + paramsMargin.bottom);
                }
            }
        }
    }
    
    UIEdgeInsets padding = self.ulk_padding;
    CGSize minSize = self.ulk_minSize;
    if (isWrapContentWidth) {
        // Width already has left padding in it since it was calculated by looking at
        // the right of each child view
        width += padding.right;
        
        if (self.layoutParams.width >= 0) {
            width = MAX(width, self.layoutParams.width);
        }
        
        width = MAX(width, minSize.width);
        width = [UIView ulk_resolveSizeForSize:width measureSpec:widthMeasureSpec];
        
        if (offsetHorizontalAxis) {
            for (int i = 0; i < count; i++) {
                UIView *child = (self.subviews)[i];
                
                if (child.ulk_visibility != ULKViewVisibilityGone) {
                    ULKRelativeLayoutParams *params = (ULKRelativeLayoutParams *)child.layoutParams;
                    NSArray *rules = params.rules;
                    id centerInParent = rules[ULKRelativeLayoutRuleCenterInParent];
                    id centerHorizontal = rules[ULKRelativeLayoutRuleCenterHorizontal];
                    id alignParentRight = rules[ULKRelativeLayoutRuleAlignParentRight];
                    if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerHorizontal != [NSNull null] && [centerHorizontal boolValue])) {
                        [self centerChild:child horizontalWithLayoutParams:params myWidth:width];
                    } else if (alignParentRight != [NSNull null] && [alignParentRight boolValue]) {
                        CGFloat childWidth = child.ulk_measuredSize.width;
                        params.left = width - padding.right - childWidth;
                        params.right = params.left + childWidth;
                    }
                }
            }
        }
    }
    
    if (isWrapContentHeight) {
        // Height already has top padding in it since it was calculated by looking at
        // the bottom of each child view
        height += padding.bottom;
        
        if (self.layoutParams.height >= 0) {
            height = MAX(height, self.layoutParams.height);
        }
        
        height = MAX(height, minSize.height);
        height = [UIView ulk_resolveSizeForSize:height measureSpec:heightMeasureSpec];
        
        if (offsetVerticalAxis) {
            for (int i = 0; i < count; i++) {
                UIView *child = (self.subviews)[i];
                
                if (child.ulk_visibility != ULKViewVisibilityGone) {
                    ULKRelativeLayoutParams *params = (ULKRelativeLayoutParams *)child.layoutParams;
                    NSArray *rules = params.rules;
                    id centerInParent = rules[ULKRelativeLayoutRuleCenterInParent];
                    id centerVertical = rules[ULKRelativeLayoutRuleCenterVertical];
                    id alignParentBottom = rules[ULKRelativeLayoutRuleAlignParentBottom];
                    if ((centerInParent != [NSNull null] && [centerInParent boolValue]) || (centerVertical != [NSNull null] && [centerVertical boolValue])) {
                        [self centerChild:child verticalWithLayoutParams:params myHeight:height];
                    } else if (alignParentBottom != [NSNull null] && [alignParentBottom boolValue]) {
                        CGFloat childHeight = child.ulk_measuredSize.height;
                        params.top = height - padding.bottom - childHeight;
                        params.bottom = params.top + childHeight;
                    }
                }
            }
        }
    }
    
    if (horizontalGravity || verticalGravity) {
        _selfBounds = CGRectMake(padding.left, padding.top, width, height);
        
        [ULKGravity applyGravity:_gravity width:right-left height:bottom-top containerRect:&_selfBounds outRect:&_contentBounds];
        
        CGFloat horizontalOffset = _contentBounds.origin.x - left;
        CGFloat verticalOffset = _contentBounds.origin.y - top;
        if (horizontalOffset != 0 || verticalOffset != 0) {
            for (int i = 0; i < count; i++) {
                UIView *child = (self.subviews)[i];
                
                if (child.ulk_visibility != ULKViewVisibilityGone && child != ignore) {
                    ULKRelativeLayoutParams *params = (ULKRelativeLayoutParams *)child.layoutParams;
                    if (horizontalGravity) {
                        params.left += horizontalOffset;
                        params.right += horizontalOffset;
                    }
                    if (verticalGravity) {
                        params.top += verticalOffset;
                        params.bottom += verticalOffset;
                    }
                }
            }
        }
    }
    ULKLayoutMeasuredSize measuredSize;
    measuredSize.width.state = ULKLayoutMeasuredStateNone;
    measuredSize.width.size = width;
    measuredSize.height.state = ULKLayoutMeasuredStateNone;
    measuredSize.height.size = height;
    [self ulk_setMeasuredDimensionSize:measuredSize];
    
}

- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    //  The layout has actually already been performed and the positions
    //  cached.  Apply the cached values to the children.
    NSUInteger count = [self.subviews count];
    
    for (int i = 0; i < count; i++) {
        UIView *child = (self.subviews)[i];
        
        if (child.ulk_visibility != ULKViewVisibilityGone) {
            ULKRelativeLayoutParams *st = (ULKRelativeLayoutParams *)child.layoutParams;
            [child ulk_layoutWithFrame:CGRectMake(st.left, st.top, st.right-st.left, st.bottom - st.top)];
        }
    }
}


@end

