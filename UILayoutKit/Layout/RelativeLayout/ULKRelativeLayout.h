//
//  RelativeLayout.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKViewGroup.h"
#import "ULKGravity.h"
#import "ULKDependencyGraph.h"
#import "ULKRelativeLayoutParams.h"


@interface ULKRelativeLayout : ULKViewGroup

@property (nonatomic, assign) ULKViewContentGravity gravity;
@property (nonatomic, copy) NSString *ignoreGravity;

@end
