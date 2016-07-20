
#import "ULKStyle.h"
#import "ULKStyle+ULK_Internal.h"
#import "ULKResourceManager.h"

@interface ULKStyle ()

@property (nonatomic, strong) NSMutableDictionary *internalAttributes;
@property (nonatomic, strong) NSString *parentIdentifier;
@property (nonatomic, strong) ULKStyle *internalParentStyle;
@property (nonatomic, assign) BOOL includesParentStyleAttributes;

@end

//
//  ULKStyle.m
//  UILayoutKit
//
//  Created by Tom Quist on 09.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

@implementation ULKStyle

- (instancetype)initUlk_WithAttributes:(NSMutableDictionary *)attributes arentIdentifier:(NSString *)parentIdentifier {
    self = [super init];
    if (self) {
        if ([parentIdentifier length] > 0) {
            self.parentIdentifier = parentIdentifier;
        } else {
            self.includesParentStyleAttributes = TRUE;
        }
        self.internalAttributes = attributes;
    }
    return self;
}

+ (ULKStyle *)createFromXMLElement:(TBXMLElement *)element {
    NSString *parentStyleId = [TBXML valueOfAttributeNamed:@"parent" forElement:element];
    TBXMLElement *child = element->firstChild;
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    while (child != NULL) {
        NSString *childName = [TBXML elementName:child];
        if ([childName isEqualToString:@"item"]) {
            NSString *name = [TBXML valueOfAttributeNamed:@"name" forElement:child];
            NSRange prefixRange = [name rangeOfString:@":"];
            if (prefixRange.location != NSNotFound) {
                name = [name substringFromIndex:(prefixRange.location+1)];
            }
            NSString *value = [TBXML textForElement:child];
            if (name != nil && [name length] > 0 && value != nil) {
                attributes[name] = value;
            }
        }
        child = child->nextSibling;
    }
    ULKStyle *style = [[ULKStyle alloc] initUlk_WithAttributes:attributes arentIdentifier:parentStyleId];
    return style;
}

- (NSDictionary *)attributes {
    // Lazy-load parent style attributes
    // Double-Checked locking should be fine here, even though it is an anti-pattern in other cases
    if (!self.includesParentStyleAttributes) {
        @synchronized(self) {
            if (!self.includesParentStyleAttributes) {
                NSDictionary *parentAttributes = self.parentStyle.attributes;
                for (NSString *name in [parentAttributes allKeys]) {
                    if ((self.internalAttributes)[name] == nil) {
                        id value = parentAttributes[name];
                        (self.internalAttributes)[name] = value;
                    }
                }
                self.includesParentStyleAttributes = TRUE;
            }
        }
    }
    return self.internalAttributes;
}

- (ULKStyle *)parentStyle {
    ULKStyle *parentStyle = self.internalParentStyle;
    if (parentStyle == nil && [self.parentIdentifier length] > 0) {
        parentStyle = [[ULKResourceManager currentResourceManager] styleForIdentifier:self.parentIdentifier];
        self.internalParentStyle = parentStyle;
    }
    return  parentStyle;
}

@end
