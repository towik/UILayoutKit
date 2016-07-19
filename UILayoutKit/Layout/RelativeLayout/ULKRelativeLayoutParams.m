//
//  RelativeLayoutLayoutParams.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKRelativeLayoutParams.h"
#import "UIView+ULK_Layout.h"

@interface ULKRelativeLayoutParams ()

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

@implementation ULKRelativeLayoutParams {
    BOOL _alignParentLeft;
    BOOL _alignParentTop;
    BOOL _alignParentRight;
    BOOL _alignParentBottom;
    BOOL _centerInParent;
    BOOL _centerHorizontal;
    BOOL _centerVertical;
}

- (instancetype) initUlk_WithAttributes:(NSDictionary *)attrs {
	self = [super initUlk_WithAttributes:attrs];
	if (self != nil) {
		NSString *leftOf = attrs[@"layout_toLeftOf"];
        NSString *rightOf = attrs[@"layout_toRightOf"];
        NSString *above = attrs[@"layout_above"];
        NSString *below = attrs[@"layout_below"];
        NSString *alignBaseline = attrs[@"layout_alignBaseline"];
        NSString *alignLeft = attrs[@"layout_alignLeft"];
        NSString *alignTop = attrs[@"layout_alignTop"];
        NSString *alignRight = attrs[@"layout_alignRight"];
        NSString *alignBottom = attrs[@"layout_alignBottom"];
        
        _alignParentLeft = ULKBOOLFromString(attrs[@"layout_alignParentLeft"]);
        _alignParentTop = ULKBOOLFromString(attrs[@"layout_alignParentTop"]);
        _alignParentRight = ULKBOOLFromString(attrs[@"layout_alignParentRight"]);
        _alignParentBottom = ULKBOOLFromString(attrs[@"layout_alignParentBottom"]);
        _centerInParent = ULKBOOLFromString(attrs[@"layout_centerInParent"]);
        _centerHorizontal = ULKBOOLFromString(attrs[@"layout_centerHorizontal"]);
        _centerVertical = ULKBOOLFromString(attrs[@"layout_centerVertical"]);
        
        NSNull *null = [NSNull null];
        _rules = @[(leftOf==nil?null:leftOf),
                  (rightOf==nil?null:rightOf),
                  (above==nil?null:above),
                  (below==nil?null:below),
                  (alignBaseline==nil?null:alignBaseline),
                  (alignLeft==nil?null:alignLeft),
                  (alignTop==nil?null:alignTop),
                  (alignRight==nil?null:alignRight),
                  (alignBottom==nil?null:alignBottom),
                  @(_alignParentLeft),
                  @(_alignParentTop),
                  @(_alignParentRight),
                  @(_alignParentBottom),
                  @(_centerInParent),
                  @(_centerHorizontal),
                  @(_centerVertical)];
	}
	return self;
}

@end


@implementation UIView (ULK_RelativeLayoutParams)

- (void)setRelativeLayoutParams:(ULKRelativeLayoutParams *)relativeLayoutLayoutParams {
    self.layoutParams = relativeLayoutLayoutParams;
}

- (ULKRelativeLayoutParams *)relativeLayoutParams {
    ULKLayoutParams *layoutParams = self.layoutParams;
    if (![layoutParams isKindOfClass:[ULKRelativeLayoutParams class]]) {
        layoutParams = [[ULKRelativeLayoutParams alloc] initWithLayoutParams:layoutParams];
        self.layoutParams = layoutParams;
    }
    
    return (ULKRelativeLayoutParams *)layoutParams;
}

@end
