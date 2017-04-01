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
@end

@implementation BannerViewController
- (instancetype)initWithName:(NSString*)name
{
    if (self = [super init])
    {
        self.name = name;
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
        
        SetBorderColor(view, [UIColor greenColor]);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_instance destroyInstance];
}

- (void)setSource:(NSString *)source
{
    [_instance renderView:source options:nil data:nil];
    _source = source;
}

- (void)setName:(NSString *)name
{
    _name = name;
    _instance.pageName = name;
}
@end
