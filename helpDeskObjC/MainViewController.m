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
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()
@end

@implementation MainViewController {
    CGRect screenRect;
    CGRect keyboardFrame;
    
    CGFloat defaultTopContainerTopConstraint;
    CGFloat defaultBottomContainerTopConstraint;
    
    CGFloat defaulLocationPinImageViewLeadingConstraintConstant;
    CGFloat defaulLocationLblLeadingConstraintConstant;
    CGFloat defaulScanQrImageViewCenterXConstraintConstant;
    CGFloat defaultScanQrBtnBackgroundImageViewTrailingConstraintConstant;
    CGFloat defaultLocationTextFieldOverlayWidthConstraintConstant;
    CGFloat defaultScanQrContainerTopConstraint;
    
    CGFloat defaultDescMarkerImageViewLeadingConstraint;
    CGFloat defaultAddDescLblLeadingConstraint;
    
    CGFloat defaultDescContainerHeightConstraint;
    CGFloat defaultSendReportBtnTopToMainViewConstraint;
    
    CGFloat defaultPhotoImageViewHeightConstraint;
    CGFloat defaultReportSentLblTrailingConstraint;
    CGFloat defaultSendReportLblLeadingConstraint;
    
    UIButton *closePickerButton;
    UIButton *savePhotoButton;
    
    UIView *qrScannerAreaView;
    
    BOOL isCameraAvailable;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // setup reveal controller and add action to menu btn
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [_scrollView setScrollEnabled:YES];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    __weak typeof(self) weakSelf = self;
    
    [self checkCameraAuthorization];
    
    _takePhotoButton.touchDownBlock = ^(void){[weakSelf compressConstraints];};
    _takePhotoButton.touchUpBlock = ^(void){[weakSelf updateConstraints];};
    _takePhotoButton.touchCanceledBlock = ^(void){[weakSelf updateConstraints];};
    _takePhotoButton.actionBlock = ^(void){
        if (isCameraAvailable) {
            [_session removeOutput:_metadataOutput];
            
            [weakSelf performSelector:@selector(slideOutAnimation) withObject:nil afterDelay:0.2];
        } else {
            [self showAlertWithTitle:@"Oops!" text:@"Reporter doesn't have permission to use Camera, please change privacy settings!"];
        }
        
        if (savePhotoButton) {
            savePhotoButton.hidden = false;
        }
    };
    
    _locationButton.actionBlock = ^(void){[weakSelf animateLocationOnDown];};
    
    _qrCodeButton.actionBlock = ^(void){
        [weakSelf setupQrScanner];
        
        [weakSelf slideOutAnimation];
    };
    
    _descriptionButton.actionBlock = ^(void){[weakSelf animateDescriptionOnDown];};
    
    _sendButton.actionBlock = ^(void){[weakSelf sendReportTouchUpInside];};
    
    _takePhotoButton.shadowImage = [UIImage imageNamed:@"button_yellow_shadow"];
    _takePhotoButton.normalImage = [UIImage imageNamed:@"button_yellow"];
    _takePhotoButton.selectedImage = [UIImage imageNamed:@"button_yellow_selected"];
    
    _locationButton.selectedImage = [UIImage imageNamed:@"button_orange_selected_field"];
    _locationButton.scalableBackground = NO;
    
    _qrCodeButton.selectedImage = [UIImage imageNamed:@"button_orange_selected_qr"];
    _qrCodeButton.scalableBackground = NO;
    
    _descriptionButton.shadowImage = [UIImage imageNamed:@"button_red_shadow"];
    _descriptionButton.normalImage = [UIImage imageNamed:@"button_red"];
    _descriptionButton.selectedImage = [UIImage imageNamed:@"button_red_selected"];
    _descriptionButton.scalableBackground = NO;
    
    _sendButton.shadowImage = [UIImage imageNamed:@"button_green_shadow"];
    _sendButton.normalImage = [UIImage imageNamed:@"button_green"];
    _sendButton.selectedImage = [UIImage imageNamed:@"button_green_selected"];
    
    UIImage *cameraSmallImage = [UIImage imageNamed:@"camera_small"];
    UIImageView *cameraSmallImageView = [[UIImageView alloc] initWithImage:cameraSmallImage];
    cameraSmallImageView.frame = CGRectMake(90, 12, 30, 22);
    
    [self.navigationController.navigationBar addSubview:cameraSmallImageView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    _addDescTextView.contentInset = UIEdgeInsetsMake(4,0,0,0);
    
    _scrollView.contentInset = UIEdgeInsetsMake(64,0,0,0);
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    [_scrollView setCanCancelContentTouches:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    screenRect = [[UIScreen mainScreen] bounds];
    
    [self registerForKeyboardNotifications];
    
    UIView *paddingForTextField = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
    _locationTextField.leftView = paddingForTextField;
    _locationTextField.leftViewMode = UITextFieldViewModeAlways;
    
    defaultDescContainerHeightConstraint = 100;
    defaultScanQrContainerTopConstraint = _locationTopConstraint.constant;
    
    _addDescTextView.textContainer.maximumNumberOfLines = 5;
    
    [self updateConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isCameraAvailable) {
        [self setupCameraView];
    }
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _activeTextField = textView;
    
    return true;
}

// on down animation for location element
- (IBAction)animateLocationOnDown {
    defaulLocationPinImageViewLeadingConstraintConstant = _locationPinImageViewLeadingConstraint.constant;
    defaulLocationLblLeadingConstraintConstant = _locationLblLeadingConstraint.constant;
    defaulScanQrImageViewCenterXConstraintConstant = _scanQrImageViewCenterXConstraint.constant;
    
    _locationPinImageViewLeadingConstraint.constant = -75;
    _locationLblLeadingConstraint.constant = _locationTextField.leftView.frame.size.width;
    _scanQrImageViewCenterXConstraint.constant = -75;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_locationContainerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        _locationTextField.text = _locationLabel.text;
        _locationTextField.backgroundColor = [UIColor clearColor];
        _locationTextField.hidden = NO;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _locationTextField.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            _locationLabel.alpha = 0.0;
            if ([_locationTextField.text isEqualToString:@"Add place"]) {
                _locationTextField.text = nil;
            }
            [_locationTextField becomeFirstResponder];
        }];
    }];
}

// on down animation for description  element
- (IBAction)animateDescriptionOnDown {
    defaultDescMarkerImageViewLeadingConstraint = _descMarkerImageViewLeadingConstraint.constant;
    defaultAddDescLblLeadingConstraint = _addDescLblLeadingConstraint.constant;
    
    _descMarkerImageViewLeadingConstraint.constant = -_descMarkerImageView.frame.size.width;
    _addDescLblLeadingConstraint.constant = _locationTextField.leftView.frame.size.width;
    
    [UIView animateWithDuration:0.2 animations:^{
        [_descContainerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        _addDescTextView.alpha = 1.0;
        _addDescLbl.alpha = 0.0;
        _addDescTextView.text = _addDescLbl.text;
        _addDescTextView.hidden = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            _addDescTextView.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            if ([_addDescTextView.text isEqualToString:@"Add description"]) {
                _addDescTextView.text = nil;
            }
            [_addDescTextView becomeFirstResponder];
        }];
    }];
}

// animation for location  element for did end event
- (IBAction)addLocationManuallyDidEnd {
    _locationPinImageViewLeadingConstraint.constant = defaulLocationPinImageViewLeadingConstraintConstant;
    _locationLblLeadingConstraint.constant = defaulLocationLblLeadingConstraintConstant;
    _scanQrImageViewCenterXConstraint.constant = defaulScanQrImageViewCenterXConstraintConstant;
    
    [_locationTextField resignFirstResponder];
    
    if (_locationTextField.hasText) {
        _locationLabel.text = _locationTextField.text;
    } else {
        _locationLabel.text = @"Add place";
    }
    _locationTextField.text = nil;
    _locationLabel.alpha = 1.0;
    
    [UIView animateWithDuration:0.2 animations:^{
        _locationTextField.backgroundColor = [UIColor clearColor];
        [_locationContainerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        _locationTextField.hidden = YES;
    }];
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    _addDescLbl.alpha = 1.0;
    _addDescTextView.alpha = 0.0;
    
#warning remove spaces!!
    if (_addDescTextView.hasText) {
        _addDescLbl.text = _addDescTextView.text;
    } else {
        _addDescLbl.text = @"Add description";
    }
    
#warning fix label animation!!!
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        _descMarkerImageViewLeadingConstraint.constant = defaultDescMarkerImageViewLeadingConstraint;
        _addDescLblLeadingConstraint.constant = defaultAddDescLblLeadingConstraint;
        
        CGSize constrainedSize = CGSizeMake(320-96-5, CGFLOAT_MAX);
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              _addDescLbl.font, NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_addDescLbl.text attributes:attributesDictionary];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        _descContainerHeightConstraint.constant = (int)MAX(45, MIN(requiredHeight.size.height+7+7, 100));
        _descriptionButton.heightConstraint.constant = _descContainerHeightConstraint.constant;
        
        [_descriptionButton setNeedsUpdateConstraints];
        [_descriptionButton updateConstraintsIfNeeded];
        
        [_descriptionButton layoutIfNeeded];
        [_descContainerView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self updateConstraints];
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize contentSize = [textView sizeThatFits:textView.frame.size];
    
    _descContainerHeightConstraint.constant = MAX(45, MIN(contentSize.height, 100));
    _descriptionButton.heightConstraint.constant = _descContainerHeightConstraint.constant;
    [_descriptionButton setNeedsUpdateConstraints];
    [_descriptionButton updateConstraintsIfNeeded];
    [_descriptionButton layoutIfNeeded];
    [_descContainerView layoutIfNeeded];
    
    [self updateConstraints];
    [self updateScroll];
}

#pragma mark - textFieldGotFocus
- (IBAction)textFieldGotFocus:(UITextField *)sender {
    _activeTextField = sender;
    sender.delegate = self;
}

#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_activeTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - QR scanner functionality
// add QR _metadataOutput to camera view
- (void)setupQrScanner {
    if ([_session canAddOutput:_metadataOutput]) {
        [self createScannerAreaView];
        
        [_session addOutput:_metadataOutput];
        
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        
        _metadataOutput.rectOfInterest = [_captureVideoPreviewLayer metadataOutputRectOfInterestForRect:qrScannerAreaView.frame];
    }
    
    savePhotoButton.hidden = true;
}

- (void)createScannerAreaView {
    if (!qrScannerAreaView) {
        qrScannerAreaView = [[UIView alloc] init];
        
        qrScannerAreaView.layer.borderColor = [UIColor whiteColor].CGColor;
        qrScannerAreaView.layer.cornerRadius = 20.0f;
        qrScannerAreaView.layer.borderWidth = 2;
        
        [qrScannerAreaView setTranslatesAutoresizingMaskIntoConstraints:false];
        
        [qrScannerAreaView addConstraint:[NSLayoutConstraint constraintWithItem:qrScannerAreaView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:150]];
        
        [qrScannerAreaView addConstraint:[NSLayoutConstraint constraintWithItem:qrScannerAreaView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:150]];
        
        [_qrView addSubview:qrScannerAreaView];
        
        NSLayoutConstraint *qrScannerAreaViewCenterX = [NSLayoutConstraint constraintWithItem:qrScannerAreaView
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:_qrView
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                multiplier:1.0
                                                                                  constant:0];
        
        NSLayoutConstraint *qrScannerAreaViewCenterY = [NSLayoutConstraint constraintWithItem:qrScannerAreaView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_qrView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.0
                                                                             constant:0];
        [_qrView addConstraint:qrScannerAreaViewCenterX];
        [_qrView addConstraint:qrScannerAreaViewCenterY];
        
        [_qrView layoutIfNeeded];
    }
}

// create and add close button to camera view
-(void)createclosePickerButtonAndAddToQrView {
    if (!closePickerButton) {
        closePickerButton = [[UIButton alloc] init];
        [closePickerButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [closePickerButton setTranslatesAutoresizingMaskIntoConstraints:false];
        
        [closePickerButton addTarget:self
                               action:@selector(slideInAnimation)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [closePickerButton addConstraint:[NSLayoutConstraint constraintWithItem:closePickerButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:100]];
        [closePickerButton addConstraint:[NSLayoutConstraint constraintWithItem:closePickerButton
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:50]];
    }
    
    [_qrView addSubview:closePickerButton];
    
    NSLayoutConstraint *closeBtnTrailingSpace = [NSLayoutConstraint constraintWithItem:_qrView
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:closePickerButton
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.0
                                                                              constant:-20];
    
    NSLayoutConstraint *closeBtnTopSpace = [NSLayoutConstraint constraintWithItem:closePickerButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_qrView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-10];
    [_qrView addConstraint:closeBtnTrailingSpace];
    [_qrView addConstraint:closeBtnTopSpace];
}

#pragma mark - slideIn\slideOut\resetMainView animations
// slide in animation for camera and QR actions
- (void)slideInAnimation {
    [self slideInAnimationWithComplitionBlock:^{}];
}

- (void)slideInAnimationWithComplitionBlock:(void (^)(void))complitionBlock {
    [_scrollView setHidden:NO];
    
    [self showNavigationAndStatusBar];
    
    _topBackgroundTopConstraint.constant = 0;
    _bottomBackgroundBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self updateConstraints];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            complitionBlock();
        }
    }];
}

// slide out animation for camera and QR actions
-(void)slideOutAnimation {
    [self hideNavigationAndStatusBar];
    [self hideKeyboard];
    
    _topBackgroundTopConstraint.constant = -(_topBackgroundHeightConstraint.constant + 64);
    _takePhotoTopConstraint.constant = _topBackgroundTopConstraint.constant +_takePhotoTopConstraint.constant;
    
    _bottomBackgroundBottomConstraint.constant = -_bottomBackgroundHeightConstraint.constant;
    _locationTopConstraint.constant = _locationTopConstraint.constant - _bottomBackgroundBottomConstraint.constant;
    _descriptionTopConstraint.constant = _descriptionTopConstraint.constant - _bottomBackgroundBottomConstraint.constant;
    _sendTopConstraint.constant = _sendTopConstraint.constant - _bottomBackgroundBottomConstraint.constant;
    
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_mainView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_scrollView setHidden:YES];
    }];
}

// reset view to default state
-(void)resetMainView {
    _locationLabel.text = @"Add place";
    _addDescLbl.text = @"Add description";
    _addDescTextView.text = @"";
    
    [_takePhotoButton resetConstraints];
    _takePhotoHeightConstraint.constant = _takePhotoButton.heightConstraint.constant;
    
    _descContainerHeightConstraint.constant = 45;
    _descriptionButton.heightConstraint.constant = _descContainerHeightConstraint.constant;
    [_descriptionButton setNeedsUpdateConstraints];
    [_descriptionButton updateConstraintsIfNeeded];
    [_descriptionButton layoutIfNeeded];
    [_descContainerView layoutIfNeeded];
    
    [self updateConstraints];
}

#pragma mark - hide\show system UI elements
- (void)hideKeyboard {
    if (_activeTextField) {
        [_activeTextField resignFirstResponder];
        _activeTextField = nil;
    }
}

- (IBAction)hideKeyboard:(id)sender {
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

#pragma mark - show alert methods
// show alert with custom title and text
- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.title = title;
    [alertView addButtonWithTitle:@"OK"];
    
    alertView.message = text;
    [alertView show];
}

// show alert with default title
- (void)showAlertWithText:(NSString *)text {
    [self showAlertWithTitle:@"Oops" text:text];
}

#pragma mark - sendReport btn events
- (IBAction)sendReportTouchUpInside {
    if (!_isSendingData) {
        if ([_locationLabel.text  isEqual: @"Add place"] || _locationLabel.text.length == 0) {
            [self showAlertWithText:@"Please fill in location field"];
        } else if ([_addDescLbl.text  isEqual: @"Add description"] || _addDescLbl.text.length == 0) {
            [self showAlertWithText:@"Please fill in description field"];
        } else {
            [self slideOutSendAnimation];
            
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
                    [UIView animateWithDuration:.5 animations:^{
                        [_mainView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        _sendReportLbl.text = @"SEND REPORT";
                        
                        [self performSelector:@selector(resetMainView) withObject:nil afterDelay:.5];
                        
                        _isSendingData = false;
                    }];
                } else {
                    [self showAlertWithTitle:@"Something went wrong" text:[NSString stringWithFormat:@"Please try agein later!\n%@", error]];
                }
            }];
        }
    }
}

// slide out animation during sending info to parse
-(void)slideOutSendAnimation {
    [self hideKeyboard];
    
    CGFloat topBackgroundTopConstraintConstant = -(_topBackgroundHeightConstraint.constant + 64);
    _takePhotoTopConstraint.constant = topBackgroundTopConstraintConstant;
    
    _locationTopConstraint.constant = -_locationTopConstraint.constant;
    _descriptionTopConstraint.constant = -_descriptionTopConstraint.constant;
    _sendTopConstraint.constant = _mainView.bounds.size.height/2 - 22;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_mainView layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark take photo functionality
- (void)createTakeBtnAddToQrView {
    savePhotoButton = [[UIButton alloc] init];
    [savePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    savePhotoButton.translatesAutoresizingMaskIntoConstraints = false;
    
    [savePhotoButton addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [_qrView addSubview:savePhotoButton];
    
    [savePhotoButton addConstraint:[NSLayoutConstraint constraintWithItem:savePhotoButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:100]];
    [savePhotoButton addConstraint:[NSLayoutConstraint constraintWithItem:savePhotoButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:50]];
    
    
    NSLayoutConstraint *savePhotoButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:_qrView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:savePhotoButton
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0
                                                                                     constant:10];
    
    NSLayoutConstraint *savePhotoButtonTrailingConstraint = [NSLayoutConstraint constraintWithItem:_qrView
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:savePhotoButton
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                     multiplier:1.0
                                                                                       constant:20];
    
    [_qrView addConstraint:savePhotoButtonBottomConstraint];
    [_qrView addConstraint:savePhotoButtonTrailingConstraint];
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
        
        [_takePhotoButton setPhoto:croppedImage];
        _takePhotoHeightConstraint.constant = _takePhotoButton.heightConstraint.constant;
        [_mainView layoutIfNeeded];
        
        [self slideInAnimation];
    }];
}

- (void)setupCameraView {
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
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
    
    [self startRunning];
    
    [self createTakeBtnAddToQrView];
    [self createclosePickerButtonAndAddToQrView];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            _locationLabel.text = readableObject.stringValue;
            _locationTextField.text = _locationLabel.text;
            
            [self slideInAnimationWithComplitionBlock:^{
                [_metadataOutput setMetadataObjectsDelegate:nil queue:dispatch_get_main_queue()];
                [_session removeOutput:_metadataOutput];
            }];
        }
    }
}

#pragma mark - show\hide keyboard notifications
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsetsNormal = UIEdgeInsetsMake(64.0, 0.0, kbSize.height, 0.0);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, kbSize.height + 10, 0.0);
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGFloat delta = _mainView.frame.size.height - kbSize.height;
    if (_activeTextField == _locationTextField) {
        delta = (_locationTopConstraint.constant + _locationHeightConstraint.constant) - delta;
    } else {
        delta = (_descriptionTopConstraint.constant + _descContainerHeightConstraint.constant) - delta;
    }
    
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
        
        CGPoint scrollPoint;
        if (delta > 0) {
            scrollPoint = CGPointMake(0.0, -64 + delta+10);
        } else {
            scrollPoint = CGPointMake(0.0, -64+10);
        }
        [_scrollView setContentOffset:scrollPoint animated:NO];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _scrollView.contentInset = contentInsetsNormal;
            _scrollView.scrollIndicatorInsets = contentInsetsNormal;
            
            CGPoint scrollPoint;
            if (delta > 0) {
                scrollPoint = CGPointMake(0.0, -64 + delta);
            } else {
                scrollPoint = CGPointMake(0.0, -64);
            }
            [_scrollView setContentOffset:scrollPoint animated:NO];
        } completion:nil];
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(64,0,0,0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
        [_scrollView setContentOffset:CGPointMake(0.0, -64) animated:NO];
    } completion:nil];
}

// Calculate distance between elements
- (void)updateScroll {
    CGFloat kbHeight = _scrollView.contentInset.bottom;
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbHeight;
    
    CGFloat delta = _mainView.frame.size.height - kbHeight;
    if (_activeTextField == _locationTextField) {
        delta = (_locationTopConstraint.constant + _locationHeightConstraint.constant) - delta;
    } else {
        delta = (_descriptionTopConstraint.constant + _descContainerHeightConstraint.constant) - delta;
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGPoint scrollPoint;
        if (delta > 0) {
            scrollPoint = CGPointMake(0.0, -64 + delta);
        } else {
            scrollPoint = CGPointMake(0.0, -64);
        }
        [_scrollView setContentOffset:scrollPoint animated:NO];
    } completion:nil];
}

// update constraints after compressConstraints
- (void)updateConstraints {
    CGFloat totalSubviewsHeight = _takePhotoHeightConstraint.constant + _locationHeightConstraint.constant + _descContainerHeightConstraint.constant + _sendHeightConstraint.constant;
    CGFloat height = self.view.bounds.size.height - 64;
    CGFloat delta = height - totalSubviewsHeight;
    
    CGFloat photoSpaceHeight = delta *0.6;
    CGFloat sendSpaceHeight = delta - photoSpaceHeight;
    
    _takePhotoTopConstraint.constant = photoSpaceHeight/2;
    _locationTopConstraint.constant = photoSpaceHeight + _takePhotoHeightConstraint.constant;
    _descriptionTopConstraint.constant = _locationTopConstraint.constant + _locationHeightConstraint.constant;
    _sendTopConstraint.constant = _descriptionTopConstraint.constant + _descContainerHeightConstraint.constant + sendSpaceHeight/2;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

// compress constrains animation when takePhoto btn pressed
- (void)compressConstraints {
    CGFloat totalSubviewsHeight = _takePhotoHeightConstraint.constant + _locationHeightConstraint.constant + _descContainerHeightConstraint.constant + _sendHeightConstraint.constant;
    CGFloat height = self.view.bounds.size.height - 64;
    CGFloat delta = height - totalSubviewsHeight;
    
    CGFloat photoSpaceHeight = delta *0.6;
    CGFloat sendSpaceHeight = delta - photoSpaceHeight;
    
    _locationTopConstraint.constant = photoSpaceHeight + _takePhotoHeightConstraint.constant - 7;
    _descriptionTopConstraint.constant = _locationTopConstraint.constant + _locationHeightConstraint.constant - 5;
    _sendTopConstraint.constant = _descriptionTopConstraint.constant + _descContainerHeightConstraint.constant + sendSpaceHeight/2 - 3;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark camera helpers
- (void)checkCameraAuthorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        isCameraAvailable = NO;
    } else {
        isCameraAvailable = YES;
    }
}

// start running camera session
- (void)startRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_session startRunning];
    });
}

// stop running camera session
- (void)stopRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_session stopRunning];
    });
}

@end
