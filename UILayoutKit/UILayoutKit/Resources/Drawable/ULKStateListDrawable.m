//
//  ULKStateListDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKStateListDrawable.h"
#import "ULKDrawableContainer+ULK_Internal.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "ULKResourceManager.h"
#import "UIView+ULK_Layout.h"

@interface ULKStateListDrawableItem : NSObject

@property (nonatomic, assign) UIControlState state;
@property (nonatomic, strong) ULKDrawable *drawable;

@end

@implementation ULKStateListDrawableItem


@end


@interface ULKStateListDrawableConstantState ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ULKStateListDrawableConstantState


- (instancetype)initWithState:(ULKStateListDrawableConstantState *)state owner:(ULKStateListDrawable *)owner {
    self = [super initWithState:state owner:owner];
    if (self) {
        if (state != nil) {
            NSInteger count = MIN([self.drawables count], [state.items count]);
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:count];
            for (NSInteger i = 0; i<count; i++) {
                ULKStateListDrawableItem *origItem = (state.items)[i];
                ULKStateListDrawableItem *item = [[ULKStateListDrawableItem alloc] init];
                item.drawable = (self.drawables)[i];
                item.state = origItem.state;
                [items addObject:item];
            }
            self.items = items;
        } else {
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:10];
            self.items = items;
        }
    }
    return self;
}

- (void)addDrawable:(ULKDrawable *)drawable forState:(UIControlState)state {
    ULKStateListDrawableItem *item = [[ULKStateListDrawableItem alloc] init];
    item.drawable = drawable;
    item.state = state;
    [self.items addObject:item];
    [self addChildDrawable:drawable];
}

@end

@interface ULKStateListDrawable ()

@property (nonatomic, strong) ULKStateListDrawableConstantState *internalConstantState;

@end

@implementation ULKStateListDrawable


- (instancetype)initWithState:(ULKStateListDrawableConstantState *)state {
    self = [super init];
    if (self) {
        ULKStateListDrawableConstantState *s = [[ULKStateListDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (instancetype)initWithColorStateListe:(ULKColorStateList *)colorStateList {
    self = [self init];
    if (self) {
        for (ULKColorStateItem *item in colorStateList.items) {
            ULKColorDrawable *colorDrawable = [[ULKColorDrawable alloc] initWithColor:item.color];
            [self.internalConstantState addDrawable:colorDrawable forState:item.controlState];
        }
    }
    return self;
}

- (NSInteger)indexOfState:(UIControlState)state {
    NSInteger ret = -1;
    NSInteger count = [self.internalConstantState.items count];
    for (NSInteger i = 0; i < count; i++) {
        ULKStateListDrawableItem *item = (self.internalConstantState.items)[i];
        if ((item.state & state) == item.state) {
            ret = i;
            break;
        }
    }
    return ret;
}
- (void)onStateChangeToState:(UIControlState)state {
    NSInteger idx = [self indexOfState:self.state];
    if (![self selectDrawableAtIndex:idx]) {
        [super onStateChangeToState:state];
    }
}

- (BOOL)isStateful {
    return TRUE;
}

- (UIControlState)controlStateForAttribute:(NSString *)attributeName {
    UIControlState controlState = UIControlStateNormal;
    if ([attributeName isEqualToString:@"state_disabled"]) {
        controlState |= UIControlStateDisabled;
    } else if ([attributeName isEqualToString:@"state_highlighted"] || [attributeName isEqualToString:@"state_pressed"] || [attributeName isEqualToString:@"state_focused"]) {
        controlState |= UIControlStateHighlighted;
    } else if ([attributeName isEqualToString:@"state_selected"]) {
        controlState |= UIControlStateSelected;
    }
    return controlState;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    
    
    self.internalConstantState.constantSize = ULKBOOLFromString(attrs[@"constantSize"]);
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *tagName = [TBXML elementName:child];
        if ([tagName isEqualToString:@"item"]) {
            attrs = [TBXML ulk_attributesFromXMLElement:child reuseDictionary:attrs];
            UIControlState state = UIControlStateNormal;
            for (NSString *attrName in [attrs allKeys]) {
                BOOL value = ULKBOOLFromString(attrs[attrName]);
                if (value) {
                    state |= [self controlStateForAttribute:attrName];
                }
            }
            NSString *drawableResId = attrs[@"drawable"];
            ULKDrawable *drawable = nil;
            if (drawableResId != nil) {
                drawable = [[ULKResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
            } else if (child->firstChild != NULL) {
                drawable = [ULKDrawable createFromXMLElement:child->firstChild];
            } else {
                NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
            }
            if (drawable != nil) {
                [self.internalConstantState addDrawable:drawable forState:state];
            }
        }
        child = child->nextSibling;
    }
    
    
}

@end
