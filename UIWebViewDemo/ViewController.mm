//
//  ViewController.m
//  WebkitDemp
//
//  Created by wangqianzhou on 13-8-3.
//  Copyright (c) 2013年 uc. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import "CustomButton.h"
#import "UIView+Addtions.h"
#import "URLViewController.h"
#import "BannerViewController.h"
#import "BannerWebViewController.h"

#define ENABLE_DBG_LOG 0

#if ENABLE_DBG_LOG
#define DBG_LOG(frmt, ...) NSLog((frmt), ##__VA_ARGS__)
#else
#define DBG_LOG(frmt, ...) do{ } while(0)
#endif

static const CGFloat banner_height = 100;

@interface ViewController ()<UIWebViewDelegate,
                            URLViewControllerDelegate,
                            UIViewControllerPreviewingDelegate,
                            BannerViewControllerDelegate,
                            BannerWebViewControllerDelegate>

@property(nonatomic, strong)UIWebView* wkview;
@property(nonatomic, assign)NSInteger frameLoadCount;
@property(nonatomic, assign)UIView* browserview;
@property(nonatomic, strong)BannerViewController* topbanner;
@property(nonatomic, strong)BannerViewController* bottombanner;
@property(nonatomic, strong)BannerViewController* fixedbanner;

@property(nonatomic, strong)BannerWebViewController* topWebbanner;
@property(nonatomic, strong)BannerWebViewController* bottomWebbanner;
@property(nonatomic, strong)BannerWebViewController* fixedWebbanner;

@property(nonatomic, assign)BOOL useWeexBanner;

@end

@implementation ViewController
@synthesize wkview = _wkview;
@synthesize frameLoadCount = m_nFrameLoadCount;

- (id)init
{
    if (self = [super init])
    {
        m_nFrameLoadCount = 0;
        _useWeexBanner = YES;
    }
    
    return self;
}

- (void)loadView
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    UIView* mainView = [[UIView alloc] initWithFrame:rect];
    mainView.backgroundColor = [UIColor grayColor];
    self.view = mainView;
    

    UIWebView* webView = [[UIWebView alloc] initWithFrame:rect];
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.allowsLinkPreview = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.allowsLinkPreview = YES;
    [mainView addSubview:webView];
    self.wkview = webView;

    [webView.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIScrollView class]])
        {
            self.browserview = obj;
            *stop = YES;
        }
    }];

    
    [self registerAsObserver];
    
    [self initAllButtons];
}

- (void)initAllButtons
{
    //打开
    CustomButton* btn = [self buttonWithTitle:@"O"];
    btn.tag = 0;
    btn.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];

    btn = [self buttonWithTitle:@"R"];
    btn.tag = 1;
    btn.right = self.view.right;
    btn.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    btn = [self buttonWithTitle:@"<"];
    btn.tag = 2;
    btn.centerY = self.view.centerY;
    btn.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    btn = [self buttonWithTitle:@">"];
    btn.tag = 3;
    btn.right = self.view.right;
    btn.centerY = self.view.centerY;
    btn.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    btn = [self buttonWithTitle:@"WEB"];
    btn.tag = 4;
    btn.bottom = self.view.bottom;
    btn.backgroundColor = [[UIColor magentaColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    
    btn = [self buttonWithTitle:@"WX"];
    btn.tag = 5;
    btn.bottom = self.view.bottom;
    btn.right = self.view.right;
    btn.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
}

- (CustomButton*)buttonWithTitle:(NSString*)title
{
    CustomButton* btn = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, DefaultBtnWidth, DefaultBtnHeight)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)dealloc
{
    [self unregisterAsObserver];
    _wkview = nil;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self clearBanner];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    m_nFrameLoadCount++;
    [self updateLoadingState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    m_nFrameLoadCount--;
    [self updateLoadingState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    m_nFrameLoadCount--;
    [self updateLoadingState];
}

#pragma mark- URLViewControllerDelegate
- (void)onURLSelect:(NSString*)url
{
    [self loadWithURLString:url];
}

#pragma mark- BtnAction
- (void)onBtnClick:(id)sender
{
    NSInteger idx = [(UIButton*)sender tag];
    NSString* selName = [NSString stringWithFormat:@"onBtn_%ld", (long)idx];
    SEL sel = NSSelectorFromString(selName);
    
    ((void(*)(id,SEL))objc_msgSend)(self, sel);
}

- (void)onBtn_0
{
    URLViewController* ctl = [[URLViewController alloc] init];
    ctl.delegate = self;
    
    [self.navigationController pushViewController:ctl animated:YES];
    
}

- (void)onBtn_1
{
    [_wkview reload];
}

- (void)onBtn_2
{
    [_wkview goBack];
}

- (void)onBtn_3
{   
    [_wkview goForward];
}

//web
- (void)onBtn_4
{
    _useWeexBanner = NO;

    [_topbanner.view removeFromSuperview];
    [_bottombanner.view removeFromSuperview];
    [_fixedbanner.view removeFromSuperview];
    
    self.topbanner.delegate = nil;
    self.topbanner = nil;
    
    self.bottombanner.delegate = nil;
    self.bottombanner = nil;
    
    self.fixedbanner.delegate = nil;
    self.fixedbanner = nil;
    
    [self updateBanner];
}

//weex
- (void)onBtn_5
{
    _useWeexBanner = YES;

    [_topWebbanner.view removeFromSuperview];
    [_bottomWebbanner.view removeFromSuperview];
    [_fixedWebbanner.view removeFromSuperview];
    
    self.topWebbanner.delegate = nil;
    self.topWebbanner = nil;
    
    self.bottomWebbanner.delegate = nil;
    self.bottomWebbanner = nil;
    
    self.fixedWebbanner.delegate = nil;
    self.fixedWebbanner = nil;
        
    [self updateBanner];
}
#pragma mark- ButtonActions
- (void)loadWithURLString:(NSString*)link
{
    NSURL* url = [NSURL URLWithString:link];
    NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:url];
    
    [_wkview loadRequest:mRequest];
    
    [self clearBanner];
}

#pragma mark-
#pragma mark- other
- (void)updateLoadingState
{
    UIColor* borderClr = nil;
    if (m_nFrameLoadCount == 0)
    {
        borderClr = [UIColor clearColor];
        [self onFinishLoad];
    }
    else
    {
        borderClr = [UIColor redColor];
    }
    
    _wkview.layer.borderWidth = 2;
    _wkview.layer.borderColor = [borderClr CGColor];
    
}

- (void)onFinishLoad
{
    [self updateBanner];
}

- (void)clearBanner
{
    [_topbanner.view removeFromSuperview];
    [_bottombanner.view removeFromSuperview];
    [_fixedbanner.view removeFromSuperview];
    
    self.topbanner.delegate = nil;
    self.topbanner = nil;
    
    self.bottombanner.delegate = nil;
    self.bottombanner = nil;
    
    self.fixedbanner.delegate = nil;
    self.fixedbanner = nil;
    
    _browserview.y = 0;
    _wkview.scrollView.contentSize = CGSizeMake(_browserview.width, _browserview.height);
}


- (void)updateBanner
{
    if ( ! [self shouldDisplayBanner] )
    {
        return ;
    }
    
    _browserview.y = banner_height;
    
    if (_useWeexBanner) {
        [self updateWeexBanner];
    } else {
        [self updateWebBanner];
    }
    
    [self updateBannerPosition];
}

- (void)updateWeexBanner
{
    NSString* sourcePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"weex_bundle/app.weex.js"];
    NSString* source =  [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    
    self.topbanner = [[BannerViewController alloc] initWithName:@"TopBanner" source:source];
    self.topbanner.delegate = self;
    
    self.bottombanner = [[BannerViewController alloc] initWithName:@"BottomBanner" source:source];
    self.bottombanner.delegate = self;
    
    self.fixedbanner = [[BannerViewController alloc] initWithName:@"FixedBanner" source:source];
    self.fixedbanner.delegate = self;
    
    _topbanner.view.frame = CGRectMake(0, 0, _wkview.scrollView.width, banner_height);
    _topbanner.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    SetBorderColor(_topbanner.view, [UIColor blueColor])
    [_wkview.scrollView addSubview:_topbanner.view];
    
    
    _bottombanner.view.frame = CGRectMake(0, 0, _wkview.scrollView.width, banner_height);
    SetBorderColor(_bottombanner.view, [UIColor blueColor])
    _bottombanner.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_wkview.scrollView addSubview:_bottombanner.view];
    
    
    _fixedbanner.view.frame = CGRectMake(0, _wkview.height-banner_height*2, _wkview.width, banner_height);
    SetBorderColor(_fixedbanner.view, [UIColor blueColor])
    
    [_wkview addSubview:_fixedbanner.view];
}

- (void)updateWebBanner
{
    NSString* url = @"https://m.baidu.com";
    
    self.topWebbanner = [[BannerWebViewController alloc] initWithURL:url];
    self.topWebbanner.delegate = self;
    
    self.bottomWebbanner = [[BannerWebViewController alloc] initWithURL:url];
    self.bottomWebbanner.delegate = self;
    
    self.fixedWebbanner = [[BannerWebViewController alloc] initWithURL:url];
    self.fixedWebbanner.delegate = self;
    
    _topWebbanner.view.frame = CGRectMake(0, 0, _wkview.scrollView.width, banner_height);
    _topWebbanner.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    SetBorderColor(_topWebbanner.view, [UIColor blueColor])
    [_wkview.scrollView addSubview:_topWebbanner.view];
    
    
    _bottomWebbanner.view.frame = CGRectMake(0, 0, _wkview.scrollView.width, banner_height);
    SetBorderColor(_bottomWebbanner.view, [UIColor blueColor])
    _bottomWebbanner.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_wkview.scrollView addSubview:_bottomWebbanner.view];
    
    
    _fixedWebbanner.view.frame = CGRectMake(0, _wkview.height-banner_height*2, _wkview.width, banner_height);
    SetBorderColor(_fixedWebbanner.view, [UIColor blueColor])
    
    [_wkview addSubview:_fixedWebbanner.view];
}

- (void)updateBannerPosition
{
    if (_useWeexBanner) {
        _topbanner.view.maxY = _browserview.y;
        _bottombanner.view.y = _browserview.maxY;
    } else {
        _topWebbanner.view.maxY = _browserview.y;
        _bottomWebbanner.view.y = _browserview.maxY;
    }
}

#pragma mark- UIViewControllerPreviewingDelegate
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0)
{
    URLViewController* ctl = [[URLViewController alloc] init];
    ctl.delegate = self;
    
    return ctl;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0)
{
    [self.navigationController pushViewController:viewControllerToCommit animated:NO];
}

#pragma mark- KVO
- (void)registerAsObserver
{
    [_wkview.scrollView addObserver:self
                         forKeyPath:@"contentOffset"
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:nil];
    
    [_wkview.scrollView addObserver:self
                         forKeyPath:@"contentSize"
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:nil];
}

- (void)unregisterAsObserver
{
    [_wkview.scrollView removeObserver:self
                            forKeyPath:@"contentOffset"
                               context:nil];
    
    [_wkview.scrollView removeObserver:self
                            forKeyPath:@"contentSize"
                               context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == _wkview.scrollView)
    {
        if ([keyPath isEqualToString:@"contentSize"])
        {
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            CGFloat targetHeight = _browserview.height;
            if (_topbanner.view.superview)
            {
                targetHeight += _topbanner.view.height;
            }
            
            if (_bottombanner.view.superview)
            {
                targetHeight += _bottombanner.view.height;
            }
            
            if (fabs(newContentSize.height - targetHeight) > FLT_EPSILON)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize contentSizeWithBottomBanner = CGSizeMake(newContentSize.width, targetHeight);
                    _wkview.scrollView.contentSize = contentSizeWithBottomBanner;
                    
                    DBG_LOG(@"ContentSize: %@ -> %@", NSStringFromCGSize(newContentSize), NSStringFromCGSize(contentSizeWithBottomBanner));
                    
                    [self updateBannerPosition];
                });
            }
        }
        else if ([keyPath isEqualToString:@"contentOffset"])
        {
            [self updateBannerPosition];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark- ContentSize
- (BOOL)shouldUpdateBanner
{
    return [self isBannerDisplaying] != [self shouldDisplayBanner];
}

- (BOOL)isBannerDisplaying
{
     return _topbanner.view.superview && _bottombanner.view.superview && _fixedbanner.view.superview;
}

- (BOOL)shouldDisplayBanner
{
    return fabs(_browserview.height - _wkview.scrollView.height) > 10;

}

- (void)updateBannerOnContentSizeChange
{
    if ( [self isBannerDisplaying] && ![self shouldDisplayBanner])
    {
        [self clearBanner];
    }
    else if (![self isBannerDisplaying] && [self shouldDisplayBanner])
    {
        [self updateBanner];
    }
}

#pragma mark- BannerViewControllerDelegate
- (void)runWeexJavascript:(NSString*)js withCompleteHandler:(void(^)(id result))completeHandler
{
    NSString* result = [_wkview stringByEvaluatingJavaScriptFromString:js];
    
    completeHandler(result);
}

- (void)openURL:(NSString*)url
{
    [self loadWithURLString:url];
}

#pragma mark- BannerWebViewControllerDelegate

@end
