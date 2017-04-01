//
//  URLModel.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 14/01/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "URLModel.h"

static NSString* URLList[] =
{
    @"http://hao123.com",
    @"https://m.baidu.com",
    @"http://sina.cn/?wm=4007",
    @"https://m.taobao.com",
    @"http://www.qstheory.cn/yaowen/2016-12/31/c_1120225207.htm",
    @"https://info.3g.qq.com/g/channel_home.htm?i_f=766&f_aid_ext=nav&chId=sports_nch&sid=&&icfa=home_touch&f_pid=135&iarea=239#/tab/105000000_tpc_tab?_k=13e6z9"
};

@interface URLModel ( )
@property(nonatomic, strong)NSMutableArray<NSString*>* urlArray;
@property(nonatomic, strong)NSHashTable<id<URLModelDelegate>>* observers;
@end

@implementation URLModel

+ (instancetype)model
{
    static URLModel* _inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[[self class] alloc] init];
    });
    
    return _inst;
}

- (NSString*)savePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return  [documentsDirectory stringByAppendingPathComponent:@"url_list.data"];
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.observers = [NSHashTable weakObjectsHashTable];
        
        self.urlArray = [[NSMutableArray alloc] init];
        
        NSInteger hardCodeItemCount = sizeof(URLList)/ sizeof(URLList[0]);
        for (int i=0; i<hardCodeItemCount; i++)
        {
            [self.urlArray addObject:URLList[i]];
        }
        
        NSArray<NSString*>* savedItems = [NSArray arrayWithContentsOfFile:[self savePath]];
        [savedItems enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( ![self.urlArray containsObject:obj] )
            {
                [self.urlArray addObject:obj];
            }
        }];
    }
    
    return self;
}

- (NSInteger)itemCount
{
    return [self.urlArray count];
}

- (NSString*)itemAtIndex:(NSInteger)index
{
    return [self.urlArray objectAtIndex:index];
}

- (void)addItem:(NSString*)url
{
    if ([url length] != 0 && ![self.urlArray containsObject:url])
    {
        [self.urlArray addObject:url];        
        [self.urlArray writeToFile:[self savePath] atomically:YES];
        
        NSEnumerator* enumerator = [self.observers objectEnumerator];
        id<URLModelDelegate> observer = [enumerator nextObject];
        while (observer)
        {
            [observer onModelChanged];
            
            observer = [enumerator nextObject];
        }
    }
}

- (void)addObserver:(id<URLModelDelegate>)observer
{
    if (observer)
    {
        [self.observers addObject:observer];
    }
}

- (void)removeObserver:(id<URLModelDelegate>)observer
{
    if (observer)
    {
        [self.observers removeObject:observer];
    }
}
@end
