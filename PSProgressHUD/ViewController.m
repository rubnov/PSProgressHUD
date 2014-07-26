//
//  ViewController.m
//  PSProgressHUD
//
//  Created by Rotem Rubnov on 26/07/14.
//  Copyright (c) 2014 100grams. All rights reserved.
//

#import "ViewController.h"
#import "PSProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [PSProgressHUD show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PSProgressHUD dismiss];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PSProgressHUD show];
    });
    


}
@end
