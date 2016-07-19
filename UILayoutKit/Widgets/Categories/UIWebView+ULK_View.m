//
//  UIWebView+ULK_View.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIWebView+ULK_View.h"
#import "UIView+ULK_Layout.h"

@implementation UIWebView (ULK_View)

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs {
    [super ulk_setupFromAttributes:attrs];
    NSString *src = attrs[@"src"];
    if (src != nil) {
        NSURL *url = [NSURL URLWithString:src];
        [self loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end
