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
    @"http://sina.cn/?wm=4007",
    @"http://ata2-img.cn-hangzhou.img-pub.aliyun-inc.com/46007be997b90c9f515729d67b9c2dcf.png"
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
