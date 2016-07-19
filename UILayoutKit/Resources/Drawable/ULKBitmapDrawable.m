//
//  ULKBitmapDrawable.m
//  UILayoutKit
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKBitmapDrawable.h"
#import "ULKDrawable+ULK_Internal.h"
#import "TBXML+ULK.h"
#import "ULKResourceManager.h"
#import "UIImage+ULKNinePatch.h"

@interface ULKBitmapDrawableConstantState ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) ULKViewContentGravity gravity;

- (instancetype)initWithState:(ULKBitmapDrawableConstantState *)state;

@end

@implementation ULKBitmapDrawableConstantState


- (instancetype)initWithState:(ULKBitmapDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            self.image = state.image;
            self.gravity = state.gravity;
        } else {
            self.gravity = ULKViewContentGravityFill;
        }
    }
    return self;
}


@end

@interface ULKBitmapDrawable ()

@property (nonatomic, strong) ULKBitmapDrawableConstantState *internalConstantState;
@property (nonatomic, strong) UIImage *scaledImageCache;

- (instancetype)initWithState:(ULKBitmapDrawableConstantState *)state NS_DESIGNATED_INITIALIZER;

@end

@implementation ULKBitmapDrawable

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        ULKBitmapDrawableConstantState *state = [[ULKBitmapDrawableConstantState alloc] initWithState:nil];
        state.image = image;
        self.internalConstantState = state;
    }
    return self;
}

- (instancetype)initWithState:(ULKBitmapDrawableConstantState *)state {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        ULKBitmapDrawableConstantState *s = [[ULKBitmapDrawableConstantState alloc] initWithState:state];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)didReceiveMemoryWarning {
    self.scaledImageCache = nil;
}

- (UIImage *)image {
    return self.internalConstantState.image;
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the original image to the context
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    // Retrieve the UIImage from the current context
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (void)drawInContext:(CGContextRef)context {
    ULKBitmapDrawableConstantState *state = self.internalConstantState;
    CGRect containerRect = self.bounds;
    CGRect dstRect = CGRectZero;
    UIImage *image = state.image;
    
    [ULKGravity applyGravity:state.gravity width:image.size.width height:image.size.height containerRect:&containerRect outRect:&dstRect];
    if (self.scaledImageCache == nil) {
        //self.scaledImageCache = [self resizeImage:image toWidth:dstRect.size.width height:dstRect.size.height];
    }
    UIGraphicsPushContext(context);
    //[self.scaledImageCache drawInRect:dstRect];
    [image drawInRect:dstRect];
    UIGraphicsPopContext();
}

- (CGSize)intrinsicSize {
    return self.internalConstantState.image.size;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    ULKBitmapDrawableConstantState *state = self.internalConstantState;
    [super inflateWithElement:element];
    NSMutableDictionary *dictionary = [TBXML ulk_attributesFromXMLElement:element reuseDictionary:nil];
    NSString *bitmapIdentifier = dictionary[@"src"];
    if (bitmapIdentifier != nil) {
        ULKResourceManager *resMgr = [ULKResourceManager currentResourceManager];
        UIImage *image = [resMgr imageForIdentifier:bitmapIdentifier];
        state.image = image;
    } else {
        NSLog(@"<bitmap> requires a valid src attribute");
    }
    
    NSString *gravityValue = dictionary[@"gravity"];
    if (gravityValue != nil) {
        state.gravity = [ULKGravity gravityFromAttribute:gravityValue];
    }
}

- (CGSize)minimumSize {
    ULKBitmapDrawableConstantState *state = self.internalConstantState;
    if ([state.image respondsToSelector:@selector(capInsets)]) {
        UIEdgeInsets insets = state.image.capInsets;
        if (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
            return CGSizeMake(insets.left + insets.right, insets.top + insets.bottom);
        }
    }
    return [super minimumSize];
}

- (BOOL)hasPadding {
    return self.internalConstantState.image.ulk_hasNinePatchPaddings;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.image.ulk_ninePatchPaddings;
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    [super onBoundsChangeToRect:bounds];
    self.scaledImageCache = nil;
}

- (ULKDrawableConstantState *)constantState {
    return self.internalConstantState;
}

@end
