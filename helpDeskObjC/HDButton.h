//
//  HDButton.h
//  helpDeskObjC
//
//  Created by Igor Koryakin on 10/13/14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_HDBUTTON_SIZE 170

@interface HDButton : UIControl

@property (strong, nonatomic) UIImageView *normalImageView;
@property (strong, nonatomic) UIImageView *selectedImageView;
@property (strong, nonatomic) UIImageView *shadowImageView;

@property (strong, nonatomic) IBOutlet UIView *contentView;


@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *photoCameraImageView;

@property (weak, nonatomic) IBOutlet UILabel *takePhotoLbl;
@property (weak, nonatomic) IBOutlet UILabel *retakePhotoLbl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

@property (strong, nonatomic) UIImage *normalImage;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) UIImage *shadowImage;

@property (assign, nonatomic, getter=isScalableBackground) BOOL scalableBackground;

/**
 *  Blocks for touchDown, touchUp, touchCanceled, action states
 */
@property (copy, nonatomic) void (^touchDownBlock)(void);
@property (copy, nonatomic) void (^touchUpBlock)(void);
@property (copy, nonatomic) void (^touchCanceledBlock)(void);
@property (copy, nonatomic) void (^actionBlock)(void);

/**
 *  Method to set photo whe photo was taken
 *
 *  @param photo UIImage to set as photo
 */
- (void)setPhoto:(UIImage *)photo;

/**
 *  Method to reset constraints to default values
 */
- (void)resetConstraints;

@end
