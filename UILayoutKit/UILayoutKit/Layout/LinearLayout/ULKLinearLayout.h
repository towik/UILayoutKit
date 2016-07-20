//
//  LinearLayout.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKViewGroup.h"
#import "ULKLinearLayoutParams.h"
#import "ULKGravity.h"

#define MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL 0
#define MAX_ASCENT_DESCENT_INDEX_TOP 1
#define MAX_ASCENT_DESCENT_INDEX_BOTTOM 2
#define MAX_ASCENT_DESCENT_INDEX_FILL 3
#define VERTICAL_GRAVITY_COUNT 4

typedef NS_ENUM(NSInteger, LinearLayoutOrientation) {
    LinearLayoutOrientationHorizontal,
    LinearLayoutOrientationVertical
};


@interface ULKLinearLayout : ULKViewGroup

@property (nonatomic, assign) LinearLayoutOrientation orientation;
@property (nonatomic, assign) ULKViewContentGravity gravity;
@property (nonatomic, assign) float weightSum;

@end