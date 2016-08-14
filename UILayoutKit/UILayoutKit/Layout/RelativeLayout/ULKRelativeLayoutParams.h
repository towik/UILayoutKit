//
//  RelativeLayoutLayoutParams.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKLayoutParams.h"

typedef NS_ENUM(NSUInteger ,ULKRelativeLayoutRule) {
    /**
     * Rule that aligns a child's right edge with another child's left edge.
     */
    ULKRelativeLayoutRuleLeftOf = 0,
    /**
     * Rule that aligns a child's left edge with another child's right edge.
     */
    ULKRelativeLayoutRuleRightOf = 1,
    /**
     * Rule that aligns a child's bottom edge with another child's top edge.
     */
    ULKRelativeLayoutRuleAbove = 2,
    /**
     * Rule that aligns a child's top edge with another child's bottom edge.
     */
    ULKRelativeLayoutRuleBelow = 3,
    
    /**
     * Rule that aligns a child's baseline with another child's baseline.
     */
    ULKRelativeLayoutRuleAlignBaseline = 4,
    /**
     * Rule that aligns a child's left edge with another child's left edge.
     */
    ULKRelativeLayoutRuleAlignLeft = 5,
    /**
     * Rule that aligns a child's top edge with another child's top edge.
     */
    ULKRelativeLayoutRuleAlignTop = 6,
    /**
     * Rule that aligns a child's right edge with another child's right edge.
     */
    ULKRelativeLayoutRuleAlignRight = 7,
    /**
     * Rule that aligns a child's bottom edge with another child's bottom edge.
     */
    ULKRelativeLayoutRuleAlignBottom = 8,
    
    /**
     * Rule that aligns the child's left edge with its RelativeLayout
     * parent's left edge.
     */
    ULKRelativeLayoutRuleAlignParentLeft = 9,
    /**
     * Rule that aligns the child's top edge with its RelativeLayout
     * parent's top edge.
     */
    ULKRelativeLayoutRuleAlignParentTop = 10,
    /**
     * Rule that aligns the child's right edge with its RelativeLayout
     * parent's right edge.
     */
    ULKRelativeLayoutRuleAlignParentRight = 11,
    /**
     * Rule that aligns the child's bottom edge with its RelativeLayout
     * parent's bottom edge.
     */
    ULKRelativeLayoutRuleAlignParentBottom = 12,
    
    /**
     * Rule that centers the child with respect to the bounds of its
     * RelativeLayout parent.
     */
    ULKRelativeLayoutRuleCenterInParent = 13,
    /**
     * Rule that centers the child horizontally with respect to the
     * bounds of its RelativeLayout parent.
     */
    ULKRelativeLayoutRuleCenterHorizontal = 14,
    /**
     * Rule that centers the child vertically with respect to the
     * bounds of its RelativeLayout parent.
     */
    ULKRelativeLayoutRuleCenterVertical = 15
};

@interface ULKRelativeLayoutParams : ULKLayoutParams

@property (nonatomic, strong) NSArray *rules;
@property (nonatomic, assign) BOOL alignWithParent;
@property (nonatomic, assign) BOOL alignParentLeft;
@property (nonatomic, assign) BOOL alignParentTop;
@property (nonatomic, assign) BOOL alignParentRight;
@property (nonatomic, assign) BOOL alignParentBottom;
@property (nonatomic, assign) BOOL centerInParent;
@property (nonatomic, assign) BOOL centerHorizontal;
@property (nonatomic, assign) BOOL centerVertical;

@end


@interface UIView (ULK_RelativeLayoutParams)

@end