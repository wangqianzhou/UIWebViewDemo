//
//  BannerViewController.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 31/03/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "BannerViewController.h"
#import <WeexSDK/WXSDKInstance.h>

@interface BannerView : UIView

@end

@implementation BannerView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

@end

@interface BannerViewController ()
@property(nonatomic, strong)WXSDKInstance* instance;
@property(nonatomic, strong)UIView* weexView;
@end

@implementation BannerViewController
- (void)loadView
{
    self.view = [[BannerView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    _instance.frame = self.view.frame;
    
    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        
        weakSelf.weexView = view;
        weakSelf.weexView.frame = weakSelf.view.bounds;
        weakSelf.weexView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [weakSelf.view addSubview:weakSelf.weexView];
    };
    _instance.onFailed = ^(NSError *error) {
        //process failure
    };
    _instance.renderFinish = ^ (UIView *view) {
        //process renderFinish
    };
    
    [_instance renderWithURL:self.url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_instance destroyInstance];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [_instance renderWithURL:self.url];
}
@end
