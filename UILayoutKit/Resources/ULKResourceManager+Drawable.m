//
//  ULKResourceManager+Drawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceManager+Drawable.h"
#import "ULKResourceManager+ULK_Internal.h"
#import "ULKDrawable.h"
#import "ULKDrawableStateList.h"
#import "ULKBitmapDrawable.h"
#import "ULKColorDrawable.h"
#import "UIColor+ULK_ColorParser.h"

@implementation ULKResourceManager (Drawable)


- (ULKDrawableStateList *)drawableStateListForIdentifier:(NSString *)identifierString {
    ULKDrawableStateList *drawableStateList = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.cachedObject != nil && ([identifier.cachedObject isKindOfClass:[ULKDrawableStateList class]] || [identifier.cachedObject isKindOfClass:[UIImage class]])) {
        if ([identifier.cachedObject isKindOfClass:[ULKDrawableStateList class]]) {
            drawableStateList = identifier.cachedObject;
        } else if ([identifier.cachedObject isKindOfClass:[UIImage class]]) {
            drawableStateList = [ULKDrawableStateList createWithSingleDrawableIdentifier:identifierString];
        }
    } else if (identifier.type == ULKResourceTypeDrawable) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
        if (url != nil) {
            drawableStateList = [ULKDrawableStateList createFromXMLURL:url];
        }
        if (drawableStateList != nil) {
            identifier.cachedObject = drawableStateList;
        }
    } else if (identifier.type == ULKResourceTypeColor) {
        ULKColorStateList *colorStateList = [self colorStateListForIdentifier:identifierString];
        if (colorStateList != nil) {
            drawableStateList = [ULKDrawableStateList createFromColorStateList:colorStateList];
        }
    }
    if (drawableStateList == nil) {
        UIImage *image = [self imageForIdentifier:identifierString];
        if (image != nil) {
            drawableStateList = [ULKDrawableStateList createWithSingleDrawableIdentifier:identifierString];
        }
    }
    
    return drawableStateList;
}


- (ULKDrawable *)drawableForIdentifier:(NSString *)identifierString {
    ULKDrawable *ret = nil;
    ULKResourceIdentifier *identifier = [self resourceIdentifierForString:identifierString];
    if (identifier.type == ULKResourceTypeDrawable && identifier.cachedObject != nil && ([identifier.cachedObject isKindOfClass:[ULKDrawable class]] || [identifier.cachedObject isKindOfClass:[UIImage class]])) {
        if ([identifier.cachedObject isKindOfClass:[ULKDrawable class]]) {
            ret = [identifier.cachedObject copy];
        } else if ([identifier.cachedObject isKindOfClass:[UIImage class]]) {
            ret = [[ULKBitmapDrawable alloc] initWithImage:identifier.cachedObject];
        }
    } else if (identifier.type == ULKResourceTypeDrawable) {
        NSBundle *bundle = [self resolveBundleForIdentifier:identifier];
        NSString *extension = [identifier.identifier pathExtension];
        if ([extension length] == 0) {
            extension = @"xml";
        }
        NSURL *url = [bundle URLForResource:[identifier.identifier stringByDeletingPathExtension] withExtension:extension];
        if (url != nil) {
            ret = [ULKDrawable createFromXMLURL:url];
        } else {
            UIImage *image = [self imageForIdentifier:identifierString];
            if (image != nil) {
                ret = [[ULKBitmapDrawable alloc] initWithImage:image];
            }
        }
        if (ret != nil) {
            identifier.cachedObject = ret;
            ret = [ret copy];
        }
    } else if (identifier.type == ULKResourceTypeColor) {
        ULKColorStateList *colorStateList = [self colorStateListForIdentifier:identifierString];
        if (colorStateList != nil) {
            ret = [colorStateList convertToDrawable];
        }
    }
    if (ret == nil) {
        UIImage *image = [self imageForIdentifier:identifierString];
        if (image != nil) {
            ret = [[ULKBitmapDrawable alloc] initWithImage:image];
        } else {
            UIColor *color = [UIColor ulk_colorFromIDLColorString:identifierString];
            if (color != nil) {
                ret = [[ULKColorDrawable alloc] initWithColor:color];
            }
        }
    }
    
    return ret;
}



@end
