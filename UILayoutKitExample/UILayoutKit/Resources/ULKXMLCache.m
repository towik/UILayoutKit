//
//  ULKXMLCache.m
//  UILayoutKit
//
//  Created by Tom Quist on 06.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//
//  Modified by towik on 19.07.16.
//  Copyright (c) 2016 towik. All rights reserved.
//

#import "ULKXMLCache.h"

@interface ULKXMLCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation ULKXMLCache


+ (ULKXMLCache *)sharedInstance {
    static ULKXMLCache *Instance = nil;
    if (Instance == nil) {
        @synchronized(self) {
            if (Instance == nil) {
                Instance = [[ULKXMLCache alloc] init];
            }
        }
    }
    return Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (TBXML *)xmlForUrl:(NSURL *)url error:(NSError **)error {
    TBXML *xml = [self.cache objectForKey:[url absoluteString]];
    if (xml == nil) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        @synchronized(self) {
            if (![self.cache objectForKey:[url absoluteString]]) {
                xml = [[TBXML alloc] initWithXMLData:data error:error];
                if (xml != nil) {
                    [self.cache setObject:xml forKey:[url absoluteString] cost:[data length]];
                } else if ([url isFileURL]) {
                    [self.cache setObject:(*error) forKey:[url absoluteString]  cost:1];
                }
            }
        }
    } else if ([xml isKindOfClass:[NSError class]]) {
        if (error != NULL) {
            (*error) = (NSError *)xml;
        }
        xml = nil;
    }
    return xml;
}

- (void)purge {
    [self.cache removeAllObjects];
}

@end
