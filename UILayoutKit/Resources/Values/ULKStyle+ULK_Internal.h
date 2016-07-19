//
//  ULKStyle+ULK_Internal.h
//  UILayoutKit
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKStyle.h"
#import "TBXML.h"

@interface ULKStyle (ULK_Internal)

+ (ULKStyle *)createFromXMLElement:(TBXMLElement *)element;

@end
