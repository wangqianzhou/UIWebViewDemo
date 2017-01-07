//
//  CustomPreferences.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 15/12/3.
//  Copyright © 2015年 uc. All rights reserved.
//

#import "CustomPreferences.h"
#import "CustomURLProtocol.h"
#import <objc/message.h>

@implementation CustomPreferences

+ (void)initPreferences
{
    [self initUserAgent];
    [self initCustomProtocol];
//    [self initCacheModel];
}

+ (void)initCustomProtocol
{
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
}


+ (void)initUserAgent
{
    NSDictionary *dictionary = @{@"UserAgent": @"Mozilla/5.0 (iPhone Simulator; CPU iPhone OS 8_1 like Mac OS X; zh-CN) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/12B411 UCBrowser/10.2.5.533 Mobile"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

+ (void)initCacheModel
{
    Class wvCls = NSClassFromString(@"WebView");
    ((void(*)(Class cls, SEL sel, int))objc_msgSend)(wvCls, @selector(_setCacheModel:), 2);
}


@end
