//
//  ViewController.m
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import "ViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()

@end

@implementation ViewController
#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_sidebarButton.target = self.revealViewController;
	_sidebarButton.action = @selector(revealToggle:);
	
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)sendIssueToServer {
	UIAlertView *alertView = [[UIAlertView alloc] init];
	alertView.title = @"Opps";
	[alertView addButtonWithTitle:@"OK"];
	
	if (!_issueLocationTextField.hasText) {
		alertView.message = @"issue location can't be empty";
		[alertView show];
	} else if (!_issueDescriptionTextField.hasText) {
		alertView.message = @"issue description can't be empty";
		[alertView show];
	} else {
		UIView *activityIndicatorBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
		
		activityIndicatorBackground.layer.cornerRadius = 15;
		activityIndicatorBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
		activityIndicatorBackground.center = _mainView.center;
		
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.center = CGPointMake(activityIndicatorBackground.frame.size.width/2, activityIndicatorBackground.frame.size.height/2);
		
		[activityIndicatorBackground addSubview:activityIndicator];
		[_mainView addSubview:activityIndicatorBackground];
		
		[activityIndicator startAnimating];
		
		PFObject *issueObject = [PFObject objectWithClassName:@"issues"];
		
		issueObject[@"location"] = _issueLocationTextField.text;
		issueObject[@"description"] = _issueDescriptionTextField.text;
		
		if (_photoImageView.image) {
			NSData *imageData = UIImagePNGRepresentation(_photoImageView.image);
			NSNumber *randomNumber = [NSNumber numberWithInt:arc4random_uniform(1000000)];
			NSString *fileName = [NSString stringWithFormat:@"issue_%@.png", randomNumber];
			PFFile * imageFile = [PFFile fileWithName:fileName data:imageData];
			
			issueObject[@"image"] = imageFile;
		}
		
		[issueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded) {
				alertView.title = @"Thanks a bunch!";
				alertView.message = @"Your issue has been sent to AD";
				
				_photoImageView.image = nil;
				_issueLocationTextField.text = @"";
				_issueDescriptionTextField.text = @"";
				
				[alertView show];
			} else {
				alertView.title = @"Something went wrong";
				alertView.message = [NSString stringWithFormat:@"Please try agein later!\n%@", error];
				
				[alertView show];
			}
			
			[activityIndicatorBackground removeFromSuperview];
		}];
		
		[self hideKeyboard];
	}
}

- (IBAction)textFieldGotFocus:(UITextField *)sender {
	_activeTextField = sender;
	_activeTextField.delegate = self;
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
	[self hideKeyboard];
}

#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _issueLocationTextField) {
		[_issueDescriptionTextField becomeFirstResponder];
	} else if (textField == _issueDescriptionTextField) {
		[_issueDescriptionTextField resignFirstResponder];
		[self sendIssueToServer];
	}
	
	return YES;
}

#pragma mark - QR scanner functionality
- (IBAction)scanQr:(UIButton *)sender {
	_scanditPicker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"mHbeTgp5EeSKsmLJfKEh7Cg56poI/nKQw2Hb8HRrI/U"];
	[_scanditPicker.overlayController setTorchEnabled:false];
	
	_closePickerButton = [[UIButton alloc] init];
	[_closePickerButton setTranslatesAutoresizingMaskIntoConstraints:false];
	
	_closePickerButton.layer.borderColor = [UIColor redColor].CGColor;
	_closePickerButton.layer.borderWidth = 2;
	
	[_closePickerButton addTarget:self
						   action:@selector(closePickerSubView)
				 forControlEvents:UIControlEventTouchUpInside];
	
	
	[_qrView addSubview:_scanditPicker.view];
	[_qrView addSubview:_closePickerButton];
	
	_scanditPicker.overlayController.delegate = self;
	
	[_scanditPicker startScanning];
	_mainView.alpha = 0.0;
	
	NSLayoutConstraint *closeBtnTrailingSpace = [NSLayoutConstraint constraintWithItem:_qrView
																			 attribute:NSLayoutAttributeTrailing
																			 relatedBy:NSLayoutRelationEqual
																				toItem:_closePickerButton
																			 attribute:NSLayoutAttributeTrailing
																			multiplier:1.0
																			  constant:10];
	
	NSLayoutConstraint *closeBtnTopSpace = [NSLayoutConstraint constraintWithItem:_closePickerButton
																		attribute:NSLayoutAttributeTop
																		relatedBy:NSLayoutRelationEqual
																		   toItem:_qrView
																		attribute:NSLayoutAttributeTop
																	   multiplier:1.0
																		 constant:20];
	[_qrView addConstraint:closeBtnTrailingSpace];
	[_qrView addConstraint:closeBtnTopSpace];
	
	[self hideKeyboard];
}

#pragma mark - ScanditSDKOverlayControllerDelegate methods
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
	[self closePickerSubView];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
	if (_scanditPicker) {
		NSString *barcodeValue = [barcode objectForKey:@"barcode"];
		
		if (barcodeValue) {
			_issueLocationTextField.text = barcodeValue;
		}
		
		[self closePickerSubView];
	}
}

#pragma mark - takePhoto functionality
- (IBAction)takePhoto:(UIButton *)sender {
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.allowsEditing = true;
		[_qrView addSubview:_imagePicker.view];
		_mainView.alpha = 0.0;
		
		[self hideKeyboard];
	}
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage *photo = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	
	if (photo) {
		_photoImageView.image = photo;
	}
	
	[self closePickerSubView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self closePickerSubView];
}

#pragma mark - hide QR\Photo
- (void)closePickerSubView {
	if (_scanditPicker) {
		[_closePickerButton removeFromSuperview];
		[_scanditPicker.view removeFromSuperview];
		_scanditPicker = nil;
	} else if (_imagePicker) {
		[_imagePicker.view removeFromSuperview];
		_imagePicker = nil;
	}
	
	_mainView.alpha = 1.0;
}

- (void)hideKeyboard{
	if (_activeTextField) {
		[_activeTextField resignFirstResponder];
	}
}

@end
