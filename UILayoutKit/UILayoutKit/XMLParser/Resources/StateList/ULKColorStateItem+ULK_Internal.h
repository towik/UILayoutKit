//
//  ULKColorStateItem+ULK_Internal.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKColorStateItem.h"

@interface ULKColorStateItem (ULK_Internal)

- (instancetype)initWithControlState:(UIControlState)controlState colorResourceIdentifier:(NSString *)resourceIdentifier;

@end
