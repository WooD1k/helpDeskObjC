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
#define NORMAL_HEIGHT 96


@implementation HDButton {
    NSInteger normalHeight;
    NSInteger scaledHeight;
    BOOL isTouchUp;
    BOOL isTouchDown;
    NSLayoutConstraint *internalContentViewWidthConstraint;
    NSLayoutConstraint *internalContentViewHeightConstraint;
    UIView *internalContentView;
    NSLayoutConstraint *shadowTopConstraint;
    
    void (^endBlock)(void);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self addInternalContentView];
    }
    
    return self;
}

- (void)addInternalContentView {
    self.backgroundColor = [UIColor clearColor];
    _scalableBackground = YES;
    CGRect aBounds = self.bounds;
    
    internalContentView = [[UIView alloc] initWithFrame:aBounds];
    [internalContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:internalContentView];
    
    internalContentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:internalContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self addConstraint:internalContentViewWidthConstraint];
    
    internalContentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:internalContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_heightConstraint.constant];
    [internalContentView addConstraint:internalContentViewHeightConstraint];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:internalContentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:internalContentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)updateConstraints {
    [super updateConstraints];
    internalContentViewHeightConstraint.constant = _heightConstraint.constant;
    _contentViewHeightConstraint.constant = _heightConstraint.constant;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self insertSubview:internalContentView belowSubview:_contentView];
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    _normalImageView = [[UIImageView alloc] initWithImage:normalImage];
    [_normalImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [internalContentView addSubview:_normalImageView];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_normalImageView);
    [internalContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_normalImageView]|" options:0 metrics:nil views:dict]];
    [internalContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_normalImageView]|" options:0 metrics:nil views:dict]];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    _selectedImageView = [[UIImageView alloc] initWithImage:selectedImage];
    _selectedImageView.alpha = 0;
    [_selectedImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [internalContentView addSubview:_selectedImageView];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_selectedImageView);
    [internalContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectedImageView]|" options:0 metrics:nil views:dict]];
    [internalContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectedImageView]|" options:0 metrics:nil views:dict]];
}

- (void)setShadowImage:(UIImage *)shadowImage {
    _shadowImage = shadowImage;
    _shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    [_shadowImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [internalContentView addSubview:_shadowImageView];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_shadowImageView);
    [internalContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shadowImageView]|" options:0 metrics:nil views:dict]];
    
    shadowTopConstraint = [NSLayoutConstraint constraintWithItem:_shadowImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:internalContentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [internalContentView addConstraint:shadowTopConstraint];
    
    [_shadowImageView addConstraint:[NSLayoutConstraint constraintWithItem:_shadowImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_shadowImageView.frame.size.height]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchDown = NO;
    isTouchUp = NO;
    
    if (self.touchDownBlock) {
        self.touchDownBlock();
    }
    
    [self selectedState:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchUp = YES;
    
    if (isTouchDown) {
        if (self.touchCanceledBlock) {
            self.touchCanceledBlock();
        }
        
        [self resetState];
    } else {
        endBlock = self.touchCanceledBlock;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchUp = YES;
    
    UITouch *touch = [touches anyObject];
    
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        if (isTouchDown) {
            if (self.touchUpBlock) {
                self.touchUpBlock();
            }
            
            [self selectedState:NO];
        } else {
            endBlock = self.touchUpBlock;
        }
    } else {
        if (isTouchDown) {
            if (self.touchCanceledBlock) {
                self.touchCanceledBlock();
            }
            
            [self resetState];
        } else {
            endBlock = self.touchCanceledBlock;
        }
    }
}

- (void)selectedState:(BOOL)selected {
    if (selected) {
        [self downAnimation];
    } else {
        [self upAnimation:YES];
    }
}

- (void)resetState {
    [self upAnimation:NO];
}

- (void)downAnimation {
    [self layoutSubviews];
    
    if (!normalHeight) {
        normalHeight = self.heightConstraint.constant;
        scaledHeight = normalHeight - SCALE_DELDA;
    }
    
    if (_scalableBackground) {
        internalContentViewHeightConstraint.constant = scaledHeight;
    }
    
    shadowTopConstraint.constant = -self.shadowImageView.frame.size.height;
    
    [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectedImageView.alpha = 1;
        self.contentView.transform = CGAffineTransformMakeScale(SCALE, SCALE);
        
        [internalContentView layoutSubviews];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        isTouchDown = YES;
        if (isTouchUp) {
            if (endBlock) {
                endBlock();
            }
            [self selectedState:NO];
        }
    }];
}

- (void)upAnimation:(BOOL)shouldCallActionBlock {
    if (!isTouchUp || !isTouchDown) return;
    
    if (_scalableBackground) {
        internalContentViewHeightConstraint.constant = normalHeight;
    }
    
    shadowTopConstraint.constant = 0;
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectedImageView.alpha = 0;
        self.contentView.transform = CGAffineTransformMakeScale(1., 1.);
        
        [internalContentView layoutSubviews];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        if (self.actionBlock && shouldCallActionBlock) {
            self.actionBlock();
        }
    }];
}

- (void)setPhoto:(UIImage *)photo {
	_heightConstraint.constant = MAX_HDBUTTON_SIZE;
    normalHeight = MAX_HDBUTTON_SIZE;
    scaledHeight = normalHeight - SCALE_DELDA;
    
	_photoImageView.image = photo;
	
    [_takePhotoLbl setHidden:YES];
    [_photoCameraImageView setHidden:YES];
    
	[_retakePhotoLbl setHidden:NO];
	[_photoImageView setHidden:NO];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    [internalContentView layoutIfNeeded];
    [_contentView layoutIfNeeded];
}

- (void)resetConstraints {
	 _heightConstraint.constant = NORMAL_HEIGHT;
    normalHeight = NORMAL_HEIGHT;
	scaledHeight = normalHeight - SCALE_DELDA;
    
	[_takePhotoLbl setHidden:NO];
	[_retakePhotoLbl setHidden:YES];
	_photoImageView.image = nil;
    [_photoCameraImageView setHidden:NO];
    [_photoImageView setHidden:YES];
	
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    [internalContentView layoutIfNeeded];
    [_contentView layoutIfNeeded];
}

@end
