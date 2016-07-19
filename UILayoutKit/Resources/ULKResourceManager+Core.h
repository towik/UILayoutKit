//
//  ULKResourceManager+Core.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ULKColorStateList;
@class ULKStyle;

@interface ULKResourceManager : NSObject

+ (instancetype)currentResourceManager;

- (BOOL)isValidIdentifier:(NSString *)identifier;
- (BOOL)invalidateCacheForBundle:(NSBundle *)bundle;

- (NSURL *)layoutURLForIdentifier:(NSString *)identifierString;
- (UIImage *)imageForIdentifier:(NSString *)identifierString withCaching:(BOOL)withCaching;
- (UIImage *)imageForIdentifier:(NSString *)identifierString;
- (UIColor *)colorForIdentifier:(NSString *)identifierString;
- (ULKColorStateList *)colorStateListForIdentifier:(NSString *)identifierString;
- (ULKStyle *)styleForIdentifier:(NSString *)identifierString;

/**
 * Changes the currently used resource manager. This can be used to change
 * the behaviour of resource resolution.
 */
+ (void)setCurrentResourceManager:(ULKResourceManager *)resourceManager;
+ (void)resetCurrentResourceManager;

@end
