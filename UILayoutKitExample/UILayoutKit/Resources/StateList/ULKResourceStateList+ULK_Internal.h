//
//  ULKResourceStateList+ULK_Internal.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKResourceStateList.h"
#import "TBXML.h"
#import "ULKResourceStateItem.h"

@interface ULKResourceStateList (ULK_Internal)

@property (nonatomic, retain) NSArray *internalItems;

+ (ULKResourceStateItem *)createItemWithControlState:(UIControlState)controlState fromElement:(TBXMLElement *)element;

- (ULKResourceStateItem *)itemForControlState:(UIControlState)controlState;

@end
