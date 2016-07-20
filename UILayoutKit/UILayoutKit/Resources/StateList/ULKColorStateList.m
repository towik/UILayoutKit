//
//  ULKColorStateList.m
//  UILayoutKit
//
//  Created by Tom Quist on 06.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKColorStateList.h"
#import "UIView+ULK_Layout.h"
#import "ULKResourceManager.h"
#import "UIColor+ULK_ColorParser.h"
#import "ULKColorStateItem+ULK_Internal.h"
#import "ULKResourceStateList+ULK_Internal.h"
#import "ULKStateListDrawable.h"
#import "ULKColorDrawable.h"

@interface ULKColorStateList ()

- (ULKColorStateItem *)itemForControlState:(UIControlState)controlState;

@end

@implementation ULKColorStateList

+ (ULKColorStateItem *)createItemWithControlState:(UIControlState)controlState fromElement:(TBXMLElement *)element {
    ULKColorStateItem *ret = nil;
    NSString *colorIdentifier = [TBXML valueOfAttributeNamed:@"color" forElement:element];
    if (colorIdentifier == nil) {
        NSLog(@"<item> tag requires a 'color' attribute. I'm ignoring this color state item.");
    } else {
        ret = [[ULKColorStateItem alloc] initWithControlState:controlState colorResourceIdentifier:colorIdentifier];
    }
    return ret;
}

+ (instancetype)createWithSingleColorIdentifier:(NSString *)colorIdentifier {
    ULKColorStateList *list = [[self alloc] init];
    ULKColorStateItem *item = [[ULKColorStateItem alloc] initWithControlState:UIControlStateNormal colorResourceIdentifier:colorIdentifier];
    list.internalItems = @[item];
    return list;
}

+ (instancetype)createFromXMLData:(NSData *)data {
    return (ULKColorStateList *)[super createFromXMLData:data];
}

+ (instancetype)createFromXMLURL:(NSURL *)url {
    return (ULKColorStateList *)[super createFromXMLURL:url];
}

- (ULKColorStateItem *)itemForControlState:(UIControlState)controlState {
    return (ULKColorStateItem *)[super itemForControlState:controlState];
}

- (UIColor *)colorForControlState:(UIControlState)controlState defaultColor:(UIColor *)defaultColor {
    UIColor *ret = defaultColor;
    ULKColorStateItem *item = [self itemForControlState:controlState];
    if (item != nil) {
        ret = item.color;
    }
    return ret;
}

- (UIColor *)colorForControlState:(UIControlState)controlState {
    return [self colorForControlState:controlState defaultColor:nil];
}

- (ULKDrawable *)convertToDrawable {
    ULKStateListDrawable *drawable = [[ULKStateListDrawable alloc] initWithColorStateListe:self];
    return drawable;
}

@end
