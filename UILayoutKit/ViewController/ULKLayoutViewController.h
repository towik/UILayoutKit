//
//  ULKLayoutViewController.h
//  UILayoutKit
//
//  Created by Tom Quist on 23.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ULKLayoutBridge.h"

@interface ULKLayoutViewController : UIViewController

@property (nonatomic, strong) ULKLayoutBridge *view;

- (instancetype)initWithLayoutName:(NSString *)layoutNameOrNil bundle:(NSBundle *)layoutBundleOrNil;

@end
