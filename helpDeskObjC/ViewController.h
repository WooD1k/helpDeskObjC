//
//  ViewController.h
//  helpDeskObjC
//
//  Created by Alexey Chulochnikov on 30.09.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanditSDKOverlayController.h"

@interface ViewController : UIViewController <UITextFieldDelegate, ScanditSDKOverlayControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIButton *takePhoto;
@property (weak, nonatomic) IBOutlet UIButton *qr;

@property (weak, nonatomic) IBOutlet UITextField *issueLocation;
@property (weak, nonatomic) IBOutlet UITextField *issueDescription;
@property (weak, nonatomic) IBOutlet UIButton *sendIssue;

@property(weak, nonatomic) IBOutlet UITextField *activeTextField;

@property(nonatomic) ScanditSDKBarcodePicker *scanditPicker;
@property(nonatomic) UIButton *pickerSubviewButton;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)sendIssueToServer;
- (IBAction)scanQr:(UIButton *)sender;
- (IBAction)textFieldGotFocus:(UITextField *)sender;
- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender;

@end

