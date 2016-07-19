//
//  ULKDrawableStateList.h
//  UILayoutKit
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKResourceStateList.h"
#import "ULKDrawableStateItem.h"
#import "ULKColorStateList.h"

@interface ULKDrawableStateList : ULKResourceStateList

- (UIImage *)imageForControlState:(UIControlState)controlState defaultImage:(UIImage *)defaultImage;
- (UIImage *)imageForControlState:(UIControlState)controlState;

+ (ULKDrawableStateList *)createFromXMLData:(NSData *)data;
+ (ULKDrawableStateList *)createFromXMLURL:(NSURL *)url;
+ (instancetype)createWithSingleDrawableIdentifier:(NSString *)imageIdentifier;
+ (ULKDrawableStateList *)createFromColorStateList:(ULKColorStateList *)colorStateList;

@end
