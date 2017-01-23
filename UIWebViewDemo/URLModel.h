//
//  URLModel.h
//  UIWebViewDemo
//
//  Created by wangqianzhou on 14/01/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLModelDelegate<NSObject>

- (void)onModelChanged;

@end

@interface URLModel : NSObject

- (void)addObserver:(id<URLModelDelegate>)observer;
- (void)removeObserver:(id<URLModelDelegate>)observer;

+ (instancetype)model;

- (NSInteger)itemCount;

- (NSString*)itemAtIndex:(NSInteger)index;

- (void)addItem:(NSString*)url;

@end
