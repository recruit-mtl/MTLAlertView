//
//  MTLViewController.m
//  MTLAlertView
//
//  Created by kasajei on 08/21/2015.
//  Copyright (c) 2015 kasajei. All rights reserved.
//

#import "MTLViewController.h"
#import "MTLAlertView.h"

@interface MTLViewController ()

@end

@implementation MTLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (IBAction)touchButton:(id)sender {
    MTLAlertView *alertView =  [MTLAlertView alertViewWithTitle:@"Test"];
    [alertView addSubmitButtonWithTitle:@"Submit" withPressHandler:nil];
    [alertView addCancelButtonWithTitle:@"Cancel" withPressHandler:nil];
    [alertView showWithMaskType:MTLAlertMaskTypeBlack];
}

@end
