//
//  BannerViewController.h
//  UIWebViewDemo
//
//  Created by wangqianzhou on 31/03/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BannerViewControllerDelegate <NSObject>

- (void)runWeexJavascript:(NSString*)js withCompleteHandler:(void(^)(id result))completeHandler;

- (void)openURL:(NSString*)url;
@end

@interface BannerViewController : UIViewController

@property(nonatomic, assign)id<BannerViewControllerDelegate> delegate;

- (instancetype)initWithName:(NSString*)name source:(NSString*)source;

- (void)runWeexJavascript:(NSString*)js withCompleteHandler:(void(^)(id result))completeHandler;

- (void)openURL:(NSString*)url;
@end
