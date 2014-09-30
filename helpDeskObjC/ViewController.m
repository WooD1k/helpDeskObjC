//
//  ViewController.m
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(UIButton *)sender {
}

- (IBAction)sendIssueToServer:(UIButton *)sender {
}

- (IBAction)scanQr:(UIButton *)sender {
}

- (IBAction)textFieldGotFocus:(UITextField *)sender {
	self.activeTextField = sender;
	self.activeTextField.delegate = self;
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
	if (self.activeTextField) {
		[self.activeTextField resignFirstResponder];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _issueLocation) {
		[_issueDescription becomeFirstResponder];
	} else if (textField == _issueDescription) {
		[_issueDescription resignFirstResponder];
	}
	return YES;
}

@end
