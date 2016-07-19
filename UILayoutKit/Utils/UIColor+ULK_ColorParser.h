//
//  UIColor+ULK_ColorParser.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ULK_ColorParser)

+ (UIColor *)ulk_colorFromIDLColorString:(NSString *)string;

@end
