//
//  URLViewController.m
//  UIWebViewDemo
//
//  Created by wangqianzhou on 12/01/2017.
//  Copyright © 2017 uc. All rights reserved.
//

#import "URLViewController.h"
#import "URLModel.h"

@interface URLViewController ()<URLModelDelegate>
@property(nonatomic, retain)NSArray<NSString*>* urlListArray;
@end

@implementation URLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[URLModel model] addObserver:self];
}

- (void)dealloc
{
    [[URLModel model] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

#pragma mark- required methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[URLModel model] itemCount];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"URLCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    cell.textLabel.text = [[URLModel model] itemAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* url = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    [self.delegate onURLSelect:url];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- URLModelDelegate
- (void)onModelChanged
{
    [self.tableView reloadData];
}
@end
