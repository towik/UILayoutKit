//
//  ULKResourceManager+ULK_Internal.h
//  UILayoutKit
//
//  Created by Tom Quist on 28.03.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "ULKResourceManager+Core.h"

@class ULKXMLCache;
@class ULKResourceValueSet;

typedef NS_ENUM(NSInteger, ULKResourceType) {
    ULKResourceTypeUnknown,
    ULKResourceTypeString,
    ULKResourceTypeLayout,
    ULKResourceTypeDrawable,
    ULKResourceTypeColor,
    ULKResourceTypeStyle,
    ULKResourceTypeValue,
    ULKResourceTypeArray
};

NSString *NSStringFromIDLResourceType(ULKResourceType type);
ULKResourceType ULKResourceTypeFromString(NSString *typeString);

@interface ULKResourceIdentifier : NSObject

@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, assign) ULKResourceType type;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak) NSBundle *bundle;
@property (nonatomic, strong) id cachedObject;
@property (nonatomic, strong) NSString *valueIdentifier;

- (instancetype)initWithString:(NSString *)string NS_DESIGNATED_INITIALIZER;
+ (BOOL)isResourceIdentifier:(NSString *)string;

@end

@interface ULKResourceManager (ULK_Internal)

@property (retain) ULKXMLCache *xmlCache;
- (ULKResourceIdentifier *)resourceIdentifierForString:(NSString *)identifierString;
- (NSBundle *)resolveBundleForIdentifier:(ULKResourceIdentifier *)identifier;
- (NSString *)valueSetIdentifierForIdentifier:(ULKResourceIdentifier *)identifier;
- (ULKResourceValueSet *)resourceValueSetForIdentifier:(NSString *)identifierString;

@end
