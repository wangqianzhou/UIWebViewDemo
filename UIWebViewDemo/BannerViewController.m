//
//  BannerViewController.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 31/03/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "BannerViewController.h"
#import <WeexSDK/WXSDKInstance.h>
#import "UIView+Addtions.h"

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
@property(nonatomic, strong)NSString* name;
@property(nonatomic, strong)NSString* source;
@end

@implementation BannerViewController
- (instancetype)initWithName:(NSString*)name source:(NSString*)source
{
    if (self = [super init])
    {
        self.name = name;
        self.source = source;
    }
    
    return self;
}


- (void)loadView
{
    self.view = [[BannerView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    _instance.frame = self.view.frame;
    _instance.pageName = _name;
    
    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        
        SetBorderColor(view, [UIColor redColor]);
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
    
    if ([_source length]) {
        [_instance renderView:_source options:nil data:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerAsObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unregisterAsObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_instance destroyInstance];
}

- (void)runWeexJavascript:(NSString*)js withCompleteHandler:(void(^)(id result))completeHandler
{
    [self.delegate runWeexJavascript:js withCompleteHandler:completeHandler];
}

- (void)openURL:(NSString*)url
{
    [self.delegate openURL:url];
}

#pragma mark- KVO
- (void)registerAsObserver
{
    [self.view addObserver:self
                         forKeyPath:@"frame"
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                            context:nil];
}

- (void)unregisterAsObserver
{
    [self.view removeObserver:self
                            forKeyPath:@"frame"
                               context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == self.view && [keyPath isEqualToString:@"frame"])
    {
        [_instance setFrame:self.view.bounds];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

@end
