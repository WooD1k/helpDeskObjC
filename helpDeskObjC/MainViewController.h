//
//  ViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"
#import "HDButton.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, ScanditSDKOverlayControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (nonatomic) BOOL isSendingData;

#pragma mark - takePhotoBtn elements
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;

@property (weak, nonatomic) IBOutlet HDButton *takePhotoTestButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoBtnTopConstraint;

#pragma mark - scanQrBtn elements
@property (weak, nonatomic) IBOutlet UIImageView *locationPinImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIView *locationTextFieldOverlayView;
@property (weak, nonatomic) IBOutlet UIButton *scanQrBtn;
@property (weak, nonatomic) IBOutlet UIImageView *scanQrBtnBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *addLocationManuallyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *addLocationManuallyImageView;
@property (weak, nonatomic) IBOutlet UIView *locationContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationPinImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationLblLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQrBtnTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQrBtnBackgroundImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationTextFieldOverlayWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQrContainerTopConstraint;

#pragma mark - addDesc elements
@property (weak, nonatomic) IBOutlet UIImageView *descMarkerImageView;
@property (weak, nonatomic) IBOutlet UIButton *addDescBtn;
@property (weak, nonatomic) IBOutlet UIImageView *addDescBtnSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *addDescLbl;
@property (weak, nonatomic) IBOutlet UITextView *addDescTextView;
@property (weak, nonatomic) IBOutlet UIImageView *addDescShadowImageView;
@property (weak, nonatomic) IBOutlet UIView *descContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *addDescBtnBackground;
@property (weak, nonatomic) IBOutlet UIImageView *addDescBtnBackgroundSelected;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descMarkerImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addDescLblLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addDescLblConstrain;

#pragma mark - sendBtn elements
@property (weak, nonatomic) IBOutlet UIButton *sendReportBtn;
@property (weak, nonatomic) IBOutlet UILabel *sendReportLbl;
@property (weak, nonatomic) IBOutlet UILabel *reportSentLbl;
@property (weak, nonatomic) IBOutlet UIImageView *sendReportBtnSelectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sendReportShadowImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendReportBtnTopToMainViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendReportLblLeadingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportSentLblTrailingConstraint;

#pragma makr - elements for slideIn\slideOut animation
@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoImageViewHeightConstraint;

@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) UITextView *activeTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerTopConstraint;

@property (strong, nonatomic) ScanditSDKBarcodePicker *scanditPicker;
@property (nonatomic) UIButton *closePickerButton;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

- (IBAction)textFieldGotFocus:(UITextField *)sender;
- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender;

#pragma mark - addLocation events
- (IBAction)addLocationManuallyTouchDown;
- (IBAction)addLocationManuallyTouchUpInside;
- (IBAction)addLocationManuallyTouchCancel;
- (IBAction)addLocationManuallyDidEnd;

#pragma mark - addLocation manually events
- (IBAction)scanQrTouchDown;
- (IBAction)scanQrTouchUpInside;
- (IBAction)scanQrTouchCancel;

#pragma mark - add description events
- (IBAction)addDecBtnTouchDown;
- (IBAction)addDescBtnTouchUpInside;
- (IBAction)addDescBtnTouchCancel;

#pragma mark - send report events
- (IBAction)sendReportTouchDown;
- (IBAction)sendReportTouchUpInside;
- (IBAction)sendReportTouchCancel;

#pragma mark - send report animation
- (void)moveElementsOffscreen;

#pragma mark - AVFoundation
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

