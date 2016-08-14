//
//  ULKDrawableStateList.m
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKDrawableStateList.h"
#import "UIImage+ULK_FromColor.h"
#import "ULKResourceStateList+ULK_Internal.h"
#import "ULKResourceStateList+ULK_Internal.h"
#import "ULKDrawableStateItem+ULK_Internal.h"

@interface ULKColorWrapperDrawableStateItem : ULKDrawableStateItem

@property (nonatomic, strong) ULKColorStateItem *colorStateItem;

- (instancetype)initWithColorStateItem:(ULKColorStateItem *)colorStateItem NS_DESIGNATED_INITIALIZER;

@end

@implementation ULKColorWrapperDrawableStateItem

- (instancetype)initWithColorStateItem:(ULKColorStateItem *)colorStateItem {
    self = [super initWithControlState:colorStateItem.controlState drawableResourceIdentifier:nil];
    if (self) {
        self.colorStateItem = colorStateItem;
    }
    return self;
}

- (UIImage *)image {
    return [UIImage ulk_imageFromColor:self.colorStateItem.color withSize:CGSizeMake(1, 1)];
}

@end

@interface ULKDrawableStateList ()

- (ULKDrawableStateItem *)itemForControlState:(UIControlState)controlState;

@end

@implementation ULKDrawableStateList

+ (ULKDrawableStateItem *)createItemWithControlState:(UIControlState)controlState fromElement:(TBXMLElement *)element {
    ULKDrawableStateItem *ret = nil;
    NSString *drawableIdentifier = [TBXML valueOfAttributeNamed:@"drawable" forElement:element];
    if (drawableIdentifier == nil) {
        NSAssert(0, @"<item> tag requires a 'drawable' attribute. I'm ignoring this drawable state item.");
    } else {
        ret = [[ULKDrawableStateItem alloc] initWithControlState:controlState drawableResourceIdentifier:drawableIdentifier];
    }
    return ret;
}

+ (instancetype)createWithSingleDrawableIdentifier:(NSString *)imageIdentifier {
    ULKDrawableStateList *list = [[self alloc] init];
    ULKDrawableStateItem *item = [[ULKDrawableStateItem alloc] initWithControlState:UIControlStateNormal drawableResourceIdentifier:imageIdentifier];
    list.internalItems = @[item];
    return list;
}

+ (ULKDrawableStateList *)createFromXMLData:(NSData *)data {
    return (ULKDrawableStateList *)[super createFromXMLData:data];
}

+ (ULKDrawableStateList *)createFromXMLURL:(NSURL *)url {
    return (ULKDrawableStateList *)[super createFromXMLURL:url];
}

+ (ULKDrawableStateList *)createFromColorStateList:(ULKColorStateList *)colorStateList {
    ULKDrawableStateList *ret = nil;
    if (colorStateList != nil) {
        ret = [[ULKDrawableStateList alloc] init];
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[colorStateList.items count]];
        for (ULKColorStateItem *colorStateItem in colorStateList.items) {
            ULKDrawableStateItem *item = [[ULKColorWrapperDrawableStateItem alloc] initWithColorStateItem:colorStateItem];
            [items addObject:item];
        }
        ret.internalItems = items;
    }
    return ret;
}

- (ULKDrawableStateItem *)itemForControlState:(UIControlState)controlState {
    return (ULKDrawableStateItem *)[super itemForControlState:controlState];
}

- (UIImage *)imageForControlState:(UIControlState)controlState defaultImage:(UIImage *)defaultImage {
    UIImage *ret = defaultImage;
    ULKDrawableStateItem *item = [self itemForControlState:controlState];
    if (item != nil) {
        ret = item.image;
    }
    return ret;
}

- (UIImage *)imageForControlState:(UIControlState)controlState {
    return [self imageForControlState:controlState defaultImage:nil];
}

@end
