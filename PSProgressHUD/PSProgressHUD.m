//
//  PSProgressHUD.m
//  PSProgressHUD
//
//  Created by Rotem Rubnov on 26/07/14.
//  Copyright (c) 2014 100grams. All rights reserved.
//

#import "PSProgressHUD.h"

@interface PSProgressHUD ()
@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIImageView *hudView;
@end



@implementation PSProgressHUD


#pragma mark - Instatiation 

+ (PSProgressHUD*)sharedView {
    static dispatch_once_t once;
    static PSProgressHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}



- (UIControl *)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        _overlayView.userInteractionEnabled = NO;
    }
    return _overlayView;
}





- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        NSMutableArray *imgListArray = [NSMutableArray array];
        NSArray *imgNums = @[@1,@2,@3,@4];
        CGRect bounds;
        for (NSNumber *num in imgNums) {
            NSString *strImgeName = [NSString stringWithFormat:@"Loading%02d", [num integerValue]];
            UIImage *image = [UIImage imageNamed:strImgeName];
            if (image) {
                [imgListArray addObject:image];
                bounds = CGRectMake(0,0,image.size.width, image.size.height);
            }
        }
        
        self.bounds = bounds;
        self.hudView = [[UIImageView alloc] initWithFrame:bounds];
        self.hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.hudView];
        [self.hudView setAnimationImages:imgListArray];
        self.hudView.animationDuration = 0.5;
    }
    return self;
}


#pragma mark - Show / Dismiss

+ (void) show;
{
    [[PSProgressHUD sharedView] show];
}

- (void) show
{

    if(!self.overlayView.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows)
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
    }
    
    if(!self.superview)
        [self.overlayView addSubview:self];
  
    [self.hudView startAnimating];
    
    [self.overlayView setHidden:NO];
    [self positionHUD:nil];

    [self registerNotifications];

    if (self.alpha != 1.f) {
        [UIView animateWithDuration:0.15 animations:^{
            self.alpha = 1.f;
        }];
    }
}


+ (void) dismiss
{
    [[PSProgressHUD sharedView] dismiss];
}


- (void) dismiss
{
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.hudView stopAnimating];
        [self.hudView removeFromSuperview];
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;

    }];
    
}


+ (BOOL)isVisible {
    return ([self sharedView].alpha == 1);
}



- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration = 0;
    
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
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
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
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
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
                             self.center = newCenter;
                         } completion:NULL];
    }
    
    else {
        self.center = newCenter;
    }
    
}


- (CGFloat)visibleKeyboardHeight {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")])
            return possibleKeyboard.bounds.size.height;
    }
    
    return 0;
}



#pragma mark - Notifications


- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}


@end
