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
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_init.h>
#include <mach/task.h>
#include <mach/task_info.h>
#import "NSNotificationCenter+AllObservers.h"
#include <pthread.h>
#include <mach/mach.h>

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
@property(nonatomic, strong)UILabel* infoLabel;
@property(nonatomic, strong)NSTimer* updateTimer;
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
    webView.allowsLinkPreview = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.allowsLinkPreview = YES;
    [mainView addSubview:webView];
    self.wkview = webView;
    
    
    [self initAllButtons];
}

- (void)initAllButtons
{
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.width = self.view.width;
    self.infoLabel.height = 25;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont systemFontOfSize:12];
    self.infoLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.infoLabel];
    
    //打开
    CustomButton* btn = [self buttonWithTitle:@"Open"];
    btn.top = self.infoLabel.bottom + 10;
    btn.tag = 0;
    btn.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];

    btn = [self buttonWithTitle:@"Reload"];
    btn.tag = 1;
    btn.right = self.view.right;
    btn.top = self.infoLabel.bottom + 10;    
    btn.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];

    btn = [self buttonWithTitle:@"Foreground"];
    btn.tag = 2;
    btn.width = btn.width * 1.5;
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.left = self.view.left;
    btn.bottom = self.view.bottom;
    btn.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];
    
    btn = [self buttonWithTitle:@"Background"];
    btn.tag = 3;
    btn.width = btn.width * 1.5;
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.right = self.view.right;
    btn.bottom = self.view.bottom;
    btn.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:btn];

    btn = [self buttonWithTitle:@"T"];
    btn.tag = 4;
    btn.centerX = self.view.centerX;
    btn.bottom = self.view.bottom;
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
    _wkview = nil;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProperty) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;
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
    
    UIButton* btn = (UIButton*)sender;
    btn.enabled = NO;
    ((void(*)(id,SEL))objc_msgSend)(self, sel);
    btn.enabled = YES;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)onBtn_3
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
}



- (void)onBtn_4
{
//    NSSet* observers = [[NSNotificationCenter defaultCenter] observersForNotificationName:@"UIApplicationDidEnterBackgroundNotification"];
//    NSLog(@"Before: \n%@", observers);
//
//    [observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
//        
//        if ([obj isKindOfClass:NSClassFromString(@"CASuspendNotification")])
//        {
//            [[NSNotificationCenter defaultCenter] removeObserver:obj];
//        }
//        
//    }];
    
    [self sendSuspendNotification];
}

- (void)sendSuspendNotification
{
    Class cls = NSClassFromString(@"CASuspendNotification");
    id obj = [[cls alloc] init];
    
    SEL sel = @selector(willSuspend:);
    ((void(*)(id,SEL))objc_msgSend)(obj, sel);
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

#pragma mark- memory useage
+ (double)curUsedMemoryVSize
{
    struct task_basic_info         info;
    kern_return_t           rval = 0;
    mach_port_t             task = mach_task_self();
    mach_msg_type_number_t  tcnt = TASK_BASIC_INFO_COUNT;
    task_info_t             tptr = (task_info_t) &info;
    
    memset(&info, 0, sizeof(info));
    
    rval = task_info(task, TASK_BASIC_INFO, tptr, &tcnt);
    if (!(rval == KERN_SUCCESS)) return 0;
    
    return info.virtual_size/1024.0;
}

//Kb，当前应用程序占用的内存
+ (double)curUsedMemory
{
    struct task_basic_info         info;
    kern_return_t           rval = 0;
    mach_port_t             task = mach_task_self();
    mach_msg_type_number_t  tcnt = TASK_BASIC_INFO_COUNT;
    task_info_t             tptr = (task_info_t) &info;
    
    memset(&info, 0, sizeof(info));
    
    rval = task_info(task, TASK_BASIC_INFO, tptr, &tcnt);
    if (!(rval == KERN_SUCCESS)) return 0;
    
    return info.resident_size/1024.0;
}

- (void)updateProperty
{
    self.infoLabel.text = [NSString stringWithFormat:@"virtual_size:%.2fmb   resident_size:%.2fmb", [[self class] curUsedMemoryVSize] / 1024.0, [[self class] curUsedMemory] / 1024.0];
}

@end
