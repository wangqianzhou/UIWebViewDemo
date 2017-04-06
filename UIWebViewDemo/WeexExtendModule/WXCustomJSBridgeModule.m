//
//  WXCustomJSBridgeModule.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 06/04/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "WXCustomJSBridgeModule.h"
#import "BannerViewController.h"

@implementation WXCustomJSBridgeModule
@synthesize weexInstance = _weexInstance;

WX_EXPORT_METHOD(@selector(runJavascriptInHost:callback:))

- (void)runJavascriptInHost:(NSString*)js callback:(WXModuleCallback)callback
{
    if ([self.weexInstance.viewController isKindOfClass:[BannerViewController class]])
    {
        BannerViewController* controller = (BannerViewController*)self.weexInstance.viewController;
        
        [controller runWeexJavascript:js withCompleteHandler:^(id result) {
            callback(result);
        }];
    }
}

WX_EXPORT_METHOD(@selector(openURL:callback:))
- (void)openURL:(NSString *)url callback:(WXModuleCallback)callback
{
    if ([self.weexInstance.viewController isKindOfClass:[BannerViewController class]])
    {
        BannerViewController* controller = (BannerViewController*)self.weexInstance.viewController;
        
        [controller openURL:url];
        
        callback(@(YES));
    }
}
@end
