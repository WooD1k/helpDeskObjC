//
//  ViewController.m
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>

@interface MainViewController ()
@end

@implementation MainViewController
CGRect screenRect;
CGPoint initialLocationPinImageViewCenter;
CGRect initialLocationTextFieldOverlayViewFrame;
CGPoint initialScanQrBtnCenter;
CGRect initialLocationLabelFrame;

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_sidebarButton.target = self.revealViewController;
	_sidebarButton.action = @selector(revealToggle:);
	
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	screenRect = [[UIScreen mainScreen] bounds];
	
	initialLocationTextFieldOverlayViewFrame = _locationTextField.frame;
	initialLocationPinImageViewCenter = _locationPinImageView.center;
	initialScanQrBtnCenter = _scanQrBtn.center;
	initialLocationLabelFrame = _locationLabel.frame;
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
	[self hideNavigationBar];
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

#pragma mark - takePhotoBtn animation
- (IBAction)takePhotoTouchDown:(UIControl *)sender {
	[self moveShadow:_takePhotoBtnShadowImageView up:YES];
	[self setMainImage:_takePhotoBtnImageView invisible:YES];
}

- (IBAction)takePhotoTouchUpInside:(UIControl *)sender {
	[self moveShadow:_takePhotoBtnShadowImageView up:NO];
	[self setMainImage:_takePhotoBtnImageView invisible:NO];
	[self showPicker];
}

- (void)moveShadow:(UIImageView *) shadowToMove up:(BOOL)isMoveUp {
	[UIView animateWithDuration:0.3 animations:^{
		if (isMoveUp) {
			shadowToMove.center = CGPointMake(shadowToMove.center.x, shadowToMove.center.y - shadowToMove.frame.size.height);
		} else {
			shadowToMove.center = CGPointMake(shadowToMove.center.x, shadowToMove.center.y + shadowToMove.frame.size.height);
		}
	}];
}

- (void)setMainImage:(UIImageView *) imageView invisible:(BOOL) isSetInvisible {
	if (isSetInvisible) {
		[UIView animateWithDuration:0.2 animations:^{
			[imageView setAlpha:0.0];
		}];
	} else {
		[UIView animateWithDuration:0.2 animations:^{
			[imageView setAlpha:1.0];
		}];
	}
}

#pragma mark - takePhoto functionality
- (void)preparePhotoPicker {
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.allowsEditing = true;
		
		[_qrView addSubview:_imagePicker.view];
	}
}

-(void)showPicker {
	screenRect = [[UIScreen mainScreen] bounds];

	[self hideNavigationBar];
	[self hideKeyboard];
	
	[UIView animateWithDuration:1.0 animations:^{
		_topContainer.center = CGPointMake(_topContainer.center.x, 0 - (_topContainer.center.y + _takePhotoBtnShadowImageView.frame.size.height));
		_bottomContainer.center = CGPointMake(_bottomContainer.center.x, (_bottomContainer.frame.size.height + screenRect.size.height));
	}];
}

- (IBAction)takePhoto:(UIButton *)sender {
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.allowsEditing = true;
		
		[self hideNavigationBar];
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
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	
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

#pragma mark - hide system UI elements
- (void)hideKeyboard{
	if (_activeTextField) {
		[_activeTextField resignFirstResponder];
	}
}

- (void)hideNavigationBar {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (IBAction)scanQr {
}

- (IBAction)addLocationManuallyTouchDown {
	[self setMainImage:_addLocationManuallyImageView invisible:NO];
}

- (IBAction)addLocationManuallyTouchCancel {
	[self setMainImage:_addLocationManuallyImageView invisible:YES];
}

- (IBAction)addLocationManuallyTouchUpInside {
	[self setMainImage:_addLocationManuallyImageView invisible:YES];
	
	[UIView animateKeyframesWithDuration:0.5 delay:0.4 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
		_locationTextFieldOverlayView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			[_locationTextFieldOverlayView setFrame:CGRectMake(0, 0, screenRect.size.width, _locationTextFieldOverlayView.frame.size.height)];
			
			_locationPinImageView.center = CGPointMake((0 - _locationPinImageView.frame.size.width), _locationPinImageView.center.y);
			
			_scanQrBtn.center = CGPointMake(_scanQrBtn.frame.size.width + screenRect.size.width, _scanQrBtn.center.y);
			
			_locationLabel.frame = CGRectMake(0, _locationLabel.center.y/2, _locationLabel.frame.size.width, _locationLabel.frame.size.height);
			
			_activeTextField = _locationTextField;
		} completion:^(BOOL finished) {
			_locationTextField.text = _locationLabel.text;
			
			_locationTextFieldOverlayView.alpha = 0.0;
			_locationTextField.alpha = 1.0;
			_locationLabel.alpha = 0.0;
			
			_addLocationManuallyBtn.hidden = true;
			
			[_locationTextField becomeFirstResponder];
		}];
	}];
}

- (IBAction)addLocationManuallyDidEnd {
	[UIView animateWithDuration:0.5 animations:^{
		_locationLabel.alpha = 1.0;
		_locationTextFieldOverlayView.alpha = 0.0;
		_locationTextField.alpha = 0.0;
		
		_locationTextFieldOverlayView.frame = initialLocationTextFieldOverlayViewFrame;
		_locationPinImageView.center = initialLocationPinImageViewCenter;
		_scanQrBtn.center = initialScanQrBtnCenter;
		_locationLabel.frame = initialLocationLabelFrame;
		
		if (_locationTextField.hasText) {
			_locationLabel.text = _locationTextField.text;
		} else {
			_locationLabel.text = @"Add place";
		}
	}];
	
	_addLocationManuallyBtn.hidden = false;
}

@end
