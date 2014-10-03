//
//  LeftMenuViewController.m
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 03.10.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "MainViewController.h"
#import "IssuesListViewController.h"
#import "SWRevealViewController.h"

@interface LeftMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation LeftMenuViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_menuItems = @[@"menuCell", @"issuesCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellName = [_menuItems objectAtIndex:indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
	
	return cell;
}

@end
