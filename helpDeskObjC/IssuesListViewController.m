//
//  issuesListViewController.m
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 02.10.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import "IssuesListViewController.h"
#import <Parse/Parse.h>
#import "SWRevealViewController.h"

@interface IssuesListViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation IssuesListViewController

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
	PFQuery* issuesQuery = [PFQuery queryWithClassName:@"issues"];
	
	[issuesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"error: %@", error);
		} else {
			_issuesQty = [objects count];
			_issuesArray = objects;
			
			[self.collectionView reloadData];
		}
	}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	SWRevealViewController *revealViewController = self.revealViewController;
	if ( revealViewController )
	{
		[self.revealButtonItem setTarget: revealViewController];
		[self.revealButtonItem setAction: @selector( revealToggle: )];
		[self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _issuesQty;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellName = @"issueCell";
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
	
	PFImageView *imageView = [[PFImageView alloc] init];
	imageView.file = [_issuesArray[indexPath.row] objectForKey:@"image"];
	[imageView loadInBackground];
	
	cell.backgroundView = imageView;
	
	return cell;
}

#pragma mark - IBAction's
- (IBAction)closeResentIssues:(UIButton *)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}
@end
