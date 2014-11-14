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
    
    UIButton *closePickerBtn;
    UIButton *savePhotoBtn;
    
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
    
    self.takePhotoTestButton.touchDownBlock = ^(void){[weakSelf compressConstraints];};
    self.takePhotoTestButton.touchUpBlock = ^(void){[weakSelf updateConstraints];};
    self.takePhotoTestButton.touchCanceledBlock = ^(void){[weakSelf updateConstraints];};
    self.takePhotoTestButton.actionBlock = ^(void){
        if (isCameraAvailable) {
            [_session removeOutput:_metadataOutput];
            
            [weakSelf performSelector:@selector(slideOutAnimation) withObject:nil afterDelay:0.2];
        } else {
            [self showAlertWithTitle:@"Oops!" text:@"Reporter doesn't have permission to use Camera, please change privacy settings!"];
        }
        
        if (savePhotoBtn) {
            savePhotoBtn.hidden = false;
        }
    };
    
    self.locationTestButton.actionBlock = ^(void){[weakSelf animateLocationOnDown];};
    
    self.qrCodeTestButton.actionBlock = ^(void){
        [weakSelf setupQrScanner];
        
        [weakSelf slideOutAnimation];
    };
    
    self.descriptionTestButton.actionBlock = ^(void){[weakSelf animateDescriptionOnDown];};
    
    _sendTestButton.actionBlock = ^(void){[weakSelf sendReportTouchUpInside];};
    
    _takePhotoTestButton.shadowImage = [UIImage imageNamed:@"button_yellow_shadow"];
    _takePhotoTestButton.normalImage = [UIImage imageNamed:@"button_yellow"];
    _takePhotoTestButton.selectedImage = [UIImage imageNamed:@"button_yellow_selected"];
    
    _locationTestButton.selectedImage = [UIImage imageNamed:@"button_orange_selected_field"];
    _locationTestButton.scalableBackground = NO;
    
    _qrCodeTestButton.selectedImage = [UIImage imageNamed:@"button_orange_selected_qr"];
    _qrCodeTestButton.scalableBackground = NO;
    
    _descriptionTestButton.shadowImage = [UIImage imageNamed:@"button_red_shadow"];
    _descriptionTestButton.normalImage = [UIImage imageNamed:@"button_red"];
    _descriptionTestButton.selectedImage = [UIImage imageNamed:@"button_red_selected"];
    _descriptionTestButton.scalableBackground = NO;
    
    _sendTestButton.shadowImage = [UIImage imageNamed:@"button_green_shadow"];
    _sendTestButton.normalImage = [UIImage imageNamed:@"button_green"];
    _sendTestButton.selectedImage = [UIImage imageNamed:@"button_green_selected"];
    
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
        _descriptionTestButton.heightConstraint.constant = _descContainerHeightConstraint.constant;
        
        [_descriptionTestButton setNeedsUpdateConstraints];
        [_descriptionTestButton updateConstraintsIfNeeded];
        
        [_descriptionTestButton layoutIfNeeded];
        [_descContainerView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self updateConstraints];
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize contentSize = [textView sizeThatFits:textView.frame.size];
    
    _descContainerHeightConstraint.constant = MAX(45, MIN(contentSize.height, 100));
    _descriptionTestButton.heightConstraint.constant = _descContainerHeightConstraint.constant;
    [_descriptionTestButton setNeedsUpdateConstraints];
    [_descriptionTestButton updateConstraintsIfNeeded];
    [_descriptionTestButton layoutIfNeeded];
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
- (void)setupQrScanner {
    if ([_session canAddOutput:_metadataOutput]) {
        [_session addOutput:_metadataOutput];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    }
    
    savePhotoBtn.hidden = true;
}

-(void)createClosePickerBtnAndAddToQrView {
    if (!closePickerBtn) {
        closePickerBtn = [[UIButton alloc] init];
        [closePickerBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [closePickerBtn setTranslatesAutoresizingMaskIntoConstraints:false];
        
        [closePickerBtn addTarget:self
                               action:@selector(slideInAnimation)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [closePickerBtn addConstraint:[NSLayoutConstraint constraintWithItem:closePickerBtn
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:100]];
        [closePickerBtn addConstraint:[NSLayoutConstraint constraintWithItem:closePickerBtn
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:50]];
    }
    
    [_qrView addSubview:closePickerBtn];
    
    NSLayoutConstraint *closeBtnTrailingSpace = [NSLayoutConstraint constraintWithItem:_qrView
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:closePickerBtn
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.0
                                                                              constant:-20];
    
    NSLayoutConstraint *closeBtnTopSpace = [NSLayoutConstraint constraintWithItem:closePickerBtn
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_qrView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-10];
    [_qrView addConstraint:closeBtnTrailingSpace];
    [_qrView addConstraint:closeBtnTopSpace];
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
    [_scrollView setHidden:NO];
    
    [self showNavigationAndStatusBar];
    
    _topBackgroundTopConstraint.constant = 0;
    _bottomBackgroundBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self updateConstraints];
        [self.view layoutIfNeeded];
    } completion:nil];
}

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

-(void)resetMainView {
    _locationLabel.text = @"Add place";
    _addDescLbl.text = @"Add description";
    _addDescTextView.text = @"";
    
    [_takePhotoTestButton resetConstraints];
    _takePhotoHeightConstraint.constant = _takePhotoTestButton.heightConstraint.constant;
    
    _descContainerHeightConstraint.constant = 45;
    _descriptionTestButton.heightConstraint.constant = _descContainerHeightConstraint.constant;
    [_descriptionTestButton setNeedsUpdateConstraints];
    [_descriptionTestButton updateConstraintsIfNeeded];
    [_descriptionTestButton layoutIfNeeded];
    [_descContainerView layoutIfNeeded];
    
    [self updateConstraints];
}

#pragma mark - hide system UI elements
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
- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.title = title;
    [alertView addButtonWithTitle:@"OK"];
    
    alertView.message = text;
    [alertView show];
}

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
    savePhotoBtn = [[UIButton alloc] init];
    [savePhotoBtn setTitle:@"Take Photo" forState:UIControlStateNormal];
    savePhotoBtn.translatesAutoresizingMaskIntoConstraints = false;
    
    [savePhotoBtn addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [_qrView addSubview:savePhotoBtn];
    
    [savePhotoBtn addConstraint:[NSLayoutConstraint constraintWithItem:savePhotoBtn
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:100]];
    [savePhotoBtn addConstraint:[NSLayoutConstraint constraintWithItem:savePhotoBtn
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:50]];
    
    
    NSLayoutConstraint *savePhotoBtnBottomConstraint = [NSLayoutConstraint constraintWithItem:_qrView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:savePhotoBtn
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0
                                                                                     constant:10];
    
    NSLayoutConstraint *savePhotoBtnTrailingConstraint = [NSLayoutConstraint constraintWithItem:_qrView
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:savePhotoBtn
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                     multiplier:1.0
                                                                                       constant:20];
    
    [_qrView addConstraint:savePhotoBtnBottomConstraint];
    [_qrView addConstraint:savePhotoBtnTrailingConstraint];
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
        _takePhotoHeightConstraint.constant = _takePhotoTestButton.heightConstraint.constant;
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
    [self createClosePickerBtnAndAddToQrView];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSLog(@"QR Code = %@", readableObject.stringValue);
        }
    }
}

- (void)resetCameraView {
    _session = nil;
    _captureDeviceInput = nil;
    _captureVideoPreviewLayer = nil;
    _captureDevice = nil;
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

- (void)checkCameraAuthorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        isCameraAvailable = NO;
    } else {
        isCameraAvailable = YES;
    }
}

- (void)startRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_session startRunning];
    });
}

- (void)stopRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_session stopRunning];
    });
}

@end
