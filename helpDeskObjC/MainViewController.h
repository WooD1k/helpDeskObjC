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
@property (weak, nonatomic) IBOutlet HDButton *locationTestButton;
@property (weak, nonatomic) IBOutlet HDButton *qrCodeTestButton;
@property (weak, nonatomic) IBOutlet HDButton *descriptionTestButton;
@property (weak, nonatomic) IBOutlet HDButton *sendTestButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBackgroundTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBackgroundBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBackgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBackgroundHeightConstraint;

#pragma mark - scanQrBtn elements
@property (weak, nonatomic) IBOutlet UIImageView *locationPinImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIView *locationContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationPinImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationLblLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQrImageViewCenterXConstraint;

#pragma mark - addDesc elements
@property (weak, nonatomic) IBOutlet UIImageView *descMarkerImageView;
@property (weak, nonatomic) IBOutlet UILabel *addDescLbl;
@property (weak, nonatomic) IBOutlet UITextView *addDescTextView;
@property (weak, nonatomic) IBOutlet UIView *descContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descMarkerImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addDescLblLeadingConstraint;

#pragma mark - sendBtn elements
@property (weak, nonatomic) IBOutlet UILabel *sendReportLbl;
@property (weak, nonatomic) IBOutlet UILabel *reportSentLbl;

#pragma makr - elements for slideIn\slideOut animation

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) UITextField *activeTextField;

@property (strong, nonatomic) ScanditSDKBarcodePicker *scanditPicker;
@property (nonatomic) UIButton *closePickerButton;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (nonatomic, strong) UIDynamicAnimator *animator;

- (IBAction)textFieldGotFocus:(UITextField *)sender;

- (IBAction)hideKeyboard:(id)sender;

#pragma mark - send report animation
- (void)moveElementsOffscreen;

#pragma mark - AVFoundation
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

