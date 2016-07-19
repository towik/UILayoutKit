//
//  TBXML+ULK.h
//  UILayoutKit
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "TBXML.h"

@interface TBXML (ULK)

+ (NSMutableDictionary *)ulk_attributesFromXMLElement:(TBXMLElement *)element reuseDictionary:(NSMutableDictionary *)dict;

@end
