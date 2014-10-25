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
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <ImageIO/ImageIO.h>

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
CGFloat defaultReportSentLblTrailingConstraint;
CGFloat defaultSendReportLblLeadingConstraint;


#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	_sidebarButton.target = self.revealViewController;
	_sidebarButton.action = @selector(revealToggle:);
	
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.takePhotoTestButton.touchBlock = ^(void){[self touchesBeganInView:self.takePhotoTestButton];};
    self.takePhotoTestButton.actionBlock = ^(void){[self touchesEndedInView:self.takePhotoTestButton];};
	
	UIImage *cameraSmallImage = [UIImage imageNamed:@"camera_small"];
	UIImageView *cameraSmallImageView = [[UIImageView alloc] initWithImage:cameraSmallImage];
	cameraSmallImageView.frame = CGRectMake(90, 12, 30, 22);
	
	[self.navigationController.navigationBar addSubview:cameraSmallImageView];
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
	
	defaultTopContainerTopConstraint = _topContainerTopConstraint.constant;
	defaultBottomContainerTopConstraint = _bottomContainerTopConstraint.constant;
	defaultReportSentLblTrailingConstraint = _reportSentLblTrailingConstraint.constant;
	defaultSendReportLblLeadingConstraint = _sendReportLblLeadingConstraint.constant;
	
	_addDescTextView.textContainer.maximumNumberOfLines = 3;
	
	[self setupCameraView];
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
				if (_takePhotoBtnTopConstraint.constant == defaultTakePhotoBtnTopConstraint) {
					_takePhotoBtnTopConstraint.constant = _takePhotoBtnTopConstraint.constant - 20;
				}
			} else {
				_scanQrContainerTopConstraint.constant = defaultScanQrContainerTopConstraint;
				_takePhotoBtnTopConstraint.constant = defaultTakePhotoBtnTopConstraint;
			}
			
			[_mainView layoutIfNeeded];
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

#pragma mark - textFieldGotFocus
- (IBAction)textFieldGotFocus:(UITextField *)sender {
	_activeTextField = sender;
	_activeTextField.delegate = self;
}

#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_activeTextField resignFirstResponder];
	
	return YES;
}

#pragma mark - QR scanner functionality
- (IBAction)prepareQrScanerPicker {
	if (_session) {
		[self resetCameraView];
	}
	
	if (!_scanditPicker) {
		_scanditPicker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"mHbeTgp5EeSKsmLJfKEh7Cg56poI/nKQw2Hb8HRrI/U"];
	}
	
	[_scanditPicker.overlayController setTorchEnabled:false];
	
	[_qrView addSubview:_scanditPicker.view];
	
	_scanditPicker.overlayController.delegate = self;
	
	[self createClosePickerBtnAndAddToQrView];
}

-(void)createClosePickerBtnAndAddToQrView {
	if (!_closePickerButton) {
		_closePickerButton = [[UIButton alloc] init];
		[_closePickerButton setTranslatesAutoresizingMaskIntoConstraints:false];
		
		_closePickerButton.layer.borderColor = [UIColor redColor].CGColor;
		_closePickerButton.layer.borderWidth = 2;
		
		[_closePickerButton addTarget:self
							   action:@selector(slideInAnimation)
					 forControlEvents:UIControlEventTouchUpInside];
	}
	
	[_qrView addSubview:_closePickerButton];
	
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

#pragma mark - animation helpers
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

#pragma mark - slideIn\slideOut\resetMainView animations
- (void)slideInAnimation {
	_mainView.hidden = false;
	
	[self showNavigationAndStatusBar];
	
	_topContainerTopConstraint.constant = defaultTopContainerTopConstraint;
	_bottomContainerTopConstraint.constant = defaultBottomContainerTopConstraint;
	_sendReportBtnTopToMainViewConstraint.constant = defaultSendReportBtnTopToMainViewConstraint;
	
	_takePhotoBtnTopConstraint.constant = defaultTakePhotoBtnTopConstraint;
	
	[UIView animateWithDuration:1.0 animations:^{
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		if (_scanditPicker) {
			[_scanditPicker stopScanning];
			
			[_closePickerButton removeFromSuperview];
			[_scanditPicker.view removeFromSuperview];
		} else if (_session) {
			[self resetCameraView];
		}
	}];
}

-(void)slideOutAnimation {
	[self hideNavigationAndStatusBar];
	[self hideKeyboard];
	
	_sendReportBtnTopToMainViewConstraint.constant = screenRect.size.height + _sendReportBtn.frame.size.height;
	
	_topContainerTopConstraint.constant = -_topContainer.frame.size.height - 20.0f;
	_bottomContainerTopConstraint.constant = _bottomContainerTopConstraint.constant + _bottomContainer.frame.size.height + 20.0f;
	
	_takePhotoBtnTopConstraint.constant = -_takePhotoTestButton.frame.size.height;
	
	[UIView animateWithDuration:1.5 animations:^{
		[_mainView layoutIfNeeded];
	} completion:^(BOOL finished) {
		_mainView.hidden = true;
		
		if (_scanditPicker) {
			[_scanditPicker startScanning];
		}
	}];
}

-(void)resetMainView {
	_locationLabel.text = @"Add place";
	_addDescLbl.text = @"Add description";
	_addDescTextView.text = @"";
	
	_takePhotoBtnTopConstraint.constant = defaultTakePhotoBtnTopConstraint;
	_scanQrContainerTopConstraint.constant = defaultScanQrContainerTopConstraint;
	_sendReportBtnTopToMainViewConstraint.constant = defaultSendReportBtnTopToMainViewConstraint;
	_reportSentLblTrailingConstraint.constant = defaultReportSentLblTrailingConstraint;
	_sendReportLblLeadingConstraint.constant = defaultSendReportLblLeadingConstraint;
	
	[_takePhotoTestButton resetConstraints];
	
	[UIView animateWithDuration:1 animations:^{
		[_mainView layoutIfNeeded];
	}];
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

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
	[self hideKeyboard];
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

#pragma mark - sendReport btn events
- (IBAction)sendReportTouchDown {
	if (!_isSendingData) {
		[self setMainImage:_sendReportBtnSelectedImageView invisible:NO];
		[self moveShadow:_sendReportShadowImageView up:YES];
	}
}

- (IBAction)sendReportTouchUpInside {
	if (!_isSendingData) {
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
			[self moveElementsOffscreen];
			
			_isSendingData = true;
			
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
			[UIView animateWithDuration:.5 delay:.2 options:UIViewAnimationOptionCurveLinear animations:^{
				_sendReportLbl.text = @"SENDING...";
			} completion:nil];
			
			[issueObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (succeeded) {
					_sendReportLblLeadingConstraint.constant = -_sendReportLbl.frame.size.width * 2;
					_reportSentLblTrailingConstraint.constant = 0;
					
					[UIView animateWithDuration:.5 animations:^{
						[_mainView layoutIfNeeded];
					} completion:^(BOOL finished) {
						_sendReportLbl.text = @"SEND REPORT";
						
						[self performSelector:@selector(resetMainView) withObject:nil afterDelay:.5];
						
						_isSendingData = false;
					}];
				} else {
					alertView.title = @"Something went wrong";
					alertView.message = [NSString stringWithFormat:@"Please try agein later!\n%@", error];
					
					[alertView show];
				}
			}];
		}
	}
}

- (IBAction)sendReportTouchCancel {
	[self setMainImage:_sendReportBtnSelectedImageView invisible:YES];
	[self moveShadow:_sendReportShadowImageView up:NO];
}

#pragma mark take photo functionality
- (void)touchesBeganInView:(HDButton *)button {
	if (!_session) {
		[self setupCameraView];
	}
	
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [button selectedState:YES];
        [self.bottomContainer layoutSubviews];
        [self.topContainer layoutSubviews];
    } completion:^(BOOL finished) {
		
    }];
}

- (void)touchesEndedInView:(HDButton *)button {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [button selectedState:NO];
        [self.bottomContainer layoutSubviews];
        [self.topContainer layoutSubviews];
    } completion:^(BOOL finished) {
		[self createClosePickerBtnAndAddToQrView];
		
		[self slideOutAnimation];
    }];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == self.takePhotoTestButton) {
        [self.takePhotoTestButton selectedState:NO];
    }
}

- (void)createTakeBtnAddToQrView {
	UIButton *savePhotoBtn = [[UIButton alloc] init];
	savePhotoBtn.translatesAutoresizingMaskIntoConstraints = false;
	
	savePhotoBtn.layer.borderColor = [UIColor greenColor].CGColor;
	savePhotoBtn.layer.borderWidth = 2;
	
	[savePhotoBtn addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
	
	[_qrView addSubview:savePhotoBtn];
	
	NSLayoutConstraint *savePhotoBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:_qrView
																					attribute:NSLayoutAttributeBottom
																					relatedBy:NSLayoutRelationEqual
																					   toItem:savePhotoBtn
																					attribute:NSLayoutAttributeBottom
																				   multiplier:1.0
																					 constant:20];
	
	NSLayoutConstraint *savePhotoBtnCenterXConstraint = [NSLayoutConstraint constraintWithItem:savePhotoBtn
																					 attribute:NSLayoutAttributeCenterX
																					 relatedBy:NSLayoutRelationEqual
																						toItem:_qrView
																					 attribute:NSLayoutAttributeCenterX
																					multiplier:1.0
																					  constant:0];
	
	[_qrView addConstraint:savePhotoBtnBottomConstraint];
	[_qrView addConstraint:savePhotoBtnCenterXConstraint];
}

- (void) savePhoto {
	AVCaptureConnection *videoConnection = nil;
	
	for (AVCaptureConnection *connection in _stillImageOutput.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}
	
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		
		NSData *photoData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
		
		UIImage *photo = [[UIImage alloc] initWithData:photoData];
		
		CGSize photoSize = photo.size;
		
		CGFloat sideToCropBy = photoSize.width;
		
		// output size has sideLength for both dimensions
		CGSize cropSize = CGSizeMake(sideToCropBy, sideToCropBy);
		
		// calculate scale so that smaller dimension fits sideLength
		CGFloat scale = MAX(sideToCropBy / photoSize.width,
							sideToCropBy / photoSize.height);
		
		// scaling the image with this scale results in this output size
		CGSize scaledPhotoSize = CGSizeMake(photoSize.width * scale,
											photoSize.height * scale);
		
		// determine point in center of "canvas"
		CGPoint center = CGPointMake(cropSize.width/2.0,
									 cropSize.height/2.0);
		
		// calculate drawing rect relative to output Size
		CGRect cropRect = CGRectMake(center.x - scaledPhotoSize.width/2.0,
									 center.y - scaledPhotoSize.height/2.0,
									 scaledPhotoSize.width,
									 scaledPhotoSize.height);
		
		// begin a new bitmap context, scale 0 takes display scale
		UIGraphicsBeginImageContextWithOptions(cropSize, YES, 0);
		
		// draw the source image into the calculated rect
		[photo drawInRect:cropRect];
		
		// create new image from bitmap context
		UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
		
		// clean up
		UIGraphicsEndImageContext();
		
		[_takePhotoTestButton setPhoto:croppedImage];
		
		[UIView animateKeyframesWithDuration:1 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
			[_mainView layoutIfNeeded];
		} completion:nil];
		
		[self slideInAnimation];
	}];
}

- (void)setupCameraView {
	if (_scanditPicker) {
		_scanditPicker = nil;
	}
	
	CALayer *viewLayer = _qrView.layer;
	
	_session = [[AVCaptureSession alloc] init];
	_session.sessionPreset = AVCaptureSessionPresetInputPriority;
	
	_captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
	_captureVideoPreviewLayer.frame = _qrView.bounds;
	
	_stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[_stillImageOutput setOutputSettings:outputSettings];
	
	_captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error = nil;
	_captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
	
	[viewLayer addSublayer:_captureVideoPreviewLayer];
	
	[_session addInput:_captureDeviceInput];
	[_session addOutput:_stillImageOutput];
	
	[_session startRunning];
	
	[self createTakeBtnAddToQrView];
}

- (void)resetCameraView {
	_session = nil;
	_captureDeviceInput = nil;
	_captureVideoPreviewLayer = nil;
	_captureDevice = nil;
}

#pragma mark - send report animation
- (void)moveElementsOffscreen {
	_takePhotoBtnTopConstraint.constant = -_takePhotoTestButton.frame.size.height;
	
	_scanQrContainerTopConstraint.constant = -_bottomContainer.frame.size.height;
	_sendReportBtnTopToMainViewConstraint.constant = defaultScanQrContainerTopConstraint * 2;
	
	[UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[_mainView layoutIfNeeded];
	} completion:nil];
}

@end
