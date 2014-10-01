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

- (IBAction)sendIssueToServer {
	NSLog(@"send issue");
}

- (IBAction)scanQr:(UIButton *)sender {
	_scanditPicker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"mHbeTgp5EeSKsmLJfKEh7Cg56poI/nKQw2Hb8HRrI/U"];
	[_scanditPicker.overlayController setTorchEnabled:false];
	
	_pickerSubviewButton = [[UIButton alloc] init];
	[_pickerSubviewButton setTranslatesAutoresizingMaskIntoConstraints:false];
	
	_pickerSubviewButton.layer.borderColor = [UIColor redColor].CGColor;
	_pickerSubviewButton.layer.borderWidth = 2;
	
	[_pickerSubviewButton addTarget:self
								 action:@selector(closePickerSubView)
					   forControlEvents:UIControlEventTouchUpInside];
	
	
	[_qrView addSubview:_scanditPicker.view];
	[_qrView addSubview:_pickerSubviewButton];
	
	_scanditPicker.overlayController.delegate = self;
	
	[_scanditPicker startScanning];
	_mainView.alpha = 0.0;
	
	NSLayoutConstraint *closeBtnTrailingSpace = [NSLayoutConstraint constraintWithItem:_qrView
																		 attribute:NSLayoutAttributeTrailing
																		 relatedBy:NSLayoutRelationEqual
																			toItem:_pickerSubviewButton
																		 attribute:NSLayoutAttributeTrailing
																		multiplier:1.0
																		  constant:10];
	
	NSLayoutConstraint *closeBtnTopSpace = [NSLayoutConstraint constraintWithItem:_pickerSubviewButton
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
	if (textField == _issueLocation) {
		[_issueDescription becomeFirstResponder];
	} else if (textField == _issueDescription) {
		[_issueDescription resignFirstResponder];
		[self sendIssueToServer];
	}
	return YES;
}

- (void)closePickerSubView {
	[_pickerSubviewButton removeFromSuperview];
	[_scanditPicker.view removeFromSuperview];
	_scanditPicker = nil;
	
	_mainView.alpha = 1.0;
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
	NSLog(@"didCancelWithStatus");
	[self closePickerSubView];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
	NSLog(@"didManualSearch");
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
	if (_scanditPicker) {
		NSString *barcodeValue = [barcode objectForKey:@"barcode"];
		
		if (barcodeValue) {
			_issueLocation.text = barcodeValue;
		}
		
		[self closePickerSubView];
	}
}

@end
