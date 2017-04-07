//
//  BannerWebViewController.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 07/04/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "BannerWebViewController.h"
#import <WebKit/WebKit.h>

@interface BannerWebViewController ()
@property(nonatomic, strong)NSString* url;
@property(nonatomic, strong)WKWebView* webview;
@end

@implementation BannerWebViewController
- (instancetype)initWithURL:(NSString*)url
{
    if (self = [super init])
    {
        self.url = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_webview];
    
    [self loadURL:_url];
}


- (void)loadURL:(NSString*)url
{
    if ([url length] == 0)
    {
        return ;
    }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
