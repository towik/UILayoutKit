//
//  UIImage+ULKNinePatch.h
//  UILayoutKit
//
//  Created by Tom Quist on 19.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ULKNinePatch)

+ (UIImage *)ulk_imageWithName:(NSString *)name fromBundle:(NSBundle *)bundle;

@property (nonatomic, readonly) BOOL ulk_hasNinePatchPaddings;
@property (nonatomic, readonly) UIEdgeInsets ulk_ninePatchPaddings;

@end
