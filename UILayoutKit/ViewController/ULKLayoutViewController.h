//
//  ULKLayoutViewController.h
//  UILayoutKit
//
//  Created by Tom Quist on 23.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ULKLayoutBridge.h"

@interface ULKLayoutViewController : UIViewController

@property (nonatomic, strong) ULKLayoutBridge *view;

- (instancetype)initWithLayoutName:(NSString *)layoutNameOrNil bundle:(NSBundle *)layoutBundleOrNil;

@end
