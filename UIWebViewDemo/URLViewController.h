//
//  URLViewController.h
//  UIWebViewDemo
//
//  Created by wangqianzhou on 12/01/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol URLViewControllerDelegate

- (void)onURLSelect:(NSString*)url;

@end


@interface URLViewController : UITableViewController

@property(nonatomic, weak)id<URLViewControllerDelegate> delegate;

@end
