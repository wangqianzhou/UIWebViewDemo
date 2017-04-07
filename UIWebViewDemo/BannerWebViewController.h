//
//  BannerWebViewController.h
//  UIWebViewDemo
//
//  Created by wangqianzhou on 07/04/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BannerWebViewControllerDelegate <NSObject>

@end


@interface BannerWebViewController : UIViewController

- (instancetype)initWithURL:(NSString*)url;

@property(nonatomic, assign)id<BannerWebViewControllerDelegate> delegate;
@end
