//
//  ULKResourceManager+Core.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceManager+Core.h"
#import "ULKResourceManager+ULK_Internal.h"
#import "UIImage+ULK_FromColor.h"
#import "ULKResourceValueSet.h"
#import "UIImage+ULKNinePatch.h"
#import "ULKXMLCache.h"
#import "ULKColorStateList.h"


@interface ULKResourceManager ()

@property (strong) NSMutableDictionary *resourceIdentifierCache;
@property (strong) ULKXMLCache *xmlCache;

@end

@implementation ULKResourceManager

static ULKResourceManager *currentResourceManager;

+ (void)initialize {
    [super initialize];
    currentResourceManager = [self defaultResourceManager];
    currentResourceManager.xmlCache = [ULKXMLCache sharedInstance];
}

+ (instancetype)defaultResourceManager {
    static ULKResourceManager *resourceManager;
    if (resourceManager == nil) {
        resourceManager = [[self alloc] init];
    }
    return resourceManager;
}

+ (ULKResourceManager *)currentResourceManager {
    @synchronized(self) {
        return currentResourceManager;
    }
}

+ (void)setCurrentResourceManager:(ULKResourceManager *)resourceManager {
    @synchronized(self) {
        currentResourceManager = resourceManager;
    }
}

+ (void)resetCurrentResourceManager {
    [self setCurrentResourceManager:[self defaultResourceManager]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.resourceIdentifierCache = [NSMutableDictionary dictionary];
        self.xmlCache = [[ULKXMLCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    for (ULKResourceIdentifier *identifier in [self.resourceIdentifierCache allValues]) {
        identifier.cachedObject = nil;
    }
}

- (BOOL)isValidIdentifier:(NSString *)identifier {
    return [ULKResourceIdentifier isResourceIdentifier:identifier];
}

- (BOOL)invalidateCacheForBundle:(NSBundle *)bundle {
    NSSet *keysToRemove = [self.resourceIdentifierCache keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        ULKResourceIdentifier *resId = obj;
        NSBundle *resBundle = resId.bundle;
        return (resBundle == bundle || [resBundle.bundleIdentifier isEqualToString:bundle.bundleIdentifier]);
    }];
    [self.resourceIdentifierCache removeObjectsForKeys:[keysToRemove allObjects]];
    return [keysToRemove count] > 0;
}

- (ULKResourceIdentifier *)resourceIdentifierForString:(NSString *)identifierString {
    ULKResourceIdentifier *identifier = (self.resourceIdentifierCache)[identifierString];
    if (identifier == nil) {
        identifier = [[ULKResourceIdentifier alloc] initWithString:identifierString];
        if (identifier != nil) {
            (self.resourceIdentifierCache)[identifierString] = identifier;
            (self.resourceIdentifierCache)[[identifier description]] = identifier;
        }
    }
    return identifier;
}

- (NSBundle *)resolveBundleForIdentifier:(ULKResourceIdentifier *)identifier {
    if (identifier.bundle == nil) {
        if (identifier.bundleIdentifier == nil) {
            identifier.bundle = [NSBundle mainBundle];
        } else {
            identifier.bundle = [NSBundle bundleWithIdentifier:identifier.bundleIdentifier];
        }
    }
    return identifier.bundle;
}

- (NSURL *)layoutURLForIdentifier:(NSString *)identifierString {
    NSURL *ret = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        ret = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
    }
    return ret;
}

- (UIImage *)imageForIdentifier:(NSString *)identifierString withCaching:(BOOL)withCaching {
    UIImage *ret = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == ULKResourceTypeColor) {
        UIColor *color = [self colorForIdentifier:identifierString];
        ret = [UIImage ulk_imageFromColor:color withSize:CGSizeMake(1, 1)];
    } else if (identifier.type == ULKResourceTypeDrawable) {
        
        if (identifier.cachedObject != nil) {
            ret = identifier.cachedObject;
        } else if (identifier != nil) {
            NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
            ret = [UIImage ulk_imageWithName:identifier.identifier fromBundle:bundle];
        }
        if (withCaching && ret != nil) {
            identifier.cachedObject = ret;
        }
    } else {
        NSAssert(0, @"Could not create image from resource identifier %@: Invalid resource type", identifierString);
    }
    return ret;
}

- (UIImage *)imageForIdentifier:(NSString *)identifierString {
    return [self imageForIdentifier:identifierString withCaching:TRUE];
}

- (UIColor *)colorForIdentifier:(NSString *)identifierString {
    UIColor *ret = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil) {
        if (identifier.type == ULKResourceTypeDrawable) {
            UIImage *image = [self imageForIdentifier:identifierString];
            if (image != nil) {
                ret = [UIColor colorWithPatternImage:image];
            }
        }
    }
    return ret;
}

- (ULKColorStateList *)colorStateListForIdentifier:(NSString *)identifierString {
    ULKColorStateList *colorStateList = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.cachedObject != nil && ([identifier.cachedObject isKindOfClass:[ULKColorStateList class]] || [identifier.cachedObject isKindOfClass:[UIColor class]])) {
        if ([identifier.cachedObject isKindOfClass:[ULKColorStateList class]]) {
            colorStateList = identifier.cachedObject;
        } else if ([identifier.cachedObject isKindOfClass:[UIColor class]]) {
            colorStateList = [ULKColorStateList createWithSingleColorIdentifier:identifierString];
        }
    } else if (identifier.type == ULKResourceTypeColor) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
        if (url != nil) {
            colorStateList = [ULKColorStateList createFromXMLURL:url];
        }
        if (colorStateList != nil) {
            identifier.cachedObject = colorStateList;
        }
    }
    if (colorStateList == nil) {
        UIColor *color = [self colorForIdentifier:identifierString];
        if (color != nil) {
            colorStateList = [ULKColorStateList createWithSingleColorIdentifier:identifierString];
        }
    }
    
    return colorStateList;
}

- (NSString *)valueSetIdentifierForIdentifier:(ULKResourceIdentifier *)identifier {
    NSString *ret = nil;
    if (identifier.valueIdentifier != nil) {
        ret = identifier.valueIdentifier;
    } else {
        NSRange range = [identifier.identifier rangeOfString:@"."];
        if (range.location != NSNotFound && range.location > 0) {
            NSString *valueSetIdentifier = [identifier.identifier substringToIndex:range.location];
            NSString *bundleIdentifier = identifier.bundle!=nil?identifier.bundle.bundleIdentifier:identifier.bundleIdentifier;
            NSString *typeName = NSStringFromIDLResourceType(ULKResourceTypeValue);
            if (bundleIdentifier) {
                ret = [NSString stringWithFormat:@"@%@:%@/%@", bundleIdentifier, typeName, valueSetIdentifier];
            } else {
                ret = [NSString stringWithFormat:@"@%@/%@", typeName, valueSetIdentifier];
            }
            identifier.valueIdentifier = ret;
        }
    }
    return ret;
}

- (ULKResourceValueSet *)resourceValueSetForIdentifier:(NSString *)identifierString {
    ULKResourceValueSet *ret = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier != nil && identifier.type != ULKResourceTypeValue) {
        NSString *valueSetIdentifier = [self valueSetIdentifierForIdentifier:identifier];
        identifier = [self resourceIdentifierForString:valueSetIdentifier];
    }
    
    if (identifier != nil) {
        if (identifier.cachedObject != nil && [identifier.cachedObject isKindOfClass:[ULKResourceValueSet class]]) {
            ret = identifier.cachedObject;
        } else {
            NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
            NSString *extension = [identifier.identifier pathExtension];
            if ([extension length] == 0) {
                extension = @"xml";
            }
            NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
            if (url != nil) {
                ret = [ULKResourceValueSet createFromXMLURL:url];
            }
            if (ret != nil) {
                identifier.cachedObject = ret;
            }
        }
    }
    return ret;
}

- (ULKStyle *)styleForIdentifier:(NSString *)identifierString {
    ULKStyle *style = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == ULKResourceTypeStyle) {
        if (identifier.cachedObject != nil) {
            style = identifier.cachedObject;
        } else if (identifier != nil) {
            ULKResourceValueSet *valueSet = [self resourceValueSetForIdentifier:identifierString];
            if (valueSet != nil) {
                NSRange range = [identifier.identifier rangeOfString:@"."];
                if (range.location != NSNotFound && range.location > 0) {
                    style = [valueSet styleForName:[identifier.identifier substringFromIndex:range.location+1]];
                }
                
            }
            if (style != nil) {
                identifier.cachedObject = style;
            }
        }
    }
    return style;
}

@end
