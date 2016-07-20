//
//  LinearLayoutLayoutParams.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKFrameLayoutParams.h"
#import "ULKViewGroup.h"
#import "ULKGravity.h"


@interface ULKLinearLayoutParams : ULKFrameLayoutParams

@property (nonatomic, assign) float weight;

@end


@interface UIView (ULK_LinearLayoutParams)

@property (nonatomic, assign) float layoutWeight;

@end