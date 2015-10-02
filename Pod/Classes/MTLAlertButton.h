//
//  MTLAlertButton.h
//  MTLAlertView
//
//  Created by Yasuo Kasajima on 2015/09/16.
//  Copyright (c) 2015年 kasajei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTLAlertView;
@class MTLAlertButton;

typedef void(^MTLAlertPressHandler)(MTLAlertView *alertView);


/**
 * Delegate for MTLAlertButton
 */
@protocol MTLAlertButtonDelegate <NSObject>
@optional
- (void)alertButton:(MTLAlertButton *)alertButton
     didChangeFrame:(CGRect)frame;

@end



/**
 * The butoom for MTLAlertView
 */
@interface MTLAlertButton : UIButton <UIAppearance>

@property (nonatomic, weak) id<MTLAlertButtonDelegate> delegate;
@property (nonatomic, copy) MTLAlertPressHandler pressHandler;

/// Font
@property (nonatomic) UIFont *normalButtonFont          UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *cancelButtonFont          UI_APPEARANCE_SELECTOR;

/// Font Color
@property (nonatomic) UIColor *normalButtonFontColor    UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *cancelButtonFontColor    UI_APPEARANCE_SELECTOR;

/// Background Images name
@property (nonatomic) NSString *normalButtonBackgroundImageName UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSString *cancelButtonBackgroundImageName UI_APPEARANCE_SELECTOR;

/// Insets for Background image resize
@property (nonatomic) UIEdgeInsets imageResizableInsets         UI_APPEARANCE_SELECTOR;

typedef NS_ENUM(NSUInteger , MTLAlertButtonType)
{
    MTLAlertButtonTypeSubmit,
    MTLAlertButtonTypeCancel
};

+ (id)buttonWithType:(MTLAlertButtonType)buttonType
               title:(NSString *)title
          withHander:(MTLAlertPressHandler)hander;

@end

