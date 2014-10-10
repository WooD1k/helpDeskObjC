//
//  ViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, ScanditSDKOverlayControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *qrView;

#pragma mark - takePhotoBtn elements
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoBtnImageView;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoBtnSelectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoBtnShadowImageView;

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

#pragma makr - elements for slideIn\slideOut animation
@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UITextField *issueLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *issueDescriptionTextField;

@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) UITextView *activeTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerTopConstraint;

@property (nonatomic) ScanditSDKBarcodePicker *scanditPicker;
@property (nonatomic) UIButton *closePickerButton;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)sendIssueToServer;
- (IBAction)textFieldGotFocus:(UITextField *)sender;
- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender;

#pragma mark - takePhotoBtn events
- (IBAction)takePhotoTouchDown:(UIControl *)sender;
- (IBAction)takePhotoTouchUpInside:(UIControl *)sender;

#pragma mark - addLocation events
- (IBAction)addLocationManuallyTouchDown;
- (IBAction)addLocationManuallyTouchUpInside;
- (IBAction)addLocationManuallyTouchCancel;
- (IBAction)addLocationManuallyDidEnd;

#pragma mark - addLocation manually events
- (IBAction)scanQrTouchDown;
- (IBAction)scanQrTouchUpInside;
- (IBAction)scanQrTouchCancel;

#pragma mark - add description
- (IBAction)addDecBtnTouchDown;
- (IBAction)addDescBtnTouchUpInside;
- (IBAction)addDescBtnTouchCancel;

@end

