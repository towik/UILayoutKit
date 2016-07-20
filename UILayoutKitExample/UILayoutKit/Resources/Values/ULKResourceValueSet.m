//
//  ULKResourceValueSet.m
//  UILayoutKit
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceValueSet.h"
#import "ULKStyle+ULK_Internal.h"
#import "TBXML.h"
#import "ULKResourceManager.h"
#import "ULKStringArray.h"

@interface ULKResourceValueSet ()

@property (nonatomic, strong) NSDictionary *values;

@end

@implementation ULKResourceValueSet

+ (NSArray *)parseStringArrayFromElement:(TBXMLElement *)element {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    TBXMLElement *child = element->firstChild;
    NSCharacterSet *whiteSpaceCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (child != nil) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            NSString *value = [[TBXML textForElement:child] stringByTrimmingCharactersInSet:whiteSpaceCharSet];
            [array addObject:value];
        }
        child = child->nextSibling;
    }
    NSArray *nonMutableArray = [[ULKStringArray alloc] initWithArray:array];
    return nonMutableArray;
}

+ (instancetype)inflateParser:(TBXML *)parser {
    ULKResourceValueSet *ret = nil;
    TBXMLElement *root = parser.rootXMLElement;
    if ([[TBXML elementName:root] isEqualToString:@"resources"]) {
        ret = [[self alloc] init];
        NSCharacterSet *whiteSpaceCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSMutableDictionary *mutableValues = [[NSMutableDictionary alloc] init];
        TBXMLElement *child = root->firstChild;
        while (child != nil) {
            NSString *tagName = [TBXML elementName:child];
            NSString *resourceName = [TBXML valueOfAttributeNamed:@"name" forElement:child];
            if ([resourceName length] > 0) {
                if ([tagName isEqualToString:@"style"]) {
                    ULKStyle *style = [ULKStyle createFromXMLElement:child];
                    mutableValues[resourceName] = style;
                } else if ([tagName isEqualToString:@"string"]) {
                    NSString *string = [[TBXML textForElement:child] stringByTrimmingCharactersInSet:whiteSpaceCharSet];
                    mutableValues[resourceName] = string;
                } else if([tagName isEqualToString:@"string-array"]) {
                    NSArray *stringArray = [self parseStringArrayFromElement:child];
                    mutableValues[resourceName] = stringArray;
                }
            }
            child = child->nextSibling;
        }
        NSDictionary *nonMutableValues = [[NSDictionary alloc] initWithDictionary:mutableValues];
        ret.values = nonMutableValues;
    }
    return ret;
}

+ (ULKResourceValueSet *)createFromXMLData:(NSData *)data {
    if (data == nil) return nil;
    ULKResourceValueSet *ret = nil;
    NSError *error = nil;
    TBXML *xml = [TBXML tbxmlWithXMLData:data error:&error];
    if (error == nil) {
        ret = [self inflateParser:xml];
    } else {
        NSLog(@"Could not parse resource value set: %@", error);
    }
    return ret;
}

+ (ULKResourceValueSet *)createFromXMLURL:(NSURL *)url {
    return [self createFromXMLData:[NSData dataWithContentsOfURL:url]];
}

- (ULKStyle *)styleForName:(NSString *)name {
    ULKStyle *ret = nil;
    id value = (self.values)[name];
    if ([value isKindOfClass:[ULKStyle class]]) {
        ret = value;
    }
    return ret;
}

- (NSString *)stringForName:(NSString *)name {
    NSString *ret = nil;
    id value = (self.values)[name];
    if ([value isKindOfClass:[NSString class]]) {
        ret = value;
        ULKResourceManager *resourceManager = [ULKResourceManager currentResourceManager];
        if ([resourceManager isValidIdentifier:ret]) {
            ret = [resourceManager stringForIdentifier:ret];
        }
    }
    return ret;
}

- (NSArray *)stringArrayForName:(NSString *)name {
    NSArray *ret = nil;
    id value = (self.values)[name];
    if ([value isKindOfClass:[ULKStringArray class]]) {
        ret = value;
    }
    return ret;
}

@end
