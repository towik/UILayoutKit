//
//  ULKColorStateList.h
//  UILayoutKit
//
//  Created by Tom Quist on 06.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKResourceStateList.h"
#import "ULKColorStateItem.h"
#import "ULKDrawable.h"

@interface ULKColorStateList : ULKResourceStateList

- (UIColor *)colorForControlState:(UIControlState)controlState defaultColor:(UIColor *)defaultColor;
- (UIColor *)colorForControlState:(UIControlState)controlState;
- (ULKDrawable *)convertToDrawable;

+ (instancetype)createFromXMLData:(NSData *)data;
+ (instancetype)createFromXMLURL:(NSURL *)url;
+ (instancetype)createWithSingleColorIdentifier:(NSString *)colorIdentifier;

@end
