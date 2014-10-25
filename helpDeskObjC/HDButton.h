//
//  HDButton.h
//  helpDeskObjC
//
//  Created by Igor Koryakin on 10/13/14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDButton : UIControl

@property (weak, nonatomic) IBOutlet UIImageView *normalImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *takePhotoLbl;
@property (weak, nonatomic) IBOutlet UILabel *retakePhotoLbl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowBottomConstraint;

@property (copy, nonatomic) void (^touchBlock)(void);
@property (copy, nonatomic) void (^actionBlock)(void);

- (void)selectedState:(BOOL)selected;
- (void)setPhoto:(UIImage *)photo;
- (void)resetConstraints;

@end
