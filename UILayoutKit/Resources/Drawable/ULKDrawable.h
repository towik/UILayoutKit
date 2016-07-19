//
//  ULKDrawable.h
//  UILayoutKit
//
//  Created by Tom Quist on 16.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXPORT NSUInteger const ULKDrawableMaxLevel;

@class ULKDrawableConstantState;
@protocol ULKDrawableDelegate;

@interface ULKDrawable : NSObject <NSCopying>

@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize intrinsicSize;
@property (nonatomic, assign) UIControlState state;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, readonly) NSUInteger level;

@property (nonatomic, readonly) ULKDrawable *currentDrawable;
@property (nonatomic, readonly, getter = isStateful) BOOL stateful;
@property (nonatomic, readonly) BOOL hasPadding;
@property (nonatomic, readonly) UIEdgeInsets padding;
@property (nonatomic, readonly) ULKDrawableConstantState *constantState;

@property (nonatomic, weak) id<ULKDrawableDelegate> delegate;

- (void)drawInContext:(CGContextRef)context;

- (UIImage *)renderToImage;
- (BOOL)setLevel:(NSUInteger)level;

+ (ULKDrawable *)createFromXMLData:(NSData *)data;
+ (ULKDrawable *)createFromXMLURL:(NSURL *)url;

@end

@interface ULKDrawableConstantState : NSObject

@end

@protocol ULKDrawableDelegate <NSObject>
@required
- (void)drawableDidInvalidate:(ULKDrawable *)drawable;

@end