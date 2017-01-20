//
//  ViewController.m
//  WebkitDemp
//
//  Created by wangqianzhou on 13-8-3.
//  Copyright (c) 2013年 uc. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import "UIView+Toast.h"
#import "CustomButton.h"
#import "UIView+Addtions.h"
#import "URLViewController.h"
#import "CustomURLProtocol.h"
#import "URLList.h"

#define ENABLE_DBG_LOG 1

#if ENABLE_DBG_LOG
#define DBG_LOG(frmt, ...) NSLog((frmt), ##__VA_ARGS__)
#else
#define DBG_LOG(frmt, ...) do{ } while(0)
#endif

@interface ViewController ()<UIWebViewDelegate, URLViewControllerDelegate, UIViewControllerPreviewingDelegate>
@property(nonatomic, strong)UIWebView* wkview;
@property(nonatomic, strong)UITableView* tabView;
@property(nonatomic, assign)NSInteger frameLoadCount;
@property(nonatomic, assign)NSInteger currentURLIndex;
@end

@implementation ViewController
@synthesize wkview = _wkview;
@synthesize frameLoadCount = m_nFrameLoadCount;

- (id)init
{
    if (self = [super init])
    {
        m_nFrameLoadCount = 0;
    }
    
    return self;
}

- (void)loadView
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    UIView* mainView = [[UIView alloc] initWithFrame:rect];
    mainView.backgroundColor = [UIColor grayColor];
    self.view = mainView;
    
    [self initWebView];
    
    
    [self initAllButtons];
}

- (void)initWebView
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.allowsLinkPreview = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.allowsLinkPreview = YES;
    [self.view addSubview:webView];
    [self.view sendSubviewToBack:webView];
    self.wkview = webView;
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
    
    btn = [self buttonWithTitle:@"L"];
    btn.tag = 4;
    btn.bottom = self.view.bottom;
    btn.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    btn = [self buttonWithTitle:@"S"];
    btn.tag = 5;
    btn.bottom = self.view.bottom;
    btn.right = self.view.right;
    btn.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    [self updateBtnTitle];
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
    
    if (m_nFrameLoadCount == 0)
    {
        [self onLoadFinish];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    m_nFrameLoadCount--;
    [self updateLoadingState];
}

#pragma mark- URLViewControllerDelegate
- (void)onURLSelect:(NSString*)url
{
    [self.wkview removeFromSuperview];
    [self initWebView];
    
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

- (void)onBtn_4
{
    if ([CustomURLProtocol currentMode] == CustomURLProtocolModeRecord)
    {
        self.currentURLIndex = 0;
        [self preloadNext];
    }
    else
    {
        [self loadNext];
    }
}

- (void)onBtn_5
{
    CustomURLProtocolMode currentMode = [CustomURLProtocol currentMode];
    currentMode = (CustomURLProtocolMode)((int)(currentMode + 1) % 3);
    [CustomURLProtocol setCurrentMode:currentMode];
    self.currentURLIndex = 0;
    
    [self updateBtnTitle];
}

- (void)updateBtnTitle
{
    NSArray<UIButton*>* subviews = [self.view subviews];
    [subviews enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 5) {
            NSString* title = mode2string([CustomURLProtocol currentMode]);
            [obj setTitle:title forState:UIControlStateNormal];
            [obj setTitle:title forState:UIControlStateHighlighted];
        }
    }];
}

- (void)loadNext
{
    NSInteger totalCount = sizeof(URLList) / sizeof(URLList[0]);
    if (self.currentURLIndex < totalCount)
    {
        NSString* msg = [NSString stringWithFormat:@"Load %zd of %zd", self.currentURLIndex+1, totalCount];
        [self.view makeToast:msg];
        
        [self loadWithURLString:URLList[self.currentURLIndex]];
        
        self.currentURLIndex += 1;
    }
    else if(self.currentURLIndex == totalCount)
    {
        [self loadWithURLString:@"about:blank"];
        [self.view makeToast:@"FinishLoad"];
        
        self.currentURLIndex = 0;
    }
}

- (void)preloadNext
{
    [CustomURLProtocol setCurrentMode:CustomURLProtocolModeRecord];
    
    NSInteger totalCount = sizeof(URLList) / sizeof(URLList[0]);
    if (self.currentURLIndex < totalCount)
    {
        NSString* msg = [NSString stringWithFormat:@"Record %zd of %zd", self.currentURLIndex+1, totalCount];
        [self.view makeToast:msg];
        
        [self loadWithURLString:URLList[self.currentURLIndex]];
        
        self.currentURLIndex += 1;
    }
    else if(self.currentURLIndex == totalCount)
    {
        [self loadWithURLString:@"about:blank"];
        
        self.currentURLIndex = 0;
        [CustomURLProtocol setCurrentMode:CustomURLProtocolModePlaykback];
        [self updateBtnTitle];
    }
}

- (void)onLoadFinish
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([CustomURLProtocol currentMode] == CustomURLProtocolModeRecord)
        {
            [self preloadNext];
        }
    });
}
#pragma mark- ButtonActions
- (void)loadWithURLString:(NSString*)link
{
    NSURL* url = [NSURL URLWithString:link];
    NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:url];

    [_wkview loadRequest:mRequest];
}

#pragma mark-
#pragma mark- other
- (void)updateLoadingState
{
    UIColor* borderClr = nil;
    if (m_nFrameLoadCount == 0)
    {
        borderClr = [UIColor clearColor];
    }
    else
    {
        borderClr = [UIColor redColor];
    }
    
    _wkview.layer.borderWidth = 2;
    _wkview.layer.borderColor = [borderClr CGColor];
    
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

@end
