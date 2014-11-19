//
//  KIOSplashViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOSplashViewController.h"


@implementation KIOSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [NSThread sleepForTimeInterval:.3f];
    [self performSegueWithIdentifier:@"GOSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
