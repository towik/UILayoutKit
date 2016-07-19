//
//  ULKBaseViewFactory.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKBaseViewFactory.h"
#import "UIView+ULK_Layout.h"

@interface UIButton () 

- (void)ulk_setupFromAttributes:(NSDictionary *)attrs;

@end

@implementation ULKBaseViewFactory

- (UIButtonType)buttonTypeFromTypeAttribute:(NSString *)typeAttribute {
    UIButtonType ret = UIButtonTypeCustom;
    if (typeAttribute == nil || [typeAttribute isEqualToString:@"custom"]) {
        ret = UIButtonTypeCustom;
    } else if ([typeAttribute isEqualToString:@"roundedRect"]) {
        ret = UIButtonTypeRoundedRect;
    } else if ([typeAttribute isEqualToString:@"detailDisclosure"]) {
        ret = UIButtonTypeDetailDisclosure;
    } else if ([typeAttribute isEqualToString:@"infoLight"]) {
        ret = UIButtonTypeInfoLight;
    } else if ([typeAttribute isEqualToString:@"infoDark"]) {
        ret = UIButtonTypeInfoDark;
    } else if ([typeAttribute isEqualToString:@"contactAdd"]) {
        ret = UIButtonTypeContactAdd;
    }
    return ret;
}

- (UIButton *)onCreateUIButtonWithAttributes:(NSDictionary *)attrs {
    NSString *type = attrs[@"type"];
    UIButtonType buttonType = [self buttonTypeFromTypeAttribute:type];
    UIButton *button = [UIButton buttonWithType:buttonType];
    [button ulk_setupFromAttributes:attrs];
    return button;
}

- (UIView *)onCreateViewWithName:(NSString *)name attributes:(NSDictionary *)attrs {
    if ([name isEqualToString:@"UIButton"]) {
        return [self onCreateUIButtonWithAttributes:attrs];
    }
    Class viewClass = NSClassFromString(name);
    if (viewClass == NULL) {
        viewClass = NSClassFromString([NSString stringWithFormat:@"ULK%@", name]);
    }
    if (viewClass == NULL) {
        @throw [NSException exceptionWithName:@"ClassNotFoundException" reason:[NSString stringWithFormat:@"Class %@ could not be found", name] userInfo:nil];
    }
    if (![viewClass isSubclassOfClass:[UIView class]]) {
        @throw [NSException exceptionWithName:@"InvalidViewClass" reason:[NSString stringWithFormat:@"Class %@ is not a view.", name] userInfo:nil];
    }
    if (![viewClass instancesRespondToSelector:@selector(initUlk_WithAttributes:)]) {
        @throw [NSException exceptionWithName:@"InvalidViewClass" reason:[NSString stringWithFormat:@"Class %@ could not be instantiated. Missing selector initUlk_WithAttributes:", name] userInfo:nil];
    }
    return [[viewClass alloc] initUlk_WithAttributes:attrs];
}

@end
