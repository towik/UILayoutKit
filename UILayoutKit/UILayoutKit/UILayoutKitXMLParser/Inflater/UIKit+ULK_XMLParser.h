//
//  UIKit+ULK_XMLParser.h
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <UIKit/UIKit.h>

BOOL ULKBOOLFromString(NSString *boolString);
ULKViewVisibility ULKViewVisibilityFromString(NSString *visibilityString);

@interface ULKLayoutParams (ULK_XMLParser)

- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs;

@end


@interface UIView (ULK_XMLParser)

- (ULKLayoutParams *)ulk_generateLayoutParamsFromAttributes:(NSDictionary *)attrs;

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs;
- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs;

@end
