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
CGRect keyboardFrame;

CGFloat defaultTopContainerTopConstraint;
CGFloat defaultBottomContainerTopConstraint;

CGFloat defaulLocationPinImageViewLeadingConstraintConstant;
CGFloat defaulLocationLblLeadingConstraintConstant;
CGFloat defaulScanQrBtnTrailingConstraintConstant;
CGFloat defaultScanQrBtnBackgroundImageViewTrailingConstraintConstant;
CGFloat defaultLocationTextFieldOverlayWidthConstraintConstant;
CGFloat defaultScanQrContainerTopConstraint;

CGFloat defaultDescMarkerImageViewLeadingConstraint;
CGFloat defaultAddDescLblLeadingConstraint;

CGFloat defaultDescContainerHeightConstraint;
CGFloat defaultSendReportBtnTopToMainViewConstraint;

CGFloat defaultPhotoImageViewHeightConstraint;
CGFloat defaultTakePhotoBtnTopConstraint;

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	UIView *paddingForTextField = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
	_locationTextField.leftView = paddingForTextField;
	_locationTextField.leftViewMode = UITextFieldViewModeAlways;
	
	defaultDescContainerHeightConstraint = _descContainerHeightConstraint.constant;
	defaultScanQrContainerTopConstraint = _scanQrContainerTopConstraint.constant;
	defaultSendReportBtnTopToMainViewConstraint = _sendReportBtnTopToMainViewConstraint.constant;
	defaultPhotoImageViewHeightConstraint = _photoImageViewHeightConstraint.constant;
	defaultTakePhotoBtnTopConstraint = _takePhotoBtnTopConstraint.constant;
	
	
	
	_addDescTextView.textContainer.maximumNumberOfLines = 3;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - show\hide keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notifiction {
	keyboardFrame = [notifiction.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	if (_activeTextField) {
		[self calculateOffsetFromTextFieldAndMove];
	} else if (_activeTextView) {
		[self calculateOffsetFromTextViewAndMove];
	}
}

- (void)keyboardWillHide:(NSNotification *)notifiction {
	CGRect initialViewRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	if (!CGRectEqualToRect(initialViewRect, self.view.frame)) {
		[UIView animateWithDuration:0.2 animations:^{
			self.view.frame = initialViewRect;
		}];
	}
}

#pragma mark - calculate offset and move view
- (void)calculateOffsetFromTextFieldAndMove {
	UIView *windowView = [[UIApplication sharedApplication] keyWindow];
	
	CGPoint activeFieldLowerPonit = CGPointMake(_activeTextView.frame.origin.x, _activeTextView.frame.origin.y + _activeTextView.frame.size.height);
	CGPoint convertedFieldLowerPoint  = [_descContainerView convertPoint:activeFieldLowerPonit toView:windowView];
	CGPoint targetLowerPoint = CGPointMake(_activeTextView.frame.origin.x, keyboardFrame.origin.y);
	
	CGFloat offset =  targetLowerPoint.y - convertedFieldLowerPoint.y;
	CGPoint viewCenterWithOffset = CGPointMake(self.view.center.x, self.view.center.y + offset);
	
	[self moveMainViewToViewWithOffset:viewCenterWithOffset];
}

- (void)calculateOffsetFromTextViewAndMove {
	UIView *windowView = [[UIApplication sharedApplication] keyWindow];
	
	CGPoint activeFieldLowerPonit = CGPointMake(_activeTextView.frame.origin.x, _activeTextView.frame.origin.y + _activeTextView.frame.size.height);
	CGPoint convertedFieldLowerPoint  = [_descContainerView convertPoint:activeFieldLowerPonit toView:windowView];
	CGPoint targetLowerPoint = CGPointMake(_activeTextView.frame.origin.x, keyboardFrame.origin.y);
	
	CGFloat offset =  targetLowerPoint.y - convertedFieldLowerPoint.y;
	CGPoint viewCenterWithOffset = CGPointMake(self.view.center.x, self.view.center.y + offset);
	
	[self moveMainViewToViewWithOffset:viewCenterWithOffset];
}

-(void)moveMainViewToViewWithOffset:(CGPoint)viewWithOffset {
	[UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.view.center = CGPointMake(viewWithOffset.x, viewWithOffset.y);
	} completion:nil];
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	_activeTextView = textView;
	
	return true;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
	_addDescTextView.alpha = 0.0;
	
	_descMarkerImageViewLeadingConstraint.constant = defaultDescMarkerImageViewLeadingConstraint;
	_addDescLblLeadingConstraint.constant = defaultAddDescLblLeadingConstraint;
	
	[UIView animateWithDuration:0.5 animations:^{
		_addDescLbl.alpha = 1.0;
		
		[_descContainerView layoutIfNeeded];
		if (_addDescTextView.hasText) {
			_addDescLbl.text = _addDescTextView.text;
			
			if (_descContainerHeightConstraint.constant > defaultDescContainerHeightConstraint) {
				_scanQrContainerTopConstraint.constant = defaultScanQrContainerTopConstraint - (_descContainerView.frame.size.height - defaultDescContainerHeightConstraint);
			} else {
				_scanQrContainerTopConstraint.constant = defaultScanQrContainerTopConstraint;
			}
			
			[_bottomContainer layoutIfNeeded];
		}
	} completion:^(BOOL finished) {
		_addDescBtn.hidden = false;
	}];
}

- (void)textViewDidChange:(UITextView *)textView {
	CGSize contentSize = [textView sizeThatFits:textView.frame.size];
	
	_descContainerHeightConstraint.constant = contentSize.height;
	[_descContainerView layoutIfNeeded];
	
	[self calculateOffsetFromTextViewAndMove];
}

#pragma mark - IBActions
- (IBAction)textFieldGotFocus:(UITextField *)sender {
	_activeTextField = sender;
	_activeTextField.delegate = self;
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
	[self hideKeyboard];
}

#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_activeTextField resignFirstResponder];
	
	return YES;
}

#pragma mark - QR scanner functionality
- (IBAction)prepareQrScanerPicker {
	if (!_scanditPicker) {
		_scanditPicker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"mHbeTgp5EeSKsmLJfKEh7Cg56poI/nKQw2Hb8HRrI/U"];
	}
	
	[_scanditPicker.overlayController setTorchEnabled:false];
	
	_closePickerButton = [[UIButton alloc] init];
	[_closePickerButton setTranslatesAutoresizingMaskIntoConstraints:false];
	
	_closePickerButton.layer.borderColor = [UIColor redColor].CGColor;
	_closePickerButton.layer.borderWidth = 2;
	
	[_closePickerButton addTarget:self
						   action:@selector(slideInAnimation)
				 forControlEvents:UIControlEventTouchUpInside];
	
	[_qrView addSubview:_scanditPicker.view];
	[_qrView addSubview:_closePickerButton];
	
	_scanditPicker.overlayController.delegate = self;
	
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

#pragma mark - ScanditSDKOverlayControllerDelegate methods
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
	[self slideInAnimation];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
	if (_scanditPicker) {
		NSString *barcodeValue = [barcode objectForKey:@"barcode"];
		
		if (barcodeValue) {
			_locationLabel.text = barcodeValue;
		}
		
		[self slideInAnimation];
	}
}

#pragma mark - takePhotoBtn animation
- (IBAction)takePhotoTouchDown {
	[self moveShadow:_takePhotoBtnShadowImageView up:YES];
	[self setMainImage:_takePhotoBtnImageView invisible:YES];
}

- (IBAction)takePhotoTouchUpInside {
	[self moveShadow:_takePhotoBtnShadowImageView up:NO];
	[self setMainImage:_takePhotoBtnImageView invisible:NO];
	
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.allowsEditing = true;
		
		[self.navigationController presentViewController:_imagePicker animated:true completion:nil];
	}
}

- (IBAction)takePhotoTouchCancel {
	[self moveShadow:_takePhotoBtnShadowImageView up:NO];
	[self setMainImage:_takePhotoBtnImageView invisible:NO];
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

-(void)slideOutAnimation {
	[self hideNavigationAndStatusBar];
	[self hideKeyboard];
	
	defaultTopContainerTopConstraint = _topContainerTopConstraint.constant;
	defaultBottomContainerTopConstraint = _bottomContainerTopConstraint.constant;
	
	_sendReportBtnTopToMainViewConstraint.constant = screenRect.size.height + _sendReportBtn.frame.size.height;
	
	_topContainerTopConstraint.constant = -_topContainer.frame.size.height - 20.0f;
	_bottomContainerTopConstraint.constant = _bottomContainerTopConstraint.constant + _bottomContainer.frame.size.height + 20.0f;
	
	[UIView animateWithDuration:1.5 animations:^{
		[_mainView layoutIfNeeded];
	} completion:^(BOOL finished) {
		_mainView.hidden = true;
		[_scanditPicker startScanning];
	}];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage *photo = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	
	_photoImageViewHeightConstraint.constant = defaultPhotoImageViewHeightConstraint * 1.5;
	_takePhotoBtnTopConstraint.constant = 30;
	
	[_topContainer layoutIfNeeded];
	
	if (photo) {
		_takePhotoLbl.alpha = 0.0;
		_retakePhotoLbl.alpha = 1.0;
		
		_photoImageView.image = photo;
		_photoImageView.alpha = 1.0;
	}
	
	[self closeImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self closeImagePicker];
}

#pragma mark - hide QR\Photo
- (void)slideInAnimation {
	_mainView.hidden = false;
	
	[self showNavigationAndStatusBar];
	
	_topContainerTopConstraint.constant = defaultTopContainerTopConstraint;
	_bottomContainerTopConstraint.constant = defaultBottomContainerTopConstraint;
	_sendReportBtnTopToMainViewConstraint.constant = defaultSendReportBtnTopToMainViewConstraint;
	
	[UIView animateWithDuration:1.0 animations:^{
		[_mainView layoutIfNeeded];
	} completion:^(BOOL finished) {
		[_scanditPicker startScanning];
		[_scanditPicker.view removeFromSuperview];
	}];
}

- (void)closeImagePicker {
	_scanditPicker = nil;
	[self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - hide system UI elements
- (void)hideKeyboard{
	if (_activeTextField) {
		[_activeTextField resignFirstResponder];
		_activeTextField = nil;
	} else if (_activeTextView) {
		[_activeTextView resignFirstResponder];
		_activeTextView = nil;
	}
}

- (void)hideNavigationAndStatusBar {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)showNavigationAndStatusBar {
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - addLocation btn events
- (IBAction)addLocationManuallyTouchDown {
	[self setMainImage:_addLocationManuallyImageView invisible:NO];
}

- (IBAction)addLocationManuallyTouchCancel {
	[self setMainImage:_addLocationManuallyImageView invisible:YES];
}

- (IBAction)addLocationManuallyTouchUpInside {
	[self setMainImage:_addLocationManuallyImageView invisible:YES];
	
	defaulLocationPinImageViewLeadingConstraintConstant = _locationPinImageViewLeadingConstraint.constant;
	defaulLocationLblLeadingConstraintConstant = _locationLblLeadingConstraint.constant;
	defaulScanQrBtnTrailingConstraintConstant = _scanQrBtnTrailingConstraint.constant;
	defaultScanQrBtnBackgroundImageViewTrailingConstraintConstant = _scanQrBtnBackgroundImageViewTrailingConstraint.constant;
	defaultLocationTextFieldOverlayWidthConstraintConstant = _locationTextFieldOverlayWidthConstraint.constant;
	
	[UIView animateKeyframesWithDuration:0.5 delay:0.4 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
		_locationTextFieldOverlayView.alpha = 1.0;
	} completion:^(BOOL finished) {
		_locationPinImageViewLeadingConstraint.constant = -_locationPinImageView.frame.size.width;
		_locationLblLeadingConstraint.constant = _locationTextField.leftView.frame.size.width;
		_scanQrBtnTrailingConstraint.constant = -_scanQrBtn.frame.size.width;
		_scanQrBtnBackgroundImageViewTrailingConstraint.constant = _scanQrBtnBackgroundImageView.frame.size.width;
		_locationTextFieldOverlayWidthConstraint.constant = screenRect.size.width;
		
		[UIView animateWithDuration:0.5 animations:^{
			[_locationContainerView layoutIfNeeded];
			
			[_locationTextField becomeFirstResponder];
		} completion:^(BOOL finished) {
			_locationTextField.text = _locationLabel.text;
			
			_locationTextFieldOverlayView.alpha = 0.0;
			_locationTextField.alpha = 1.0;
			_locationLabel.alpha = 0.0;
			
			_addLocationManuallyBtn.hidden = true;
		}];
	}];
}

- (IBAction)addLocationManuallyDidEnd {
	_locationPinImageViewLeadingConstraint.constant = defaulLocationPinImageViewLeadingConstraintConstant;
	_locationLblLeadingConstraint.constant = defaulLocationLblLeadingConstraintConstant;
	_scanQrBtnTrailingConstraint.constant = defaulScanQrBtnTrailingConstraintConstant;
	_scanQrBtnBackgroundImageViewTrailingConstraint.constant = defaultScanQrBtnBackgroundImageViewTrailingConstraintConstant;
	_locationTextFieldOverlayWidthConstraint.constant = defaultLocationTextFieldOverlayWidthConstraintConstant;
	
	if (_locationTextField.hasText) {
		_locationLabel.text = _locationTextField.text;
		_locationTextField.text = nil;
	} else {
		_locationLabel.text = @"Add place";
	}
	
	[UIView animateWithDuration:0.5 animations:^{
		[_locationContainerView layoutIfNeeded];
		
		_locationLabel.alpha = 1.0;
		_locationTextFieldOverlayView.alpha = 0.0;
		_locationTextField.alpha = 0.0;
	}];
	
	_addLocationManuallyBtn.hidden = false;
}

#pragma mark - scan QR btn events
- (IBAction)scanQrTouchDown {
	[self prepareQrScanerPicker];
	
	[self setMainImage:_scanQrBtnBackgroundImageView invisible:NO];
}

- (IBAction)scanQrTouchUpInside {
	[self setMainImage:_scanQrBtnBackgroundImageView invisible:YES];
	[self slideOutAnimation];
}

- (IBAction)scanQrTouchCancel {
	[self setMainImage:_scanQrBtnBackgroundImageView invisible:YES];
}

#pragma mark - add desc btn events
- (IBAction)addDecBtnTouchDown {
	[self setMainImage:_addDescBtnSelectedImageView invisible:NO];
	[self moveShadow:_addDescShadowImageView up:YES];
}

- (IBAction)addDescBtnTouchUpInside {
	[self setMainImage:_addDescBtnSelectedImageView invisible:YES];
	[self moveShadow:_addDescShadowImageView up:NO];
	
	defaultDescMarkerImageViewLeadingConstraint = _descMarkerImageViewLeadingConstraint.constant;
	defaultAddDescLblLeadingConstraint = _addDescLblLeadingConstraint.constant;
	
	_descMarkerImageViewLeadingConstraint.constant = -_descMarkerImageView.frame.size.width;
	_addDescLblLeadingConstraint.constant = 0/*_locationTextField.leftView.frame.size.width*/;
	
	CGSize contentSize = [_addDescTextView sizeThatFits:_addDescLbl.frame.size];
	_descContainerHeightConstraint.constant = contentSize.height;
	
	[UIView animateWithDuration:0.5 animations:^{
		_addDescLbl.alpha = 0.0;
		
		[_descContainerView layoutIfNeeded];
	} completion:^(BOOL finished) {
		_addDescTextView.alpha = 1.0;
		
		[UIView animateWithDuration:0.0 animations:^{
			
		} completion:^(BOOL finished) {
			_addDescBtn.hidden = true;
			[_addDescTextView becomeFirstResponder];
		}];
	}];
}

- (IBAction)addDescBtnTouchCancel {
	[self setMainImage:_addDescBtnSelectedImageView invisible:YES];
	[self moveShadow:_addDescShadowImageView up:NO];
}

#pragma mark - sendREport btn events
- (IBAction)sendReportTouchDown {
	[self setMainImage:_sendReportBtnSelectedImageView invisible:NO];
	[self moveShadow:_sendReportShadowImageView up:YES];
}

- (IBAction)sendReportTouchUpInside {
	[self setMainImage:_sendReportBtnSelectedImageView invisible:YES];
	[self moveShadow:_sendReportShadowImageView up:NO];
	
	UIAlertView *alertView = [[UIAlertView alloc] init];
	alertView.title = @"Oops";
	[alertView addButtonWithTitle:@"OK"];
	
	if ([_locationLabel.text  isEqual: @"Add place"] || _locationLabel.text.length == 0) {
		alertView.message = @"Please fill in location field";
		[alertView show];
	} else if ([_addDescLbl.text  isEqual: @"Add description"] || _addDescLbl.text.length == 0) {
		alertView.message = @"Please fill in description field";
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
		
		issueObject[@"location"] = _locationLabel.text;
		issueObject[@"description"] = _addDescLbl.text;
		
		if (_photoImageView.image) {
			NSData *imageData = UIImagePNGRepresentation(_photoImageView.image);
			NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
			[dateFormater setDateFormat:@"yyMMddHHmmss"];
			
			NSDate *currentDate = [[NSDate alloc] init];
			NSString *formatedDate = [dateFormater stringFromDate:currentDate];
			
			NSString *fileName = [NSString stringWithFormat:@"issue_%@.png", formatedDate];
			PFFile * imageFile = [PFFile fileWithName:fileName data:imageData];
			
			issueObject[@"image"] = imageFile;
		}
		
		[issueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded) {
				alertView.title = @"Thanks a bunch!";
				alertView.message = @"Your issue has been sent to AD";
				
				[self resetMainView];
				
				[alertView show];
			} else {
				alertView.title = @"Something went wrong";
				alertView.message = [NSString stringWithFormat:@"Please try agein later!\n%@", error];
				
				[alertView show];
			}
			
			[activityIndicatorBackground removeFromSuperview];
		}];
	}
}

-(void)resetMainView {
	_photoImageView.image = nil;
	_locationLabel.text = @"Add place";
	_addDescLbl.text = @"Add description";
	_addDescTextView.text = @"";
	
	_takePhotoLbl.alpha = 1.0;
	_retakePhotoLbl.alpha = 0.0;
	
#warning TODO: do not hardcode, use default constraint constant
	_takePhotoBtnTopConstraint.constant = 45 /*defaultTakePhotoBtnTopConstraint*/;
	_photoImageViewHeightConstraint.constant = 102/*defaultPhotoImageViewHeightConstraint*/;
	
	[UIView animateWithDuration:0.5 animations:^{
		[_topContainer layoutIfNeeded];
	}];
}

- (IBAction)sendReportTouchCancel {
	[self setMainImage:_sendReportBtnSelectedImageView invisible:YES];
	[self moveShadow:_sendReportShadowImageView up:NO];
}
@end
