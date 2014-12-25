//
//  CustomURLProtocol.m
//  ResponseRobot
//
//  Created by wangqianzhou on 14/11/26.
//  Copyright (c) 2014年 wangqianzhou. All rights reserved.
//

#import "CustomURLProtocol.h"

@interface CustomURLProtocol ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property(nonatomic, retain)NSMutableURLRequest* mReuqest;
@property(nonatomic, retain)NSURLConnection* connection;
@end

@implementation CustomURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
//    if ( ![[[request URL] scheme] isEqualToString:@"http"] )
//    {
//        return NO;
//    }
//    
    return ([[self class] propertyForKey:@"CustomProtocol" inRequest:request] == nil);
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client])
    {
        self.mReuqest = [request mutableCopy];
        
        NSLog(@"\n==ProtocolInitRequest:%@policy:%lu\n\n==================\n\n", _mReuqest, _mReuqest.cachePolicy);
        [[self class] setProperty:@"" forKey:@"CustomProtocol" inRequest:_mReuqest];
    }
    
    return self;
}

-(void)dealloc
{
    [_mReuqest release], _mReuqest = nil;
    [_connection release], _connection = nil;
    
    [super dealloc];
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
//    NSLog(@"\n==ProtocolRequest:%@policy:%lu\n\n==================\n\n", _mReuqest, _mReuqest.cachePolicy);
    self.connection = [[[NSURLConnection alloc] initWithRequest:_mReuqest delegate:self startImmediately:NO] autorelease];
    
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:[[NSRunLoop currentRunLoop] currentMode]];
    [_connection start];
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

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
//    NSURLCredential* credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
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

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
