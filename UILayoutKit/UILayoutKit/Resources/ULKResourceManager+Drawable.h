//
//  ULKResourceManager+Drawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceManager+Core.h"

@class ULKDrawable;
@class ULKDrawableStateList;

@interface ULKResourceManager (Drawable)

- (ULKDrawableStateList *)drawableStateListForIdentifier:(NSString *)identifierString;
- (ULKDrawable *)drawableForIdentifier:(NSString *)identifier;

@end
