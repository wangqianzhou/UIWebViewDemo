//
//  ViewController.m
//  WebkitDemp
//
//  Created by wangqianzhou on 13-8-3.
//  Copyright (c) 2013年 uc. All rights reserved.
//

#import "ViewController.h"
#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>
#import "UIView+Toast.h"
#import "URLDataProvider.h"

@interface ViewController ()<UITextFieldDelegate, UIWebViewDelegate, QuadCurveMenuDelegate, UITableViewDelegate>
@property(nonatomic, retain)UIWebView* wkview;
@property(nonatomic, retain)URLDataProvider* dataProvider;
@property(nonatomic, retain)UITableView* tabView;
@end

@implementation ViewController
@synthesize wkview = _wkview;

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
    UIView* mainView = [[[UIView alloc] initWithFrame:rect] autorelease];
    mainView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view = mainView;
    
    UIWebView* webView = [[[UIWebView alloc] initWithFrame:rect] autorelease];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.allowsLinkPreview = YES;
    [mainView addSubview:webView];
    self.wkview = webView;
    
    
    [self setButtonsWithFrame:rect];
}

- (void)setButtonsWithFrame:(CGRect)rect
{
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    QuadCurveMenuItem *starMenuItem1 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem2 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem3 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem4 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem5 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem6 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem7 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *starMenuItem8 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:starImage
                                                        highlightedContentImage:nil];
    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5, starMenuItem6, starMenuItem7,starMenuItem8, nil];
    [starMenuItem1 release];
    [starMenuItem2 release];
    [starMenuItem3 release];
    [starMenuItem4 release];
    [starMenuItem5 release];
    [starMenuItem6 release];
    [starMenuItem7 release];
    [starMenuItem8 release];
    
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:rect menus:menus];
	
	// customize menu
	/*
     menu.rotateAngle = M_PI/3;
     menu.menuWholeAngle = M_PI;
     menu.timeOffset = 0.2f;
     menu.farRadius = 180.0f;
     menu.endRadius = 100.0f;
     menu.nearRadius = 50.0f;
     */
	
    menu.delegate = self;
    [self.view addSubview:menu];
    [menu release];
}

- (void)dealloc
{
    [_wkview release], _wkview = nil;
   
    [_tabView removeFromSuperview];
    _tabView.dataSource = nil;
    _tabView.delegate = nil;
    
    [_tabView release], _tabView = nil;

    [_dataProvider release], _dataProvider = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* url = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];    
    [self loadWithURLString:url];
    
    [_tabView removeFromSuperview];
    _tabView.dataSource = nil;
    _tabView.delegate = nil;
    
    self.tabView = nil;
    self.dataProvider = nil;
}

#pragma mark- QuadCurveMenuDelegate
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSString* selName = [NSString stringWithFormat:@"onBtn_%ld", (long)idx];
    SEL sel = NSSelectorFromString(selName);
    
    objc_msgSend(self, sel);
}

- (void)onBtn_0
{
    self.tabView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.dataProvider = [[[URLDataProvider alloc] init] autorelease];
    
    _tabView.dataSource = _dataProvider;
    _tabView.delegate = self;
    
    [self.view addSubview:_tabView];
}

- (void)onBtn_1
{

}

- (void)onBtn_2
{
    [_wkview goForward];
}

- (void)onBtn_3
{   

}

- (void)onBtn_4
{
    [_wkview reload];
}

- (void)onBtn_5
{

}

- (void)onBtn_6
{
    [_wkview goBack];
}

- (void)onBtn_7
{
    
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

@end
