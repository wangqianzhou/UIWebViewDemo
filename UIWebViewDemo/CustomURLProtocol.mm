//
//  CustomURLProtocol.m
//  ResponseRobot
//
//  Created by wangqianzhou on 14/11/26.
//  Copyright (c) 2014年 wangqianzhou. All rights reserved.
//

#import "CustomURLProtocol.h"
#import <CommonCrypto/CommonDigest.h>

NSString* mode2string(CustomURLProtocolMode mode)
{
    NSString* modestring = @"正常";
    switch (mode)
    {
        case CustomURLProtocolModeRecord:
            modestring = @"预读";
            break;
        case CustomURLProtocolModePlaykback:
            modestring = @"回放";
            break;
            
        default:
            break;
    }

    return modestring;
}

static CustomURLProtocolMode gs_customURLProtocolMode = CustomURLProtocolModeNormal;

@interface CustomURLProtocol ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property(nonatomic, strong)NSMutableURLRequest* mReuqest;
@property(nonatomic, strong)NSURLConnection* connection;
@end

@implementation CustomURLProtocol

+ (CustomURLProtocolMode)currentMode
{
    return gs_customURLProtocolMode;
}

+ (void)setCurrentMode:(CustomURLProtocolMode)currentMode
{
    gs_customURLProtocolMode = currentMode;
}

+ (NSString*)cacheStorePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

+ (NSString*)fileNameWithURL:(NSURL*)url
{
    const char * pointer = [url.absoluteString UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ([[self class] propertyForKey:@"CustomProtocol" inRequest:request] == nil);
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client])
    {
        self.mReuqest = [request mutableCopy];
        
        [[self class] setProperty:@"" forKey:@"CustomProtocol" inRequest:_mReuqest];
    }
    
    return self;
}

-(void)dealloc
{
    _mReuqest = nil;
    _connection = nil;
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    if (gs_customURLProtocolMode == CustomURLProtocolModePlaykback)
    {
        [self playback];
    }
    else
    {
        [self startNormalLoading];
    }
}

- (void)startNormalLoading
{
    self.connection = [[NSURLConnection alloc] initWithRequest:_mReuqest delegate:self startImmediately:NO];
    
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:[[NSRunLoop currentRunLoop] currentMode]];
    [_connection start];
}

- (void)playback
{
    NSString* fileDirectory = [[self class] cacheStorePath];
    NSString* fileName = [[self class] fileNameWithURL:_mReuqest.URL];
    NSString* fileFullPath = [fileDirectory stringByAppendingPathComponent:fileName];
    
    NSCachedURLResponse* cachedResponse = [NSKeyedUnarchiver unarchiveObjectWithFile:fileFullPath];
    
    if (cachedResponse)
    {
        [[self client] URLProtocol:self didReceiveResponse:cachedResponse.response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [[self client] URLProtocol:self didLoadData:cachedResponse.data];
        [[self client] URLProtocolDidFinishLoading:self];
    }
    else
    {
        NSLog(@"Miss : %@", _mReuqest.URL);
        
        [self startNormalLoading];
    }
}

- (void)stopLoading
{
    [_connection cancel];
    
    self.connection = nil;
}

#pragma mark- NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

#pragma mark- NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
        [connection cancel];
        
        return nil;
    }
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    if (gs_customURLProtocolMode == CustomURLProtocolModeRecord)
    {
        NSString* fileDirectory = [[self class] cacheStorePath];
        NSString* fileName = [[self class] fileNameWithURL:_mReuqest.URL];
        NSString* fileFullPath = [fileDirectory stringByAppendingPathComponent:fileName];
        [NSKeyedArchiver archiveRootObject:cachedResponse toFile:fileFullPath];
    }
    
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
