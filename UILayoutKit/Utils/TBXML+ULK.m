//
//  TBXML+ULK.m
//  UILayoutKit
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "TBXML+ULK.h"

@implementation TBXML (ULK)

+ (NSMutableDictionary *)ulk_attributesFromXMLElement:(TBXMLElement *)element reuseDictionary:(NSMutableDictionary *)dict {
    if (dict == nil) {
        dict = [NSMutableDictionary dictionaryWithCapacity:20];
    } else {
        [dict removeAllObjects];
    }
    [TBXML iterateAttributesOfElement:element withBlock:^(TBXMLAttribute *attribute, NSString *attributeName, NSString *attributeValue) {
        NSRange prefixRange = [attributeName rangeOfString:@":"];
        if (prefixRange.location != NSNotFound) {
            attributeName = [attributeName substringFromIndex:(prefixRange.location+1)];
        }
        dict[attributeName] = attributeValue;
    }];
    return dict;
}

@end
