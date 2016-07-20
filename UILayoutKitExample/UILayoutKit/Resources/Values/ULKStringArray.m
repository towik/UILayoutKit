//
//  ULKStringArray.m
//  UILayoutKit
//
//  Created by Tom Quist on 15.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKStringArray.h"
#import "ULKResourceManager.h"

@interface ULKStringArray ()

@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, assign) CFMutableBitVectorRef resolvedInfo;

@end

@implementation ULKStringArray

- (void)dealloc {
    CFRelease(_resolvedInfo);
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        self.content = [array mutableCopy];
        _resolvedInfo = CFBitVectorCreateMutable(CFAllocatorGetDefault(), [array count]);
        CFBitVectorSetCount(_resolvedInfo, [array count]);
    }
    return self;
}

- (NSUInteger)count {
    return  [self.content count];
}

- (id)objectAtIndex:(NSUInteger)index {
    id value = (self.content)[index];
    if (value == [NSNull null]) {
        value = nil;
    }
    if (!CFBitVectorGetBitAtIndex(_resolvedInfo, index)) {
        ULKResourceManager *resMgr = [ULKResourceManager currentResourceManager];
        if ([resMgr isValidIdentifier:value]) {
            value = [resMgr stringForIdentifier:value];
            if (value == nil) {
                (self.content)[index] = [NSNull null];
            } else {
                (self.content)[index] = value;
            }
        }
        CFBitVectorFlipBitAtIndex(_resolvedInfo, index);
    }
    return value;
}

@end
