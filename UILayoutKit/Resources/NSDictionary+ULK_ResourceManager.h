//
//  NSDictionary+ULK_ResourceManager.h
//  UILayoutKit
//
//  Created by Tom Quist on 02.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ULKColorStateList.h"

@interface NSDictionary (ULK_ResourceManager)

- (NSString *)ulk_stringFromIDLValueForKey:(NSString *)key;
- (UIColor *)ulk_colorFromIDLValueForKey:(NSString *)key;
- (ULKColorStateList *)ulk_colorStateListFromIDLValueForKey:(NSString *)key;
- (CGFloat)ulk_dimensionFromIDLValueForKey:(NSString *)key;
- (CGFloat)ulk_dimensionFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue;
- (float)ulk_fractionValueFromIDLValueForKey:(NSString *)key;
- (float)ulk_fractionValueFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue;
- (BOOL)ulk_isFractionIDLValueForKey:(NSString *)key;
- (BOOL)ulk_boolFromIDLValueForKey:(NSString *)key;
- (BOOL)ulk_boolFromIDLValueForKey:(NSString *)key defauleValue:(BOOL)defaultValue;


@end
