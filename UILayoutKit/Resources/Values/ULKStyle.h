//
//  ULKStyle.h
//  UILayoutKit
//
//  Created by Tom Quist on 09.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ULKStyle : NSObject

@property (weak, nonatomic, readonly) ULKStyle *parentStyle;
@property (weak, nonatomic, readonly) NSDictionary *attributes;

@end
