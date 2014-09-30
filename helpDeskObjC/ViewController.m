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
	self.scanditPicker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"mHbeTgp5EeSKsmLJfKEh7Cg56poI/nKQw2Hb8HRrI/U"];
	[self.scanditPicker.overlayController setTorchEnabled:false];
	
	self.pickerSubviewButton = [[UIButton alloc] init];
	[self.pickerSubviewButton setTranslatesAutoresizingMaskIntoConstraints:false];
	
	self.pickerSubviewButton.layer.borderColor = [UIColor redColor].CGColor;
	self.pickerSubviewButton.layer.borderWidth = 2;
	
	[self.pickerSubviewButton addTarget:self
								 action:@selector(closePickerSubView)
					   forControlEvents:UIControlEventTouchUpInside];
	
	
	[self.qrView addSubview:self.scanditPicker.view];
	[self.qrView addSubview:self.pickerSubviewButton];
	
	self.scanditPicker.overlayController.delegate = self;
	
	[self.scanditPicker startScanning];
	self.mainView.alpha = 0.0;
	
	NSLayoutConstraint *closeBtnTrailingSpace = [NSLayoutConstraint constraintWithItem:self.qrView
																		 attribute:NSLayoutAttributeTrailing
																		 relatedBy:NSLayoutRelationEqual
																			toItem:_pickerSubviewButton
																		 attribute:NSLayoutAttributeTrailing
																		multiplier:1.0
																		  constant:10];
	
	NSLayoutConstraint *closeBtnTopSpace = [NSLayoutConstraint constraintWithItem:_pickerSubviewButton
																		attribute:NSLayoutAttributeTop
																		relatedBy:NSLayoutRelationEqual
																		   toItem:self.qrView
																		attribute:NSLayoutAttributeTop
																	   multiplier:1.0
																		 constant:20];
	[self.qrView addConstraint:closeBtnTrailingSpace];
	[self.qrView addConstraint:closeBtnTopSpace];
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

- (void)closePickerSubView {
	[self.pickerSubviewButton removeFromSuperview];
	[self.scanditPicker.view removeFromSuperview];
	self.scanditPicker = nil;
	
	self.mainView.alpha = 1.0;
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
	NSLog(@"didCancelWithStatus");
	[self closePickerSubView];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
	NSLog(@"didManualSearch");
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
	if (self.scanditPicker) {
		NSString *barcodeValue = [barcode objectForKey:@"barcode"];
		
		if (barcodeValue) {
			self.issueLocation.text = barcodeValue;
		}
		
		[self closePickerSubView];
	}
}

@end
