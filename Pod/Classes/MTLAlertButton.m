//
//  MTLAlertButton.m
//  MTLAlertView
//
//  Created by Yasuo Kasajima on 2015/09/16.
//  Copyright (c) 2015年 kasajei. All rights reserved.
//

#import "MTLAlertButton.h"

#pragma mark ========== MTLAlertButton ==========



@interface MTLAlertButton ()
@property (nonatomic) MTLAlertButtonType alertButtonType;
@end

@implementation MTLAlertButton

#pragma mark - Const

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _cancelButtonFontColor = [UIColor redColor];
        _normalButtonBackgroundImageName = @"MTLAlertViewBtnSubmit.png";
        _cancelButtonBackgroundImageName = @"MTLAlertViewBtnCancel.png";
    }
    return self;
}

+(id)buttonWithType:(UIButtonType)buttonType{
    MTLAlertButton *button = [super buttonWithType:buttonType];
    return button;
}

+(id)buttonWithType:(MTLAlertButtonType)buttonType
              title:(NSString *)title
         withHander:(MTLAlertPressHandler)hander{
    MTLAlertButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.exclusiveTouch = YES;
    button.pressHandler = hander;
    [button setTitle:title forState:UIControlStateNormal];
    button.alertButtonType = buttonType;
    [button setup];
    return button;
}


- (void)setup {
    [self setButtonImage];
    self.titleLabel.font = (self.alertButtonType == MTLAlertButtonTypeCancel) ? self.cancelButtonFont : self.normalButtonFont;
    [self setTitleColor:(self.alertButtonType == MTLAlertButtonTypeCancel) ? self.cancelButtonFontColor : self.normalButtonFontColor
               forState:UIControlStateNormal];
}

- (void)setButtonImage {
    UIImage *image;
    switch (_alertButtonType) {
        case MTLAlertButtonTypeSubmit:
            image = [UIImage imageNamed:self.normalButtonBackgroundImageName];
            break;
        case MTLAlertButtonTypeCancel:
            image = [UIImage imageNamed:self.cancelButtonBackgroundImageName];
            break;
        default:
            break;
    }
    
    [self setBackgroundImage:[image resizableImageWithCapInsets:self.imageResizableInsets]
                    forState:UIControlStateNormal];
    CGRect rect = self.frame;
    rect.size.width = [self backgroundImageForState:UIControlStateNormal].size.width;
    rect.size.height = [self backgroundImageForState:UIControlStateNormal].size.height;
    self.frame = rect;
    if ([self.delegate respondsToSelector:@selector(alertButton:didChangeFrame:)]){
        [self.delegate alertButton:self didChangeFrame:rect];
    }
}

#pragma mark - Appearance

- (void)setImageResizableInsets:(UIEdgeInsets)imageResizableInsets {
    _imageResizableInsets = imageResizableInsets;
    [self setButtonImage];
}

- (void)setNormalButtonBackgroundImageName:(NSString *)buttonBackgroundImageNameNormal {
    _normalButtonBackgroundImageName = buttonBackgroundImageNameNormal;
    [self setButtonImage];
}

- (void)setCancelButtonBackgroundImageName:(NSString *)buttonBackgroundImageNameCancel {
    _cancelButtonBackgroundImageName = buttonBackgroundImageNameCancel;
    [self setButtonImage];
}

- (void)setNormalButtonFont:(UIFont *)buttonFontNormal {
    _normalButtonFont = buttonFontNormal;
    self.titleLabel.font = (self.alertButtonType == MTLAlertButtonTypeCancel) ? self.cancelButtonFont : self.normalButtonFont;
}

- (void)setCancelButtonFont:(UIFont *)buttonFontCancel {
    _cancelButtonFont = buttonFontCancel;
    self.titleLabel.font = (self.alertButtonType == MTLAlertButtonTypeCancel) ? self.cancelButtonFont : self.normalButtonFont;
}


- (void)setNormalButtonFontColor:(UIColor *)buttonFontColorNormal {
    _normalButtonFontColor = buttonFontColorNormal;
    [self setTitleColor:(self.alertButtonType == MTLAlertButtonTypeCancel) ? self.cancelButtonFontColor : self.normalButtonFontColor
               forState:UIControlStateNormal];
}


- (void)setCancelButtonFontColor:(UIColor *)buttonFontColorCancel {
    _cancelButtonFontColor = buttonFontColorCancel;
    [self setTitleColor:(self.alertButtonType == MTLAlertButtonTypeCancel) ? self.cancelButtonFontColor : self.normalButtonFontColor
               forState:UIControlStateNormal];
}

@end

