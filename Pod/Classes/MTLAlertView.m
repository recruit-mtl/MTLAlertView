//
//  MTLAlertView.m
//  Pods
//
//  Created by Yasuo Kasajima on 2015/08/21.
//
//

#import "MTLAlertView.h"
#import "MTLAlertButton.h"

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface MTLAlertView()<MTLAlertButtonDelegate>
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) NSTimer *closeTimer;
@property (nonatomic) UIImageView *topImageView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextView *messageView;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UILabel *annotationLabel;
@property (nonatomic) UIImageView *bottomImageView;
@end

@implementation MTLAlertView

#pragma mark - Initialization Methods

+ (MTLAlertView *)alertViewWithTitle:(NSString *)title {
    return [self alertViewWithTitle:title withMessage:nil];
}

+ (MTLAlertView *)alertViewWithTitle:(NSString *)title
                         withMessage:(NSString *)message {
    
    MTLAlertView *alertView = [[MTLAlertView alloc] initWithTitle:title
                                                          message:message
                                                       annotation:nil
                                                       customView:nil];
    return alertView;
}

+ (MTLAlertView *)alertViewWithTitle:(NSString *)title
                         withMessage:(NSString *)message
                      withAnnotation:(NSString *)annotation
                      withCustomView:(UIView *)customView {
    
    MTLAlertView *alertView = [[MTLAlertView alloc] initWithTitle:title
                                                          message:message
                                                       annotation:annotation
                                                       customView:customView];
    return alertView;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
         annotation:(NSString *)annotationOrNil
         customView:(UIView *)customViewOrNil {
    self = [super init];
    if (self)
    {
        _title = title;
        _message = message;
        _annotation = annotationOrNil;
        _customTopView = customViewOrNil;
        _buttons = [NSMutableArray array];
        _padding = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
        _backgroundImageResizableInsets = UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);
        _titleFont = [UIFont boldSystemFontOfSize:18.0f];
        _messageFont = [UIFont boldSystemFontOfSize:15.0f];
        _annotationFont = [UIFont systemFontOfSize:12.0f];
        
        _titleColor = [UIColor darkGrayColor];
        _messageColor = [UIColor darkGrayColor];
        _annotationColor = [UIColor grayColor];
        
        _backgroundImageName = @"MTLAlertViewBg.png";
        self.frame = [UIScreen mainScreen].bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - Add Button Methods
- (MTLAlertButton *)addSubmitButtonWithTitle:(NSString *)title
                            withPressHandler:(void (^)(MTLAlertView *alertView))pressHandler {
    MTLAlertButton *button = [MTLAlertButton buttonWithType:MTLAlertButtonTypeSubmit
                                                      title:title
                                                 withHander:pressHandler];
    button.delegate = self;
    // Add action for dissmiss animation
    [button addTarget:self
               action:@selector(pressButton:)
     forControlEvents:UIControlEventTouchUpInside];
    // The button add self in [self setup].
    [self.buttons addObject:button];
    return button;
}

- (MTLAlertButton *)addCancelButtonWithTitle:(NSString *)title
                            withPressHandler:(void (^)(MTLAlertView *alertView))pressHandler; {
    MTLAlertButton *button = [MTLAlertButton buttonWithType:MTLAlertButtonTypeCancel
                                                      title:title
                                                 withHander:pressHandler];
    button.delegate = self;
    // Add action for dissmiss animation
    [button addTarget:self
               action:@selector(pressButton:)
     forControlEvents:UIControlEventTouchUpInside];
    // The button add self in [self setup].
    [self.buttons addObject:button];
    return button;
}

#pragma mark - Show Methods

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert];
    });
}

- (void)showWithMaskType:(MTLAlertMaskType)maskType
{
    self.maskType = maskType;
    [self show];
}

#pragma mark - Private Methods

- (void)showAlert {
    [self setupView];
    [self layoutView];
    [self setTextAlignments];
    [self.titleLabel sizeToFit];
    [self.messageLabel sizeToFit];
    [self.annotationLabel sizeToFit];
    [self positionAlertView:nil];
    
    if (self.useBackgroundTapCloseMode) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(backgroundTapHandler:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    
    __weak typeof(self) wSelf = self;
    [self executeShowAnimation:^(BOOL finished) {
        if (wSelf.closeTimeInterval > 0.f)
        {
            wSelf.closeTimer = [NSTimer scheduledTimerWithTimeInterval:wSelf.closeTimeInterval
                                                           target:wSelf
                                                         selector:@selector(timerHandler:)
                                                         userInfo:nil
                                                          repeats:NO];
        }
    }];

    // Set Notification to change positon when keybord layout change.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionAlertView:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionAlertView:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionAlertView:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionAlertView:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionAlertView:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    
    
    // Add AlertView on TopWindow
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];

}

- (void)setupView {
    UIImage *image = [UIImage imageNamed:self.backgroundImageName];
    [image resizableImageWithCapInsets:self.backgroundImageResizableInsets];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:image];
    self.backgroundImageView.userInteractionEnabled = YES;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.backgroundImageView];
    
    if (self.topImage) {
        self.topImageView = [[UIImageView alloc] initWithImage:self.topImage];
        [self.backgroundImageView addSubview:self.topImageView];
    }
    
    if (self.customTopView) {
        [self.backgroundImageView addSubview:self.customTopView];
    }
    
    if (self.title)
    {
        self.titleLabel = [self titleLabelWithTitle:self.title];
        [self.backgroundImageView addSubview:self.titleLabel];
    }
    
    if (self.message) {
        self.messageView = [self messageViewWithMessage:self.message];
        [self.backgroundImageView addSubview:self.messageView];
        self.messageLabel = [self messageLabelWithMessage:self.message];
        [self.backgroundImageView addSubview:self.messageLabel];
    }
    
    if (self.annotation) {
        self.annotationLabel = [self annotationLabelWithAnnotation:self.annotation];
        [self.backgroundImageView addSubview:self.annotationLabel];
    }
    
    if (self.bottomImage) {
        self.bottomImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.backgroundImageView addSubview:self.bottomImageView];
    }
    
    for (MTLAlertButton *button in self.buttons) {
        [self.backgroundImageView addSubview:button];
    }
    
    self.backgroundImageView.alpha = 0;
    UIColor *color;
    switch (self.maskType)
    {
        case MTLAlertMaskTypeBlack:
            color = [UIColor colorWithWhite:0.0f
                                      alpha:0.8f];
            break;
        case MTLAlertMaskTypeWhite:
            color = [UIColor colorWithWhite:1.0f
                                      alpha:0.8f];
            break;
        default:
            color = [UIColor colorWithWhite:0.0f
                                      alpha:0.0f];
            break;
    }
    self.backgroundColor = color;
}

- (void)layoutView {
    CGFloat h = self.padding.top;
    CGFloat bw = self.backgroundImageView.frame.size.width;
    if (self.topImage) {
        CGFloat w = bw - (self.padding.left + self.padding.right);
        
        if (self.topImage.size.width < w && self.topImage.size.height < w) {
            self.topImageView.frame = CGRectMake(self.padding.left, h, w, self.topImage.size.height);
            self.topImageView.contentMode = UIViewContentModeCenter;
        }
        else {
            CGFloat h2;
            if (self.topImage.size.width >= self.topImage.size.height)
            {
                h2 = w / self.topImage.size.width * self.topImage.size.height;
            } else {
                h2 = w;
            }
            self.topImageView.frame = CGRectMake(self.padding.left, h, w, h2);
            self.topImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        h += self.topImageView.frame.size.height + 10;
    }
    if (self.customTopView) {
        CGRect r = self.customTopView.frame;
        r.origin.y = h;
        r.origin.x = (bw - r.size.width) / 2;
        self.customTopView.frame = r;
        h += self.customTopView.frame.size.height + 10;
    }
    if (self.title) {
        CGRect r = self.titleLabel.frame;
        r.origin.y = h;
        r.size.width = bw - (self.padding.left + self.padding.right);
        self.titleLabel.frame = r;
        h += self.titleLabel.frame.size.height + 10;
    }
    if (self.message) {
        CGRect rect = [self.message boundingRectWithSize:CGSizeMake(bw - (self.padding.left + self.padding.right), 100000)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:NULL
                                                  context:NULL];
        CGSize size = rect.size;
        if (size.height > self.messageMaximumHeight) {
            CGRect r = self.messageView.frame;
            r.origin.y = h;
            r.size.width = bw - (self.padding.left + self.padding.right);
            self.messageView.frame = r;
            h += self.messageView.frame.size.height + 10;
            self.messageView.hidden = NO;
            self.messageLabel.hidden = YES;
        }
        else {
            CGRect r = self.messageLabel.frame;
            r.origin.y = h;
            r.size.width = bw - (self.padding.left + self.padding.right);
            self.messageLabel.frame = r;
            h += self.messageLabel.frame.size.height + 10;
            self.messageView.hidden = YES;
            self.messageLabel.hidden = NO;
        }
    }
    if (self.annotation) {
        CGRect r = self.annotationLabel.frame;
        r.origin.y = h;
        r.size.width = bw - (self.padding.left + self.padding.right);
        self.annotationLabel.frame = r;
        h += self.annotationLabel.frame.size.height + 10;
    }
    if (self.bottomImage)
    {
        CGFloat w = bw - (self.padding.left + self.padding.right);
        
        if (self.bottomImage.size.width < w && self.bottomImage.size.height < w)
        {
            self.bottomImageView.frame = CGRectMake(self.padding.left, h, w, self.bottomImage.size.height);
            self.bottomImageView.contentMode = UIViewContentModeCenter;
        } else {
            CGFloat h2;
            if (self.bottomImage.size.width >= self.bottomImage.size.height)
            {
                h2 = w / self.bottomImage.size.width * self.bottomImage.size.height;
            } else {
                h2 = w;
            }
            
            self.bottomImageView.frame = CGRectMake(self.padding.left, h, w, h2);
            self.bottomImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        self.bottomImageView.image = self.bottomImage;
        h += self.bottomImageView.frame.size.height + 10;
    }
    if (self.buttons.count > 0) {
        h += 10.0f;
    }
    
    CGFloat halfWidth = (bw - (self.padding.left + self.padding.right)) / 2 - 5;
    if (self.buttons.count == 2 && [self widthOfButton:self.buttons[0]] <= halfWidth && [self widthOfButton:self.buttons[1]] <= halfWidth) {
        CGFloat highHeight;
        MTLAlertButton *button0 = self.buttons[0];
        MTLAlertButton *button1 = self.buttons[1];
        
        CGRect bRect = button0.frame;
        bRect.origin.y = h;
        bRect.origin.x = self.padding.left;
        bRect.size.width = halfWidth;
        button0.frame = bRect;
        highHeight = button0.frame.size.height;
        
        bRect = button1.frame;
        bRect.origin.y = h;
        bRect.origin.x = self.padding.left + button0.frame.size.width + 10.0f;
        bRect.size.width = halfWidth;
        button1.frame = bRect;
        if (button1.frame.size.height > highHeight) highHeight = button1.frame.size.height;
        
        h += highHeight + 10.0f;
    } else {
        for (MTLAlertButton *button in self.buttons)
        {
            CGRect bRect = button.frame;
            bRect.origin.y = h;
            bRect.origin.x = self.padding.left;
            bRect.size.width = bw - (self.padding.left + self.padding.right);
            button.frame = bRect;
            h += bRect.size.height + 10.0f;
        }
    }
    
    if (self.buttons.count > 0) h -= 10.0f;
    
    CGRect rect = self.backgroundImageView.frame;
    rect.size.height = h + self.padding.bottom;
    self.backgroundImageView.frame = rect;
}

- (void)setTextAlignments {
    // titleLabel
    CGFloat w = self.titleLabel.frame.size.width;
    self.titleLabel.font = self.titleFont;
    self.titleLabel.textColor = self.titleColor;
    self.titleLabel.textAlignment = self.titleAlign;
    [self.titleLabel sizeToFit];
    CGRect rect = self.titleLabel.frame;
    rect.size.width = w;
    self.titleLabel.frame = rect;
    
    if (self.labelAlignMode == MTLAlertAlignModeFlexible)
    {
        if ([self lineNumber:self.titleLabel] > 1)
        {
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    // messageLabel
    w = self.messageLabel.frame.size.width;
    self.messageLabel.textAlignment = self.messageAlign;
    self.messageLabel.font = self.messageFont;
    self.messageLabel.textColor = self.messageColor;
    
    [self.messageLabel sizeToFit];
    
    rect = self.messageLabel.frame;
    rect.size.width = w;
    self.messageLabel.frame = rect;
    
    if (self.labelAlignMode == MTLAlertAlignModeFlexible)
    {
        if ([self lineNumber:self.messageLabel] > 1)
        {
            self.messageLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    // messageView
    self.messageView.font = self.messageFont;
    self.messageView.textColor = self.messageColor;
    
    if (self.labelAlignMode == MTLAlertAlignModeFlexible)
    {
        self.messageView.textAlignment = NSTextAlignmentLeft;
    } else {
        self.messageView.textAlignment = self.messageAlign;
    }
    
    // annotationLabel
    w = self.annotationLabel.frame.size.width;
    self.annotationLabel.textAlignment = self.annotationAlign;
    self.annotationLabel.font = self.annotationFont;
    self.annotationLabel.textColor = self.annotationColor;
    
    [self.annotationLabel sizeToFit];
    
    rect = self.annotationLabel.frame;
    rect.size.width = w;
    self.annotationLabel.frame = rect;
    
    if (self.labelAlignMode == MTLAlertAlignModeFlexible)
    {
        if ([self lineNumber:self.annotationLabel] > 1)
        {
            self.annotationLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            self.annotationLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
}

#pragma mark - ShowAnimation

- (void)executeShowAnimation:(void(^)(BOOL finished))completeHandler {
    [self executeShowAnimationDefaultTypeWithCompleteHandler:completeHandler];
}

- (void)executeShowAnimationDefaultTypeWithCompleteHandler:(void(^)(BOOL finished))completeHandler {
    __weak typeof(self) wSelf = self;
    self.backgroundImageView.transform = CGAffineTransformConcat(
                                                                 CGAffineTransformMakeScale(1.2f, 1.2f),
                                                                 CGAffineTransformRotate(wSelf.backgroundImageView.transform, 0.0f)
                                                                 );
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            wSelf.backgroundImageView.transform = CGAffineTransformConcat(
                                                                                          CGAffineTransformMakeScale(1.0f / 1.2f, 1.0f / 1.2f),
                                                                                          CGAffineTransformRotate(wSelf.backgroundImageView.transform, 0.0f)
                                                                                          );
                        } completion:^(BOOL finished) {
                            completeHandler(finished);
                        }];
    [UIView animateWithDuration:0.3f animations:^{
        wSelf.backgroundImageView.alpha = 1.f;
    }];
}

#pragma mark - CloseAnimation

- (void)executeCloseAnimation:(void(^)(BOOL finished))completeHandler
{
    [self executeCloseAnimationDefaultTypeWithCompleteHandler:completeHandler];
}

- (void)executeCloseAnimationDefaultTypeWithCompleteHandler:(void(^)(BOOL finished))completeHandler
{
    __weak typeof(self) wSelf = self;
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            wSelf.backgroundImageView.transform = CGAffineTransformConcat(
                                                                                          CGAffineTransformMakeScale(1.3f, 1.3f),
                                                                                          CGAffineTransformRotate(wSelf.backgroundImageView.transform, 0.0f)
                                                                                          );
                        } completion:^(BOOL finished) {
                            completeHandler(finished);
                        }];
    
    [UIView animateWithDuration:0.3f animations:^{
        wSelf.backgroundImageView.alpha = 0.f;
    }];
}

- (void)dismiss
{
    self.userInteractionEnabled = NO;
    
    if (self.closeTimer)
    {
        [self.closeTimer invalidate];
        self.closeTimer = nil;
    }
    
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    
    [self removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
}

- (UILabel *)titleLabelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(
                                                               self.padding.left,
                                                               0,
                                                               self.backgroundImageView.frame.size.width - (self.padding.left + self.padding.right),
                                                               0.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = title;
    return label;
}

- (UILabel *)messageLabelWithMessage:(NSString *)message
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(
                                                               self.padding.left,
                                                               0,
                                                               self.backgroundImageView.frame.size.width - (self.padding.left + self.padding.right),
                                                               0.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = message;
    return label;
}

- (UITextView *)messageViewWithMessage:(NSString *)message
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(
                                                                        self.padding.left,
                                                                        0,
                                                                        self.backgroundImageView.frame.size.width - (self.padding.left + self.padding.right),
                                                                        self.messageMaximumHeight)];
    textView.editable = NO;
    textView.contentInset = UIEdgeInsetsMake(-8,-8,-8,-8);
    textView.backgroundColor = [UIColor clearColor];
    textView.text = message;
    return textView;
}

- (UILabel *)annotationLabelWithAnnotation:(NSString *)annotation
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(
                                                               self.padding.left,
                                                               0,
                                                               self.backgroundImageView.frame.size.width - (self.padding.left + self.padding.right),
                                                               0.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = annotation;
    return label;
}

- (void)positionAlertView:(NSNotification*)notification
{
    CGFloat keyboardHeight;
    double animationDuration = 0.0f;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    
    CGFloat posY = (CGFloat) floor(activeHeight * 0.5);
    CGFloat posX = orientationFrame.size.width / 2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = (CGFloat) M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height - posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = (CGFloat) (-M_PI / 2.0f);
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = (CGFloat) (M_PI / 2.0f);
            newCenter = CGPointMake(orientationFrame.size.height - posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter
                                   rotateAngle:rotateAngle];
                         } completion:NULL];
    }
    else {
        [self moveToPoint:newCenter
              rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter
        rotateAngle:(CGFloat)angle
{
    self.backgroundImageView.transform = CGAffineTransformMakeRotation(angle);
    self.backgroundImageView.center = newCenter;
}

- (CGFloat)widthOfButton:(MTLAlertButton *)button
{
    NSString *str = button.titleLabel.text;
    return [str sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}].width;
}

#pragma mark - Action

- (void)pressButton:(MTLAlertButton *)button
{
    for (MTLAlertButton *button in self.buttons)
    {
        button.enabled = NO;
    }
    __weak typeof(self) wSelf = self;
    __block MTLAlertButton *bButton = button;
    
    [self executeCloseAnimation:^(BOOL finished) {
        if (bButton.pressHandler) bButton.pressHandler(wSelf);
        [wSelf dismiss];
    }];
}

- (void)backgroundTapHandler:(id)sender {
    __weak typeof(self) wSelf = self;
    [self executeCloseAnimation:^(BOOL finished) {
        [wSelf dismiss];
    }];
}

#pragma mark  - TimerHandler

- (void)timerHandler:(NSTimer *)timer
{
    __weak typeof(self) wSelf = self;
    
    [self executeCloseAnimation:^(BOOL finished) {
        if (wSelf.timerCloseHandler)
        {
            wSelf.timerCloseHandler(wSelf);
        }
        [wSelf dismiss];
    }];
}

#pragma mark - property

- (CGFloat)visibleKeyboardHeight
{
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    UIView *foundKeyboard = nil;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
            for (UIView *v in [possibleKeyboard subviews])
            {
                if ([[v description] hasPrefix:@"<UIKeyboardAutomatic"])
                {
                    foundKeyboard = v;
                }
            }
            
        } else {
            if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboardAutomatic"]) {
                foundKeyboard = possibleKeyboard;
                break;
            }
        }
    }

    if(foundKeyboard && foundKeyboard.bounds.size.height > 0)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}

#pragma mark - MTLAlertButtonDelegate

- (void)alertButton:(MTLAlertButton *)alertButton
     didChangeFrame:(CGRect)frame {
    [self layoutView];
}


#pragma mark - Helper method

- (int)lineNumber:(UILabel *)label{
    CGRect oneLineRect = [@"a" boundingRectWithSize:label.bounds.size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:NULL
                                            context:NULL];
    CGRect lineRect = [label.text boundingRectWithSize:label.bounds.size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:NULL
                                               context:NULL];
    return lineRect.size.height/oneLineRect.size.height;
}

#pragma mark - Appearance
/* ===== Font ===== */
- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
    [_titleLabel sizeToFit];
    [self layoutView];
    [self positionAlertView:nil];
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    _messageLabel.font = messageFont;
    _messageView.font = messageFont;
    [_messageLabel sizeToFit];
    [self layoutView];
    [self positionAlertView:nil];
}


- (void)setAnnotationFont:(UIFont *)annotationFont {
    _annotationFont = annotationFont;
    _annotationLabel.font = annotationFont;
    [_annotationLabel sizeToFit];
    [self layoutView];
    [self positionAlertView:nil];
}

/* ===== Color ===== */
- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    _messageLabel.textColor = messageColor;
    _messageView.textColor = messageColor;
}

- (void)setAnnotationColor:(UIColor *)messageColor {
    _annotationColor = messageColor;
    _annotationLabel.textColor = messageColor;
}

/* ===== Align ===== */
- (void)setTitleAlign:(NSTextAlignment)titleAlign {
    _titleAlign = titleAlign;
    [self setTextAlignments];
}


- (void)setMessageAlign:(NSTextAlignment)messageAlign {
    _messageAlign = messageAlign;
    [self setTextAlignments];
}


- (void)setAnnotationAlign:(NSTextAlignment)messageAlign {
    _annotationAlign = messageAlign;
    [self setTextAlignments];
}

/* ===== Margin ===== */
- (void)setTitleMargin:(UIEdgeInsets)titleMargin {
    _titleMargin = titleMargin;
    [self layoutView];
    [self positionAlertView:nil];
}


- (void)setMessageMargin:(UIEdgeInsets)messageMargin {
    _messageMargin = messageMargin;
    [self layoutView];
    [self positionAlertView:nil];
}



- (void)setLabelAlignMode:(MTLAlertAlignMode)labelAlignMode {
    _labelAlignMode = labelAlignMode;
    [self setTextAlignments];
}


/* ===== Images ===== */
- (void)setBackgroundImageName:(NSString *)backgroundImageName {
    _backgroundImageName = backgroundImageName;
    UIImage *image = [UIImage imageNamed:_backgroundImageName];
    [image resizableImageWithCapInsets:self.backgroundImageResizableInsets];
    self.backgroundImageView.image = image;
    [self layoutView];
    [self positionAlertView:nil];
}

- (void)setBackgroundImageResizableInsets:(UIEdgeInsets)backgroundImageResizableInsets {
    _backgroundImageResizableInsets = backgroundImageResizableInsets;
    [self layoutView];
    [self positionAlertView:nil];
}


/* ===== Layout ===== */
- (void)setMessageMaximumHeight:(CGFloat)messageMaximumHeight {
    _messageMaximumHeight = messageMaximumHeight;
    [self layoutView];
    [self positionAlertView:nil];
}


- (void)setPadding:(UIEdgeInsets)padding {
    _padding = padding;
    [self layoutView];
    [self positionAlertView:nil];
}


@end
