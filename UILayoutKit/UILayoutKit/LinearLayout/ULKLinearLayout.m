//
//  LinearLayout.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKLinearLayout.h"
#import "UIView+ULK_Layout.h"




@implementation ULKLinearLayoutParams

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height {
    self = [super initWithWidth:width height:height];
    if (self != nil) {
        
    }
    return self;
}

- (instancetype)initWithLayoutParams:(ULKLayoutParams *)layoutParams {
    self = [super initWithLayoutParams:layoutParams];
    if (self) {
        if ([layoutParams isKindOfClass:[ULKLinearLayoutParams class]]) {
            ULKLinearLayoutParams *otherLP = (ULKLinearLayoutParams *)layoutParams;
            self.gravity = otherLP.gravity;
            self.weight = otherLP.weight;
        }
    }
    return self;
}

@end


@implementation UIView (ULK_LinearLayoutParams)

- (void)setLinearLayoutParams:(ULKLinearLayoutParams *)linearLayoutParams {
    self.ulk_layoutParams = linearLayoutParams;
}

- (ULKLinearLayoutParams *)linearLayoutParams {
    ULKLayoutParams *layoutParams = self.ulk_layoutParams;
    if (![layoutParams isKindOfClass:[ULKLinearLayoutParams class]]) {
        layoutParams = [[ULKLinearLayoutParams alloc] initWithLayoutParams:layoutParams];
        self.ulk_layoutParams = layoutParams;
    }
    
    return (ULKLinearLayoutParams *)layoutParams;
}

- (void)setUlk_layoutWeight:(float)layoutWeight {
    self.linearLayoutParams.weight = layoutWeight;
    [self ulk_requestLayout];
}

- (float)ulk_layoutWeight {
    return self.linearLayoutParams.weight;
}

@end


@implementation ULKLinearLayout {
    CGFloat _totalLength;
    
    /**
     * Whether the children of this layout are baseline aligned.  Only applicable
     * if _orientation is horizontal.
     */
    BOOL _baselineAligned;
    int _maxAscent[VERTICAL_GRAVITY_COUNT];
    int _maxDescent[VERTICAL_GRAVITY_COUNT];
    NSInteger _baselineAlignedChildIndex;
    CGFloat _baselineChildTop;
    BOOL _useLargestChild;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gravity = ULKGravityLeft | ULKGravityTop;
        _orientation = LinearLayoutOrientationVertical;
        _baselineAligned = TRUE;
        _baselineAlignedChildIndex = -1;
        _baselineChildTop = 0;
    }
    return self;
}

- (void)setGravity:(ULKGravity)gravity {
    if (_gravity != gravity) {
        if ((gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK) == 0) {
            gravity |= ULKGravityLeft;
        }
        
        if ((gravity & VERTICAL_GRAVITY_MASK) == 0) {
            gravity |= ULKGravityTop;
        }
        
        _gravity = gravity;
        [self ulk_requestLayout];
    }
}

- (void)setOrientation:(LinearLayoutOrientation)orientation {
    if (_orientation != orientation) {
        _orientation = orientation;
        [self ulk_requestLayout];
    }
}

- (void)setWeightSum:(float)weightSum {
    _weightSum = MAX(0.0f, weightSum);
}

- (CGFloat)ulk_baseline {
    if (_baselineAlignedChildIndex < 0) {
        return [super ulk_baseline];
    }
    
    if ([[self subviews] count] <= _baselineAlignedChildIndex) {
        @throw [NSException exceptionWithName:@"RuntimeException" reason:@"mBaselineAlignedChildIndex of LinearLayout set to an index that is out of bounds." userInfo:nil];
    }
    
    UIView *child = [self subviews][_baselineAlignedChildIndex];
    CGFloat childBaseline = child.ulk_baseline;
    
    if (childBaseline == -1) {
        if (_baselineAlignedChildIndex == 0) {
            // this is just the default case, safe to return -1
            return -1;
        }
        // the user picked an index that points to something that doesn't
        // know how to calculate its baseline.
        @throw [NSException exceptionWithName:@"RuntimeException" reason:@"mBaselineAlignedChildIndex of LinearLayout points to a View that doesn't know how to get its baseline." userInfo:nil];
    }
    
    // TODO: This should try to take into account the virtual offsets
    // (See getNextLocationOffset and getLocationOffset)
    // We should add to childTop:
    // sum([getNextLocationOffset(getChildAt(i)) / i < mBaselineAlignedChildIndex])
    // and also add:
    // getLocationOffset(child)
    CGFloat childTop = _baselineChildTop;
    
    if (_orientation == LinearLayoutOrientationVertical) {
        ULKGravity majorGravity = _gravity & VERTICAL_GRAVITY_MASK;
        if (majorGravity != ULKGravityTop) {
            UIEdgeInsets padding = self.ulk_padding;
            switch (majorGravity) {
                case ULKGravityBottom:
                    childTop = self.frame.size.height - padding.bottom - _totalLength;
                    break;
                    
                case ULKGravityCenterVertical:
                    childTop += ((self.frame.size.height - padding.top - padding.bottom) - _totalLength) / 2;
                    break;
                default:
                    break;
            }
        }
    }
    
    ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
    return childTop + lp.margin.top + childBaseline;
}

/**
 * <p>Return the size offset of the next sibling of the specified child.
 * This can be used by subclasses to change the location of the widget
 * following <code>child</code>.</p>
 *
 * @param child the child whose next sibling will be moved
 * @return the location offset of the next child in pixels
 */
- (CGFloat)nextLocationOffsetOfChild:(UIView *)child {
    return 0;
}

/**
 * <p>Returns the number of children to skip after measuring/laying out
 * the specified child.</p>
 *
 * @param child the child after which we want to skip children
 * @param index the index of the child after which we want to skip children
 * @return the number of children to skip, 0 by default
 */
- (NSInteger)childrenSkipCountAfterChild:(UIView *)child atIndex:(NSInteger)index {
    return 0;
}


- (void)forceUniformWidthWithCount:(NSInteger)count heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    // Pretend that the linear layout has an exact size.
    ULKLayoutMeasureSpec uniformMeasureSpec;
    uniformMeasureSpec.size = self.ulk_measuredSize.width;
    uniformMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
    for (int i = 0; i< count; ++i) {
        UIView *child = [self subviews][i];
        if (child.ulk_visibility == ULKViewVisibilityGone) {
            continue;
        }
        
        ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)child.ulk_layoutParams;
        
        if (lp.width == ULKLayoutParamsSizeMatchParent) {
            // Temporarily force children to reuse their old measured height
            // FIXME: this may not be right for something like wrapping text?
            CGFloat oldHeight = lp.height;
            lp.height = child.ulk_measuredSize.height;
            
            // Remeasue with new dimensions
            [self ulk_measureChildWithMargins:child parentWidthMeasureSpec:uniformMeasureSpec widthUsed:0.f parentHeightMeasureSpec:heightMeasureSpec heightUsed:0.f];
            lp.height = oldHeight;
        }
    }
}

- (void)ulk_measureChild:(UIView *)child atIndex:(NSInteger)index beforeLayoutWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec totalWidth:(CGFloat)totalWidth heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec totalHeight:(CGFloat)totalHeight {
    [self ulk_measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:totalWidth parentHeightMeasureSpec:heightMeasureSpec heightUsed:totalHeight];
}

/**
 * Measures the children when the orientation of this LinearLayout is set
 * to {@link #VERTICAL}.
 *
 * @param widthMeasureSpec Horizontal space requirements as imposed by the parent.
 * @param heightMeasureSpec Vertical space requirements as imposed by the parent.
 *
 * @see #getOrientation()
 * @see #setOrientation(int)
 * @see #onMeasure(int, int)
 */
- (void)measureVerticalWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    _totalLength = 0;
    CGFloat maxWidth = 0;
    ULKLayoutMeasuredWidthHeightState childState = {ULKLayoutMeasuredStateNone, ULKLayoutMeasuredStateNone};
    CGFloat alternativeMaxWidth = 0;
    CGFloat weightedMaxWidth = 0;
    BOOL allFillParent = TRUE;
    float totalWeight = 0;
    
    NSInteger count = [self.subviews count];
    
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    
    BOOL matchWidth = FALSE;
    
    NSInteger baselineChildIndex = _baselineAlignedChildIndex;        
    BOOL useLargestChild = _useLargestChild;
    
    CGFloat largestChildHeight = CGFLOAT_MIN;
    
    // See how tall everyone is. Also remember max width.
    for (int i = 0; i < count; ++i) {
        UIView *child = (self.subviews)[i];
        
        if (child.ulk_visibility == ULKViewVisibilityGone) {
            i += [self childrenSkipCountAfterChild:child atIndex:i];
            continue;
        }
        
        ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
        UIEdgeInsets lpMargin = lp.margin;
        totalWeight += lp.weight;
        
        if (heightMode == ULKLayoutMeasureSpecModeExactly && lp.height == 0 && lp.weight > 0) {
            // Optimization: don't bother measuring children who are going to use
            // leftover space. These views will get measured again down below if
            // there is any leftover space.
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + lpMargin.top + lpMargin.bottom);
        } else {
            CGFloat oldHeight = CGFLOAT_MIN;
            
            if (lp.height == 0 && lp.weight > 0) {
                // heightMode is either UNSPECIFIED or AT_MOST, and this
                // child wanted to stretch to fill available space.
                // Translate that to WRAP_CONTENT so that it does not end up
                // with a height of 0
                oldHeight = 0;
                lp.height = ULKLayoutParamsSizeWrapContent;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self ulk_measureChild:child atIndex:i beforeLayoutWithWidthMeasureSpec:widthMeasureSpec totalWidth:0 heightMeasureSpec:heightMeasureSpec totalHeight:(totalWeight == 0 ? _totalLength : 0)];
            
            if (oldHeight != CGFLOAT_MIN) {
                lp.height = oldHeight;
            }
            
            CGFloat childHeight = child.ulk_measuredSize.height;
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + childHeight + lpMargin.top + lpMargin.bottom + [self nextLocationOffsetOfChild:child]);
            
            if (useLargestChild) {
                largestChildHeight = MAX(childHeight, largestChildHeight);
            }
        }
        
        /**
         * If applicable, compute the additional offset to the child's baseline
         * we'll need later when asked {@link #getBaseline}.
         */
        if ((baselineChildIndex >= 0) && (baselineChildIndex == i + 1)) {
            _baselineChildTop = _totalLength;
        }
        
        // if we are trying to use a child index for our baseline, the above
        // book keeping only works if there are no children above it with
        // weight.  fail fast to aid the developer.
        if (i < baselineChildIndex && lp.weight > 0) {
            @throw [NSException exceptionWithName:@"LayoutError" reason:@"A child of LinearLayout with index less than mBaselineAlignedChildIndex has weight > 0, which won't work.  Either remove the weight, or don't set mBaselineAlignedChildIndex." userInfo:nil];
        }
        
        BOOL matchWidthLocally = FALSE;
        if (widthMode != ULKLayoutMeasureSpecModeExactly && lp.width == ULKLayoutParamsSizeMatchParent) {
            // The width of the linear layout will scale, and at least one
            // child said it wanted to match our width. Set a flag
            // indicating that we need to remeasure at least that view when
            // we know our width.
            matchWidth = TRUE;
            matchWidthLocally = TRUE;
        }
        
        CGFloat margin = lpMargin.left + lpMargin.right;
        CGFloat measuredWidth = child.ulk_measuredSize.width + margin;
        maxWidth = MAX(maxWidth, measuredWidth);
        childState = [UIView ulk_combineMeasuredStatesCurrentState:childState newState:child.ulk_measuredState];
        
        allFillParent = allFillParent && lp.width == ULKLayoutParamsSizeMatchParent;
        if (lp.weight > 0) {
            /*
             * Widths of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxWidth = MAX(weightedMaxWidth,
                                   matchWidthLocally ? margin : measuredWidth);
        } else {
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                                      matchWidthLocally ? margin : measuredWidth);
        }
        
        i += [self childrenSkipCountAfterChild:child atIndex:i];
    }
    
    if (useLargestChild &&
        (heightMode == ULKLayoutMeasureSpecModeAtMost || heightMode == ULKLayoutMeasureSpecModeUnspecified)) {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [self subviews][i];
            
            if (child.ulk_visibility == ULKViewVisibilityGone) {
                i += [self childrenSkipCountAfterChild:child atIndex:i];
            }
            
            ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
            // Account for negative margins
            CGFloat totalLength = _totalLength;
            UIEdgeInsets lpMargin = lp.margin;
            _totalLength = MAX(totalLength, totalLength + largestChildHeight +
                               lpMargin.top + lpMargin.bottom + [self nextLocationOffsetOfChild:child]);
        }
    }
    
    // Add in our padding
    UIEdgeInsets padding = self.ulk_padding;
    _totalLength += padding.top + padding.bottom;
    
    CGFloat heightSize = _totalLength;
    
    // Check against our minimum height
    CGSize minSize = self.ulk_minSize;
    CGSize maxSize = self.ulk_maxSize;
    heightSize = MAX(heightSize, minSize.height);
    heightSize = MIN(heightSize, maxSize.height);
    
    // Reconcile our calculated size with the heightMeasureSpec
    ULKLayoutMeasuredDimension heightSizeAndState = [UIView ulk_resolveSizeAndStateForSize:heightSize measureSpec:heightMeasureSpec childMeasureState:ULKLayoutMeasuredStateNone];
    heightSize = heightSizeAndState.size;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds
    CGFloat delta = heightSize - _totalLength;
    if (delta != 0 && totalWeight > 0.0f) {
        float weightSum = _weightSum > 0.0f ? _weightSum : totalWeight;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [self subviews][i];
            
            if (child.ulk_visibility == ULKViewVisibilityGone) {
                continue;
            }
            
            ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            float childExtra = lp.weight;
            if (childExtra > 0) {
                // Child said it could absorb extra space -- give him his share
                float share = (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                ULKLayoutMeasureSpec childWidthMeasureSpec = [ULKViewGroup childMeasureSpecForMeasureSpec:widthMeasureSpec padding:(padding.left + padding.right + lpMargin.left + lpMargin.right) childDimension:lp.width];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if ((lp.height != 0) || (heightMode != ULKLayoutMeasureSpecModeExactly)) {
                    // child was measured once already above...
                    // base new measurement on stored values
                    CGFloat childHeight = child.ulk_measuredSize.height + share;
                    if (childHeight < 0) {
                        childHeight = 0;
                    }
                    ULKLayoutMeasureSpec childHeightMeasureSpec = ULKLayoutMeasureSpecMake(childHeight, ULKLayoutMeasureSpecModeExactly);
                    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                } else {
                    // child was skipped in the loop above.
                    // Measure for this first time here      
                    ULKLayoutMeasureSpec childHeightMeasureSpec = ULKLayoutMeasureSpecMake((share > 0 ? share : 0), ULKLayoutMeasureSpecModeExactly);
                    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
                
                // Child may now not fit in vertical dimension.
                ULKLayoutMeasuredWidthHeightState newState = child.ulk_measuredState;
                newState.widthState = ULKLayoutMeasuredStateNone;
                childState = [UIView ulk_combineMeasuredStatesCurrentState:childState newState:newState];
            }
            
            CGFloat margin =  lpMargin.left + lpMargin.right;
            CGFloat measuredWidth = child.ulk_measuredSize.width + margin;
            maxWidth = MAX(maxWidth, measuredWidth);
            
            BOOL matchWidthLocally = widthMode != ULKLayoutMeasureSpecModeExactly && lp.width == ULKLayoutParamsSizeMatchParent;
            
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                                      matchWidthLocally ? margin : measuredWidth);
            
            allFillParent = allFillParent && lp.width == ULKLayoutParamsSizeMatchParent;
            
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + child.ulk_measuredSize.height + lpMargin.top + lpMargin.bottom + [self nextLocationOffsetOfChild:child]);
        }
        
        // Add in our padding
        _totalLength += padding.top + padding.bottom;
        // TODO: Should we recompute the heightSpec based on the new total length?
    } else {
        alternativeMaxWidth = MAX(alternativeMaxWidth, weightedMaxWidth);
        
        
        // We have no limit, so make all weighted views as tall as the largest child.
        // Children will have already been measured once.
        if (useLargestChild && widthMode == ULKLayoutMeasureSpecModeUnspecified) {
            for (int i = 0; i < count; i++) {
                UIView *child = [self subviews][i];
                
                if (child.ulk_visibility == ULKViewVisibilityGone) {
                    continue;
                }
                
                ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
                
                float childExtra = lp.weight;
                if (childExtra > 0) {
                    ULKLayoutMeasureSpec childWidthMeasureSpec;
                    ULKLayoutMeasureSpec childHeightMeasureSpec;
                    childWidthMeasureSpec.size = child.ulk_measuredSize.width;
                    childWidthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
                    childHeightMeasureSpec.size = largestChildHeight;
                    childHeightMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
                    
                    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
            }
        }
    }
    
    if (!allFillParent && widthMode != ULKLayoutMeasureSpecModeExactly) {
        maxWidth = alternativeMaxWidth;
    }
    
    maxWidth += padding.left + padding.right;
    
    // Check against our minimum width
    maxWidth = MAX(maxWidth, minSize.width);
    maxWidth = MIN(maxWidth, maxSize.width);
    
    ULKLayoutMeasuredSize measuredSize = ULKLayoutMeasuredSizeMake([UIView ulk_resolveSizeAndStateForSize:maxWidth measureSpec:widthMeasureSpec childMeasureState:childState.widthState] , heightSizeAndState);
    [self ulk_setMeasuredDimensionSize:measuredSize];
    
    if (matchWidth) {
        [self forceUniformWidthWithCount:count heightMeasureSpec:heightMeasureSpec];
    }
}

- (void)forceUniformHeightWithCount:(NSInteger)count widthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec {
    // Pretend that the linear layout has an exact size. This is the measured height of
    // ourselves. The measured height should be the max height of the children, changed
    // to accomodate the heightMesureSpec from the parent
    ULKLayoutMeasureSpec uniformMeasureSpec;
    uniformMeasureSpec.size = self.ulk_measuredSize.height;
    uniformMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
    for (int i = 0; i < count; ++i) {
        UIView *child = [self subviews][i];
        
        if (child.ulk_visibility == ULKViewVisibilityGone) {
            continue;
        }
        
        ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
        
        if (lp.height == ULKLayoutParamsSizeMatchParent) {
            // Temporarily force children to reuse their old measured width
            // FIXME: this may not be right for something like wrapping text?
            int oldWidth = lp.width;
            lp.width = child.ulk_measuredSize.width;
            
            // Remeasure with new dimensions
            [self ulk_measureChildWithMargins:child parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:uniformMeasureSpec heightUsed:0];
            lp.width = oldWidth;
        }
    }
}


/**
 * Measures the children when the orientation of this LinearLayout is set
 * to {@link #HORIZONTAL}.
 *
 * @param widthMeasureSpec Horizontal space requirements as imposed by the parent.
 * @param heightMeasureSpec Vertical space requirements as imposed by the parent.
 *
 * @see #getOrientation()
 * @see #setOrientation(int)
 * @see #onMeasure(int, int) 
 */
- (void)measureHorizontalWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    _totalLength = 0.f;
    CGFloat maxHeight = 0.f;
    ULKLayoutMeasuredWidthHeightState childState = {ULKLayoutMeasuredStateNone, ULKLayoutMeasuredStateNone};
    CGFloat alternativeMaxHeight = 0.f;
    CGFloat weightedMaxHeight = 0.f;
    BOOL allFillParent = TRUE;
    float totalWeight = 0.f;
    
    NSInteger count = [[self subviews] count];
    
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    
    BOOL matchHeight = FALSE;
    
    int maxAscent[VERTICAL_GRAVITY_COUNT];
    int maxDescent[VERTICAL_GRAVITY_COUNT];
    
    maxAscent[0] = maxAscent[1] = maxAscent[2] = maxAscent[3] = -1;
    maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = -1;
    
    BOOL baselineAligned = _baselineAligned;
    BOOL useLargestChild = _useLargestChild;
    
    BOOL isExactly = widthMode == ULKLayoutMeasureSpecModeExactly;
    
    CGFloat largestChildWidth = CGFLOAT_MIN;
    
    // See how wide everyone is. Also remember max height.
    for (int i = 0; i < count; ++i) {
        UIView *child = [self subviews][i];
        
        if (child.ulk_visibility == ULKViewVisibilityGone) {
            i += [self childrenSkipCountAfterChild:child atIndex:i];
            continue;
        }
        
        ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
        UIEdgeInsets lpMargin = lp.margin;
        
        totalWeight += lp.weight;
        
        if (widthMode == ULKLayoutMeasureSpecModeExactly && lp.width == 0 && lp.weight > 0) {
            // Optimization: don't bother measuring children who are going to use
            // leftover space. These views will get measured again down below if
            // there is any leftover space.
            if (isExactly) {
                _totalLength += lpMargin.left + lpMargin.right;
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + lpMargin.left + lpMargin.right);
            }
            
            // Baseline alignment requires to measure widgets to obtain the
            // baseline offset (in particular for TextViews). The following
            // defeats the optimization mentioned above. Allow the child to
            // use as much space as it wants because we can shrink things
            // later (and re-measure).
            if (baselineAligned) {
                ULKLayoutMeasureSpec freeSpec;
                freeSpec.size = 0;
                freeSpec.mode = ULKLayoutMeasureSpecModeUnspecified;
                [child ulk_measureWithWidthMeasureSpec:freeSpec heightMeasureSpec:freeSpec];
            }
        } else {
            CGFloat oldWidth = CGFLOAT_MIN;
            
            if (lp.width == 0 && lp.weight > 0) {
                // widthMode is either UNSPECIFIED or AT_MOST, and this
                // child
                // wanted to stretch to fill available space. Translate that to
                // WRAP_CONTENT so that it does not end up with a width of 0
                oldWidth = 0.f;
                lp.width = ULKLayoutParamsSizeWrapContent;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self ulk_measureChild:child atIndex:i beforeLayoutWithWidthMeasureSpec:widthMeasureSpec totalWidth:(totalWeight == 0 ? _totalLength : 0) heightMeasureSpec:heightMeasureSpec totalHeight:0];
            
            if (oldWidth != CGFLOAT_MIN) {
                lp.width = oldWidth;
            }
            
            CGFloat childWidth = child.ulk_measuredSize.width;
            if (isExactly) {
                _totalLength += childWidth + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child];
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + childWidth + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child]);
            }
            
            if (useLargestChild) {
                largestChildWidth = MAX(childWidth, largestChildWidth);
            }
        }
        
        BOOL matchHeightLocally = false;
        if (heightMode != ULKLayoutMeasureSpecModeExactly && lp.height == ULKLayoutParamsSizeMatchParent) {
            // The height of the linear layout will scale, and at least one
            // child said it wanted to match our height. Set a flag indicating that
            // we need to remeasure at least that view when we know our height.
            matchHeight = true;
            matchHeightLocally = true;
        }
        
        CGFloat margin = lpMargin.top + lpMargin.bottom;
        CGFloat childHeight = child.ulk_measuredSize.height + margin;
        childState = [UIView ulk_combineMeasuredStatesCurrentState:childState newState:child.ulk_measuredState];
        
        if (baselineAligned) {
            CGFloat childBaseline = child.ulk_baseline;
            if (childBaseline != -1) {
                // Translates the child's vertical gravity into an index
                // in the range 0..VERTICAL_GRAVITY_COUNT
                ULKGravity gravity = (lp.gravity < ULKGravityNone ? _gravity : lp.gravity) & VERTICAL_GRAVITY_MASK;
                int index = ((gravity >> AXIS_Y_SHIFT)
                             & ~AXIS_SPECIFIED) >> 1;
                
                maxAscent[index] = MAX(maxAscent[index], childBaseline);
                maxDescent[index] = MAX(maxDescent[index], childHeight - childBaseline);
            }
        }
        
        maxHeight = MAX(maxHeight, childHeight);
        
        allFillParent = allFillParent && lp.height == ULKLayoutParamsSizeMatchParent;
        if (lp.weight > 0) {
            /*
             * Heights of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxHeight = MAX(weightedMaxHeight,
                                    matchHeightLocally ? margin : childHeight);
        } else {
            alternativeMaxHeight = MAX(alternativeMaxHeight,
                                       matchHeightLocally ? margin : childHeight);
        }
        
        i += [self childrenSkipCountAfterChild:child atIndex:i];
    }
    
    // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
    // the most common case
    if (maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP] != -1 ||
        maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL] != -1 ||
        maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM] != -1 ||
        maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL] != -1) {
        int ascent = MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL],
                         MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                             MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP], maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
        int descent = MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_FILL],
                          MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                              MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_TOP], maxDescent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
        maxHeight = MAX(maxHeight, ascent + descent);
    }
    
    if (useLargestChild &&
        (widthMode == ULKLayoutMeasureSpecModeAtMost || widthMode == ULKLayoutMeasureSpecModeUnspecified)) {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [self subviews][i];
            
            if (child.ulk_visibility == ULKViewVisibilityGone) {
                i += [self childrenSkipCountAfterChild:child atIndex:i];
                continue;
            }
            
            ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)
            child.ulk_layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            if (isExactly) {
                _totalLength += largestChildWidth + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child];
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + largestChildWidth + lpMargin.left + lpMargin.right + [ self nextLocationOffsetOfChild:child]);
            }
        }
    }
    
    // Add in our padding
    UIEdgeInsets padding = self.ulk_padding;
    _totalLength += padding.left + padding.right;
    
    CGFloat widthSize = _totalLength;
    
    // Check against our minimum width
    CGSize minSize = self.ulk_minSize;
    CGSize maxSize = self.ulk_maxSize;
    widthSize = MAX(widthSize, minSize.width);
    widthSize = MIN(widthSize, maxSize.width);
    
    // Reconcile our calculated size with the widthMeasureSpec
    ULKLayoutMeasuredDimension widthSizeAndState = [UIView ulk_resolveSizeAndStateForSize:widthSize measureSpec:widthMeasureSpec childMeasureState:ULKLayoutMeasuredStateNone];
    widthSize = widthSizeAndState.size;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds
    CGFloat delta = widthSize - _totalLength;
    if (delta != 0 && totalWeight > 0.0f) {
        float weightSum = _weightSum > 0.0f ? _weightSum : totalWeight;
        
        maxAscent[0] = maxAscent[1] = maxAscent[2] = maxAscent[3] = -1;
        maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = -1;
        maxHeight = -1;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            UIView *child = [self subviews][i];
            
            if (child.ulk_visibility == ULKViewVisibilityGone) {
                continue;
            }
            
            ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            float childExtra = lp.weight;
            if (childExtra > 0) {
                // Child said it could absorb extra space -- give him his share
                int share = (int) (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                ULKLayoutMeasureSpec childHeightMeasureSpec = [self ulk_childMeasureSpecWithMeasureSpec:heightMeasureSpec padding:(padding.top + padding.bottom + lpMargin.top + lpMargin.bottom) childDimension:lp.height];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if ((lp.width != 0) || (widthMode != ULKLayoutMeasureSpecModeExactly)) {
                    // child was measured once already above ... base new measurement
                    // on stored values
                    CGFloat childWidth = child.ulk_measuredSize.width + share;
                    if (childWidth < 0) {
                        childWidth = 0;
                    }
                    
                    ULKLayoutMeasureSpec childWidthMeasureSpec;
                    childWidthMeasureSpec.size = childWidth;
                    childWidthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
                    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                } else {
                    // child was skipped in the loop above. Measure for this first time here
                    ULKLayoutMeasureSpec childWidthMeasureSpec;
                    childWidthMeasureSpec.size = (share > 0 ? share : 0);
                    childWidthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
                    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
                
                // Child may now not fit in horizontal dimension.
                ULKLayoutMeasuredWidthHeightState newState = child.ulk_measuredState;
                newState.heightState = ULKLayoutMeasuredStateNone;
                childState = [UIView ulk_combineMeasuredStatesCurrentState:childState newState:newState];
            }
            
            if (isExactly) {
                _totalLength += child.ulk_measuredSize.width + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child];
            } else {
                CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + child.ulk_measuredSize.width + lpMargin.left + lpMargin.right + [self nextLocationOffsetOfChild:child]);
            }
            
            BOOL matchHeightLocally = heightMode != ULKLayoutMeasureSpecModeExactly && lp.height == ULKLayoutParamsSizeMatchParent;
            
            CGFloat margin = lpMargin.top + lpMargin.bottom;
            CGFloat childHeight = child.ulk_measuredSize.height + margin;
            maxHeight = MAX(maxHeight, childHeight);
            alternativeMaxHeight = MAX(alternativeMaxHeight,
                                       matchHeightLocally ? margin : childHeight);
            
            allFillParent = allFillParent && lp.height == ULKLayoutParamsSizeMatchParent;
            
            if (baselineAligned) {
                CGFloat childBaseline = child.ulk_baseline;
                if (childBaseline != -1) {
                    // Translates the child's vertical gravity into an index in the range 0..2
                    ULKGravity gravity = (lp.gravity < ULKGravityNone ? _gravity : lp.gravity) & VERTICAL_GRAVITY_MASK;
                    int index = ((gravity >> AXIS_Y_SHIFT)
                                 & ~AXIS_SPECIFIED) >> 1;
                    
                    maxAscent[index] = MAX(maxAscent[index], childBaseline);
                    maxDescent[index] = MAX(maxDescent[index],
                                            childHeight - childBaseline);
                }
            }
        }
        
        // Add in our padding
        _totalLength += padding.left + padding.right;
        // TODO: Should we update widthSize with the new total length?
        
        // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
        // the most common case
        if (maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP] != -1 ||
            maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL] != -1 ||
            maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM] != -1 ||
            maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL] != -1) {
            int ascent = MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_FILL],
                             MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                                 MAX(maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP], maxAscent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
            int descent = MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_FILL],
                              MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL],
                                  MAX(maxDescent[MAX_ASCENT_DESCENT_INDEX_TOP], maxDescent[MAX_ASCENT_DESCENT_INDEX_BOTTOM])));
            maxHeight = MAX(maxHeight, ascent + descent);
        }
    } else {
        alternativeMaxHeight = MAX(alternativeMaxHeight, weightedMaxHeight);
        
        // We have no limit, so make all weighted views as wide as the largest child.
        // Children will have already been measured once.
        if (useLargestChild && widthMode == ULKLayoutMeasureSpecModeUnspecified) {
            for (int i = 0; i < count; i++) {
                UIView *child = [self subviews][i];
                
                if (child.ulk_visibility == ULKViewVisibilityGone) {
                    continue;
                }
                
                ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *) child.ulk_layoutParams;
                
                float childExtra = lp.weight;
                if (childExtra > 0) {
                    ULKLayoutMeasureSpec childWidthMeasureSpec;
                    ULKLayoutMeasureSpec childHeightMeasureSpec;
                    childWidthMeasureSpec.size = largestChildWidth;
                    childWidthMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
                    childHeightMeasureSpec.size = child.ulk_measuredSize.height;
                    childHeightMeasureSpec.mode = ULKLayoutMeasureSpecModeExactly;
                    [child ulk_measureWithWidthMeasureSpec:childWidthMeasureSpec heightMeasureSpec:childHeightMeasureSpec];
                }
            }
        }
    }
    
    if (!allFillParent && heightMode != ULKLayoutMeasureSpecModeExactly) {
        maxHeight = alternativeMaxHeight;
    }
    
    maxHeight += padding.top + padding.bottom;
    
    // Check against our minimum height
    maxHeight = MAX(maxHeight, minSize.height);
    maxHeight = MIN(maxHeight, maxSize.height);
    
    widthSizeAndState.state |= childState.widthState;
    ULKLayoutMeasuredSize measuredSize = ULKLayoutMeasuredSizeMake(widthSizeAndState, [UIView ulk_resolveSizeAndStateForSize:maxHeight measureSpec:heightMeasureSpec childMeasureState:childState.heightState]);
    [self ulk_setMeasuredDimensionSize:measuredSize];
    
    if (matchHeight) {
        [self forceUniformHeightWithCount:count widthMeasureSpec:widthMeasureSpec];
    }
}


- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    if (_orientation == LinearLayoutOrientationVertical) {
        [self measureVerticalWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    } else {
        [self measureHorizontalWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
    }
}

/**
 * <p>Return the location offset of the specified child. This can be used
 * by subclasses to change the location of a given widget.</p>
 *
 * @param child the child for which to obtain the location offset
 * @return the location offset in pixels
 */
-(CGFloat)locationOffsetOfChild:(UIView *)child {
    return 0;
}

/**
 * Position the children during a layout pass if the orientation of this
 * LinearLayout is set to LinearLayoutOrientationVertical.
 */
- (void)layoutVertical {
    UIEdgeInsets padding = self.ulk_padding;
    
    CGFloat childTop;
    CGFloat childLeft;
    
    // Where right end of child should go
    CGFloat width = self.frame.size.width;
    CGFloat childRight = width - padding.right;
    
    // Space available for child
    CGFloat childSpace = width - padding.left - padding.right;
    
    NSInteger count = [self.subviews count];
    
    ULKGravity majorGravity = _gravity & VERTICAL_GRAVITY_MASK;
    ULKGravity minorGravity = _gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    
    switch (majorGravity) {
        case ULKGravityBottom:
            // mTotalLength contains the padding already
            childTop = padding.top + self.frame.size.height - _totalLength;
            break;
            
            // mTotalLength contains the padding already
        case ULKGravityCenterVertical:
            childTop = padding.top + (self.frame.size.height - _totalLength) / 2;
            break;
            
        case ULKGravityTop:
        default:
            childTop = padding.top;
            break;
    }
    
    for (int i = 0; i < count; i++) {
        UIView *child = (self.subviews)[i];
        if (child.ulk_visibility != ULKViewVisibilityGone) {
            CGSize childSize = child.ulk_measuredSize;
            
            ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)child.ulk_layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            ULKGravity gravity = lp.gravity;
            if (gravity < ULKGravityNone) {
                gravity = minorGravity;
            }
            switch (gravity & HORIZONTAL_GRAVITY_MASK) {
                case ULKGravityCenterHorizontal:
                    childLeft = padding.left + ((childSpace - childSize.width) / 2)
                    + lpMargin.left - lpMargin.right;
                    break;
                    
                case ULKGravityRight:
                    childLeft = childRight - childSize.width - lpMargin.right;
                    break;
                    
                case ULKGravityLeft:
                default:
                    childLeft = padding.left + lpMargin.left;
                    break;
            }
            
            childTop += lpMargin.top;
            [child ulk_setFrame:CGRectMake(childLeft, childTop + [self locationOffsetOfChild:child], childSize.width, childSize.height)];
            childTop += childSize.height + lpMargin.bottom + [self nextLocationOffsetOfChild:child];
            
            i += [self childrenSkipCountAfterChild:child atIndex:i];
        }
    }
}

/**
 * Position the children during a layout pass if the orientation of this
 * LinearLayout is set to LinearLayoutOrientationHorizontal.
 */
- (void)layoutHorizontal {
    UIEdgeInsets padding = self.ulk_padding;
    
    CGFloat childTop;
    CGFloat childLeft;
    
    // Where bottom of child should go
    CGFloat height = self.frame.size.height;
    CGFloat childBottom = height - padding.bottom; 
    
    // Space available for child
    CGFloat childSpace = height - padding.top - padding.bottom;
    
    NSInteger count = [self.subviews count];
    
    ULKGravity majorGravity = _gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    ULKGravity minorGravity = _gravity & VERTICAL_GRAVITY_MASK;
    
    BOOL baselineAligned = _baselineAligned;
    switch (majorGravity) {
        case ULKGravityRight:
            // mTotalLength contains the padding already
            childLeft = padding.left + self.frame.size.width - _totalLength;
            break;
            
        case ULKGravityCenterHorizontal:
            // mTotalLength contains the padding already
            childLeft = padding.left + (self.frame.size.width - _totalLength) / 2;
            break;
            
        case ULKGravityLeft:
        default:
            childLeft = padding.left;
            break;
    }
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *child = (self.subviews)[i];
        if (child.ulk_visibility != ULKViewVisibilityGone) {
            
            CGSize childSize = child.ulk_measuredSize;
            CGFloat childBaseline = -1;
            
            ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)child.ulk_layoutParams;
            UIEdgeInsets lpMargin = lp.margin;
            
            if (baselineAligned && lp.height != ULKLayoutParamsSizeMatchParent) {
                childBaseline = child.ulk_baseline;
            }
            
            ULKGravity gravity = lp.gravity;
            if (gravity < ULKGravityNone) {
                gravity = minorGravity;
            }
            
            switch (gravity & VERTICAL_GRAVITY_MASK) {
                case ULKGravityTop:
                    childTop = padding.top + lpMargin.top;
                    if (childBaseline != -1) {
                        childTop += _maxAscent[MAX_ASCENT_DESCENT_INDEX_TOP] - childBaseline;
                    }
                    break;
                    
                case ULKGravityCenterVertical:
                    childTop = padding.top + ((childSpace - childSize.height) / 2) + lpMargin.top - lpMargin.bottom;
                    break;
                    
                case ULKGravityBottom:
                    childTop = childBottom - childSize.height - lpMargin.bottom;
                    if (childBaseline != -1) {
                        int descent = childSize.height - childBaseline;
                        childTop -= (_maxDescent[MAX_ASCENT_DESCENT_INDEX_BOTTOM] - descent);
                    }
                    break;
                default:
                    childTop = padding.top;
                    break;
            }
            
            childLeft += lpMargin.left;
            [child ulk_setFrame:CGRectMake(childLeft + [self locationOffsetOfChild:child], childTop,
                                                                  childSize.width, childSize.height)];
            childLeft += childSize.width + lpMargin.right + [self nextLocationOffsetOfChild:child];
            
            i += [self childrenSkipCountAfterChild:child atIndex:i];
        }
    }
}


- (void)ulk_onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    if (_orientation == LinearLayoutOrientationVertical) {
        [self layoutVertical];
    } else {
        [self layoutHorizontal];
    }
}

- (BOOL)ulk_checkLayoutParams:(ULKLayoutParams *)layoutParams {
    return [layoutParams isKindOfClass:[ULKLinearLayoutParams class]];
}

-(ULKLayoutParams *)ulk_generateLayoutParamsFromLayoutParams:(ULKLayoutParams *)layoutParams {
    return [[ULKLinearLayoutParams alloc] initWithLayoutParams:layoutParams];
}

@end
