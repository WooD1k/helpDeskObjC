//
//  ViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, ScanditSDKOverlayControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *qrView;

#pragma mark - takePhotoBtn elements
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoBtnImageView;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoBtnSelectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoBtnShadowImageView;

#pragma makr - elements for slideIn\slideOut animation
@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;

@property (weak, nonatomic) IBOutlet UITextField *issueLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *issueDescriptionTextField;

@property (weak, nonatomic) UITextField *activeTextField;

@property (nonatomic) ScanditSDKBarcodePicker *scanditPicker;
@property (nonatomic) UIButton *closePickerButton;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)sendIssueToServer;
- (IBAction)scanQr:(UIButton *)sender;
- (IBAction)textFieldGotFocus:(UITextField *)sender;
- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender;

#pragma mark - takePhotoBtn events
- (IBAction)takePhotoTouchDown:(UIControl *)sender;
- (IBAction)takePhotoTouchUpInside:(UIControl *)sender;

@end

