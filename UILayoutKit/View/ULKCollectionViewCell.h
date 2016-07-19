//
//  ULKCollectionViewCell.h
//  UILayoutKit
//
//  Created by Tom Quist on 06.12.14.
//  Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ULKLayoutBridge;

@interface ULKCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic, readonly) ULKLayoutBridge *layoutBridge;

- (instancetype)initWithLayoutResource:(NSString *)resource NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayoutURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

- (CGFloat)requiredHeightForWidth:(CGFloat)width;
- (CGFloat)requiredWidthForHeight:(CGFloat)height;
- (CGSize)preferredSize;


@end
