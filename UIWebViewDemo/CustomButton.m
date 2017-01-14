//
//  CustomButton.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 12/01/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "CustomButton.h"

const int DefaultBtnWidth     = 40;
const int DefaultBtnHeight    = 40;

@implementation CustomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

@end
