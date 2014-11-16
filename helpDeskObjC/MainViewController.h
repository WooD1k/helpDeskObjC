//
//  ViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HDButton.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (nonatomic) BOOL isSendingData;

@property (weak, nonatomic) IBOutlet HDButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet HDButton *locationButton;
@property (weak, nonatomic) IBOutlet HDButton *qrCodeButton;
@property (weak, nonatomic) IBOutlet HDButton *descriptionButton;
@property (weak, nonatomic) IBOutlet HDButton *sendButton;

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
@property (nonatomic) AVCaptureMetadataOutput *metadataOutput;

@end

