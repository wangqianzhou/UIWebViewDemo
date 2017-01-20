//
//  CustomURLProtocol.h
//  ResponseRobot
//
//  Created by wangqianzhou on 14/11/26.
//  Copyright (c) 2014年 wangqianzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CustomURLProtocolModeNormal,
    CustomURLProtocolModeRecord,
    CustomURLProtocolModePlaykback,
} CustomURLProtocolMode;

NSString* mode2string(CustomURLProtocolMode mode);

@interface CustomURLProtocol : NSURLProtocol

+ (void)setCurrentMode:(CustomURLProtocolMode)currentMode;
+ (CustomURLProtocolMode)currentMode;

@end
