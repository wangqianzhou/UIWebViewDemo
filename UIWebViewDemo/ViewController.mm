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
#import "WebViewJavascriptBridge.h"

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
@property(nonatomic, strong)WebViewJavascriptBridge* jsbridge;
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
    

    UIWebView* webView = [[UIWebView alloc] initWithFrame:rect];
    webView.dataDetectorTypes = UIDataDetectorTypeNone;

    
    
    webView.allowsLinkPreview = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.allowsLinkPreview = YES;
    [mainView addSubview:webView];
    self.wkview = webView;
    
    self.jsbridge = [WebViewJavascriptBridge bridge:self.wkview];
    [self.jsbridge setWebViewDelegate:self];
    
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
