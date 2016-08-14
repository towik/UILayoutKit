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

@interface UIView (ULK_XMLParser)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs;
- (instancetype)initUlk_WithAttributes:(NSDictionary *)attrs;

@end
