//
//  MTLAlertView.h
//  Pods
//
//  Created by Yasuo Kasajima on 2015/08/21.
//
//

#import <UIKit/UIKit.h>


@class MTLAlertView;
@class MTLAlertButton;

typedef void(^MTLAlertTimerCloseHandler)(MTLAlertView *alertView);

/// The type of backgrould color
typedef NS_ENUM(NSUInteger, MTLAlertMaskType)
{
    MTLAlertMaskTypeNone = 0,
    MTLAlertMaskTypeBlack,
    MTLAlertMaskTypeWhite
};


/// TextAlignMode
typedef NS_ENUM(NSUInteger , MTLAlertAlignMode)
{
    // set textAligment {titleAlign, messageAlign, annotationAlign}.
    MTLAlertAlignModeNone = 0,
    /* 
     * If the line of UILabel is 1, set textAligment left.
     * If the line of UILabel is bigger than 1, set textAligment center.
     * We think this settig is better. We recommend use it.
     */
    MTLAlertAlignModeFlexible
};


/*
 * MTLAlertView is created for customizing design easily by UIAppearance
 */
@interface MTLAlertView : UIView <UIAppearance>

/// Font settings
@property (nonatomic) UIFont *titleFont                  UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *messageFont                UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *annotationFont             UI_APPEARANCE_SELECTOR;

/// Font Color settings
@property (nonatomic) UIColor *titleColor                UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *messageColor              UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *annotationColor           UI_APPEARANCE_SELECTOR;

/// Text align settings
@property (nonatomic) NSTextAlignment titleAlign         UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSTextAlignment messageAlign       UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSTextAlignment annotationAlign    UI_APPEARANCE_SELECTOR;

/// Text margin settings
@property (nonatomic) UIEdgeInsets titleMargin                      UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets messageMargin                    UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets annotationMargin                 UI_APPEARANCE_SELECTOR;

/// Text align mode settings
@property (nonatomic) MTLAlertAlignMode labelAlignMode  UI_APPEARANCE_SELECTOR;

/// Background images name for AlertView
@property (nonatomic) NSString *backgroundImageName UI_APPEARANCE_SELECTOR;

/// Insets for background image resize
@property (nonatomic) UIEdgeInsets backgroundImageResizableInsets   UI_APPEARANCE_SELECTOR;

/// Max height of message
@property (nonatomic) CGFloat messageMaximumHeight  UI_APPEARANCE_SELECTOR;

/// Padding of inside AlertView
@property (nonatomic) UIEdgeInsets padding   UI_APPEARANCE_SELECTOR;


/// User can close AlertView to tap Background, or not
@property (nonatomic) BOOL useBackgroundTapCloseMode;

/*
 * Time of auto close. 
 * If set it more than 0, auto close mode is enable
 * Default value is 0.
 */
@property (nonatomic) CGFloat closeTimeInterval;

/// This is called when AlrtView close automatically.
@property (nonatomic, copy) MTLAlertTimerCloseHandler timerCloseHandler;

/// Type of Background color
@property (nonatomic) MTLAlertMaskType maskType;

/// (optional)Top image
@property (nonatomic) UIImage *topImage;

/// (optional)Bottom image
@property (nonatomic) UIImage *bottomImage;

/// Title
@property (nonatomic) NSString *title;

/// (optional)Message
@property (nonatomic) NSString *message;

/// (optional)Annotation
@property (nonatomic) NSString *annotation;

/// (optional)Custom TopView
@property (nonatomic) UIView *customTopView;


#pragma mark - Public method

/// Initialize method with title
+ (MTLAlertView *)alertViewWithTitle:(NSString *)title;

/// Initialize method with title and message
+ (MTLAlertView *)alertViewWithTitle:(NSString *)title
                         withMessage:(NSString *)message;

/// Initialize method with title and message and customView
+ (MTLAlertView *)alertViewWithTitle:(NSString *)title
                         withMessage:(NSString *)message
                      withAnnotation:(NSString *)annotation
                      withCustomView:(UIView *)customView;

/// Add Submit button
- (MTLAlertButton *)addSubmitButtonWithTitle:(NSString *)title
                            withPressHandler:(void (^)(MTLAlertView *alertView))pressHandler;

/// Add Cancel button
- (MTLAlertButton *)addCancelButtonWithTitle:(NSString *)title
                            withPressHandler:(void (^)(MTLAlertView *alertView))pressHandler;

/// Show AlertView
- (void)show;

/// Show AlertView with background mask
- (void)showWithMaskType:(MTLAlertMaskType)maskType;

@end