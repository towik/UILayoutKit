//
//  NSDictionary+ULK_ResourceManager.m
//  UILayoutKit
//
//  Created by Tom Quist on 02.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "NSDictionary+ULK_ResourceManager.h"
#import "ULKResourceManager.h"
#import "UIColor+ULK_ColorParser.h"

@implementation NSDictionary (ULK_ResourceManager)

- (NSString *)ulk_stringFromIDLValueForKey:(NSString *)key {
    NSString *ret = nil;
    NSString *text = self[key];
    if ([[ULKResourceManager currentResourceManager] isValidIdentifier:text]) {
        NSString *textFromResouces = [[ULKResourceManager currentResourceManager] stringForIdentifier:text];
        ret = textFromResouces;
    } else {
        ret = text;
    }
    return ret;
}

- (UIColor *)ulk_colorFromIDLValueForKey:(NSString *)key {
    UIColor *ret = nil;
    id value = self[key];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = value;
        if ([[ULKResourceManager currentResourceManager] isValidIdentifier:string]) {
            ret = [[ULKResourceManager currentResourceManager] colorForIdentifier:string];
        } else {
            ret = [UIColor ulk_colorFromIDLColorString:string];
        }
    }
    return ret;
}

- (ULKColorStateList *)ulk_colorStateListFromIDLValueForKey:(NSString *)key {
    ULKColorStateList *ret = nil;
    id value = self[key];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = value;
        ret = [[ULKResourceManager currentResourceManager] colorStateListForIdentifier:string];
    }
    return ret;
}

- (CGFloat)ulk_dimensionFromIDLValueForKey:(NSString *)key {
    return [self ulk_dimensionFromIDLValueForKey:key defaultValue:0];
}

- (CGFloat)ulk_dimensionFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue {
    CGFloat ret = 0;
    id value = self[key];
    if (value == nil) {
        ret = defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([[ULKResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            ret = [value floatValue];
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = [value floatValue];
    }
    return ret;
}

- (float)ulk_fractionValueFromIDLValueForKey:(NSString *)key {
    return [self ulk_fractionValueFromIDLValueForKey:key defaultValue:0];
}

- (float)ulk_fractionValueFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue {
    float ret = defaultValue;
    id value = self[key];
    if (value == nil) {
        ret = defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = nil;
        if ([[ULKResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            stringValue = value;
        }
        if ([stringValue hasSuffix:@"%"]) {
            ret = [stringValue floatValue] / 100.f;
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = [value floatValue];
    }
    return ret;
}

- (BOOL)ulk_isFractionIDLValueForKey:(NSString *)key {
    BOOL ret = FALSE;
    id value = self[key];
    if (value == nil) {
        ret = FALSE;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = nil;
        if ([[ULKResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            stringValue = value;
        }
        ret = [stringValue hasSuffix:@"%"];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = FALSE;
    }
    return ret;
}

- (BOOL)ulk_boolFromIDLValueForKey:(NSString *)key {
    return [self ulk_boolFromIDLValueForKey:key defauleValue:FALSE];
}

- (BOOL)ulk_boolFromIDLValueForKey:(NSString *)key defauleValue:(BOOL)defaultValue {
    BOOL ret = defaultValue;
    id value = self[key];
    if (value == nil) {
        ret = defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([[ULKResourceManager currentResourceManager] isValidIdentifier:value]) {
#warning Implement dimension resources
        } else {
            ret = [value boolValue];
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        ret = [value boolValue];
    }
    return ret;
}

@end
