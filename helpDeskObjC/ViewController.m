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
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.allowsEditing = true;
		[_qrView addSubview:_imagePicker.view];
		_mainView.alpha = 0.0;
	}
}

- (IBAction)sendIssueToServer {
	NSLog(@"send issue");
}

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
}

- (IBAction)textFieldGotFocus:(UITextField *)sender {
	_activeTextField = sender;
	_activeTextField.delegate = self;
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
	if (_activeTextField) {
		[_activeTextField resignFirstResponder];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _issueLocationTextField) {
		[_issueDescriptionTextField becomeFirstResponder];
	} else if (textField == _issueDescriptionTextField) {
		[_issueDescriptionTextField resignFirstResponder];
		[self sendIssueToServer];
	}
	return YES;
}

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

@end
