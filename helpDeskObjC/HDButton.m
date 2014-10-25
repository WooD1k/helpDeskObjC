//
//  HDButton.m
//  helpDeskObjC
//
//  Created by Igor Koryakin on 10/13/14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

#import "HDButton.h"

#define SCALE_DELDA 6
#define SCALE 0.9

@implementation HDButton {
    NSInteger normalHeight;
    NSInteger scaledHeight;
    BOOL isTouchUp;
    BOOL isTouchDown;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouchDown = NO;
    isTouchUp = NO;
    
    if (self.touchBlock) {
        self.touchBlock();
    }
}
//
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouchUp = YES;
    
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouchUp = YES;
    
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)selectedState:(BOOL)selected
{
    if (selected) {
        [self downAnimation];
    } else {
        [self upAnimation];
    }
}

- (void)downAnimation
{
    if (!normalHeight) {
        normalHeight = self.heightConstraint.constant;
        scaledHeight = normalHeight - SCALE_DELDA;
    }
    
    self.heightConstraint.constant = scaledHeight;
    self.shadowBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.selectedImageView.alpha = 1;
        self.contentView.transform = CGAffineTransformMakeScale(SCALE, SCALE);
        self.contentView.center = CGPointMake(self.bounds.size.width/2, scaledHeight/2-30);
        
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        isTouchDown = YES;
        if (self.actionBlock) {
            self.actionBlock();
        }
    }];
}

- (void)upAnimation
{
    if (!isTouchUp || !isTouchDown) return;
    
    self.heightConstraint.constant = normalHeight;
    self.shadowBottomConstraint.constant = -self.shadowImageView.frame.size.height;
    
    self.contentView.transform = CGAffineTransformMakeScale(1., 1.);
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.selectedImageView.alpha = 0;
        
        [self layoutSubviews];
    } completion:^(BOOL finished) {
    }];
}

- (void)setPhoto:(UIImage *)photo {
	_heightConstraint.constant = self.heightConstraint.constant * 1.5;
	_photoImageView.image = photo;
	
	_takePhotoLbl.alpha = 0.0;
	_retakePhotoLbl.alpha = 1.0;
	
	_photoImageView.alpha = 1.0;
}

- (void)resetConstraints {
	 _heightConstraint.constant = normalHeight;
	
	_takePhotoLbl.alpha = 1.0;
	_retakePhotoLbl.alpha = 0.0;
	_photoImageView.image = nil;
	
	[UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		[self layoutSubviews];
	} completion:nil];
}

//- (IBAction)takePhotoTouchDown {
//    [self moveShadow:_takePhotoBtnShadowImageView up:YES];
//    [self setMainImage:_takePhotoBtnImageView invisible:YES];
//}
//
//- (IBAction)takePhotoTouchUpInside {
//    [self moveShadow:_takePhotoBtnShadowImageView up:NO];
//    [self setMainImage:_takePhotoBtnImageView invisible:NO];
//    
//    _imagePicker = [[UIImagePickerController alloc] init];
//    _imagePicker.delegate = self;
//    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        _imagePicker.allowsEditing = true;
//        
//        [self.navigationController presentViewController:_imagePicker animated:true completion:nil];
//    }
//}
//
//- (IBAction)takePhotoTouchCancel {
//    [self moveShadow:_takePhotoBtnShadowImageView up:NO];
//    [self setMainImage:_takePhotoBtnImageView invisible:NO];
//}
//
//- (void)moveShadow:(UIImageView *)shadowToMove up:(BOOL)isMoveUp {
//    [UIView animateWithDuration:0.3 animations:^{
//        if (isMoveUp) {
//            shadowToMove.center = CGPointMake(shadowToMove.center.x, shadowToMove.center.y - shadowToMove.frame.size.height);
//        } else {
//            shadowToMove.center = CGPointMake(shadowToMove.center.x, shadowToMove.center.y + shadowToMove.frame.size.height);
//        }
//    }];
//}
//
//- (void)setMainImage:(UIImageView *) imageView invisible:(BOOL) isSetInvisible {
//    if (isSetInvisible) {
//        [UIView animateWithDuration:0.2 animations:^{
//            [imageView setAlpha:0.0];
//        }];
//    } else {
//        [UIView animateWithDuration:0.2 animations:^{
//            [imageView setAlpha:1.0];
//        }];
//    }
//}


@end
