//
//  ViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"

@interface ViewController : UIViewController <UITextFieldDelegate, ScanditSDKOverlayControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;

@property (weak, nonatomic) IBOutlet UITextField *issueLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *issueDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendIssueButton;

@property (weak, nonatomic) UITextField *activeTextField;

@property (nonatomic) ScanditSDKBarcodePicker *scanditPicker;
@property (nonatomic) UIButton *closePickerButton;
@property (nonatomic) UIImagePickerController *imagePicker;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)sendIssueToServer;
- (IBAction)scanQr:(UIButton *)sender;
- (IBAction)textFieldGotFocus:(UITextField *)sender;
- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender;

@end

