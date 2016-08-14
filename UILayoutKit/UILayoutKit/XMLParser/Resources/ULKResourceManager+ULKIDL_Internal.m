//
//  ULKResourceManager+ULK_Internal.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceManager+ULK_Internal.h"


NSString *NSStringFromIDLResourceType(ULKResourceType type) {
    NSString *ret;
    switch (type) {
        case ULKResourceTypeString:
            ret = @"string";
            break;
        case ULKResourceTypeLayout:
            ret = @"layout";
            break;
        case ULKResourceTypeDrawable:
            ret = @"drawable";
            break;
        case ULKResourceTypeColor:
            ret = @"color";
            break;
        case ULKResourceTypeStyle:
            ret = @"style";
            break;
        case ULKResourceTypeValue:
            ret = @"value";
            break;
        case ULKResourceTypeArray:
            ret = @"array";
            break;
        default:
            ret = nil;
            break;
    }
    return ret;
}

ULKResourceType ULKResourceTypeFromString(NSString *typeString) {
    ULKResourceType ret = ULKResourceTypeUnknown;
    if ([typeString isEqualToString:@"string"]) {
        ret = ULKResourceTypeString;
    } else if ([typeString isEqualToString:@"layout"]) {
        ret = ULKResourceTypeLayout;
    } else if ([typeString isEqualToString:@"drawable"]) {
        ret = ULKResourceTypeDrawable;
    } else if ([typeString isEqualToString:@"color"]) {
        ret = ULKResourceTypeColor;
    } else if ([typeString isEqualToString:@"style"]) {
        ret = ULKResourceTypeStyle;
    } else if ([typeString isEqualToString:@"value"]) {
        ret = ULKResourceTypeValue;
    } else if ([typeString isEqualToString:@"array"]) {
        ret = ULKResourceTypeArray;
    }
    return ret;
}

@interface ULKResourceIdentifier()

- (instancetype)initWithString:(NSString *)string;

+ (BOOL)isResourceIdentifier:(NSString *)string;

@end

@implementation ULKResourceIdentifier


- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        BOOL valid = TRUE;
        if ([string length] > 0 && [string characterAtIndex:0] == '@') {
            NSRange separatorRange = [string rangeOfString:@"/"];
            if (separatorRange.location != NSNotFound) {
                NSRange firstPartRange = NSMakeRange(1, separatorRange.location - 1);
                NSRange identifierRange = NSMakeRange(separatorRange.location+1, [string length] - separatorRange.location - 1);
                NSString *identifier = [string substringWithRange:identifierRange];
                NSRange colonRange = [string rangeOfString:@":" options:0 range:firstPartRange];
                
                NSString *bundleIdentifier = nil;
                NSString *typeIdentifier = nil;
                if (colonRange.location != NSNotFound) {
                    bundleIdentifier = [string substringWithRange:NSMakeRange(1, colonRange.location - 1)];
                    typeIdentifier = [string substringWithRange:NSMakeRange(colonRange.location + firstPartRange.location, firstPartRange.length - colonRange.location)];
                } else {
                    typeIdentifier = [string substringWithRange:firstPartRange];
                }
                self.bundleIdentifier = bundleIdentifier;
                self.type = ULKResourceTypeFromString(typeIdentifier);
                if (self.type == ULKResourceTypeUnknown) {
                    valid = FALSE;
                }
                self.identifier = identifier;
            } else {
                valid = FALSE;
            }
        } else {
            valid = FALSE;
        }
        if (!valid) {
            self = nil;
        }
        
    }
    return self;
}

- (NSString *)description {
    NSString *ret = nil;
    NSString *bundleIdentifier = self.bundle!=nil?self.bundle.bundleIdentifier:self.bundleIdentifier;
    NSString *typeName = NSStringFromIDLResourceType(self.type);
    if (bundleIdentifier) {
        ret = [NSString stringWithFormat:@"@%@:%@/%@", bundleIdentifier, typeName, self.identifier];
    } else {
        ret = [NSString stringWithFormat:@"@%@/%@", typeName, self.identifier];
    }
    return ret;
}

+ (BOOL)isResourceIdentifier:(NSString *)string {
    static NSRegularExpression *regex;
    if (regex == nil) {
        regex = [[NSRegularExpression alloc] initWithPattern:@"@([A-Za-z0-9\\.\\-]+:)?[a-z]+/[A-Za-z0-9_\\.]+" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return string != nil && [string isKindOfClass:[NSString class]] && [string length] > 0 && [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])].location != NSNotFound;
}

@end

