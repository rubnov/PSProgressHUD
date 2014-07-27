//
//  PSProgressHUD.h
//  PSProgressHUD
//
//  Created by Rotem Rubnov on 26/07/14.
//  Copyright (c) 2014 100grams. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPSHudImageNameFormat   @"Loading%02d"
#define kPSHudImageNumbers      @[@1,@2,@3,@4];

@interface PSProgressHUD : UIView

+ (void) show;
+ (void) dismiss;
+ (BOOL) isVisible;

@end
