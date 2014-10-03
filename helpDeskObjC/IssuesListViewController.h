//
//  issuesListViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 02.10.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssuesListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSUInteger issuesQty;
@property (nonatomic) NSArray *issuesArray;

- (IBAction)closeResentIssues:(UIButton *)sender;

@end
