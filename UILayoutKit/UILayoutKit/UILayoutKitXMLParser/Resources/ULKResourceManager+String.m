//
//  ULKResourceManager+String.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceManager+String.h"
#import "ULKResourceValueSet.h"
#import "ULKResourceManager+ULK_Internal.h"

@implementation ULKResourceManager (String)


- (NSString *)stringForIdentifier:(NSString *)identifierString {
    NSString *ret = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        NSString *valueSetIdentifier = [self valueSetIdentifierForIdentifier:identifier];
        if ([valueSetIdentifier length] > 0) {
            ULKResourceValueSet *valueSet = [self resourceValueSetForIdentifier:valueSetIdentifier];
            if (valueSet != nil) {
                NSRange range = [identifier.identifier rangeOfString:@"."];
                if (range.location != NSNotFound && range.location > 0) {
                    ret = [valueSet stringForName:[identifier.identifier substringFromIndex:range.location+1]];
                }
                
            }
        }
        if (ret == nil) {
            // Fallback to localized strings
            NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
            ret = [bundle localizedStringForKey:identifier.identifier value:nil table:nil];
        }
    }
    return ret;
}


- (NSArray *)stringArrayForIdentifier:(NSString *)identifierString {
    NSArray *array = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == ULKResourceTypeArray) {
        if (identifier.cachedObject != nil) {
            array = identifier.cachedObject;
        } else if (identifier != nil) {
            ULKResourceValueSet *valueSet = [self resourceValueSetForIdentifier:identifierString];
            if (valueSet != nil) {
                NSRange range = [identifier.identifier rangeOfString:@"."];
                if (range.location != NSNotFound && range.location > 0) {
                    array = [valueSet stringArrayForName:[identifier.identifier substringFromIndex:range.location+1]];
                }
            }
            if (array != nil) {
                identifier.cachedObject = array;
            }
        }
    }
    return array;
}



@end
