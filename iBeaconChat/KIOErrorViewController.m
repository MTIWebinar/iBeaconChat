//
//  KIOErrorViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 20.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOErrorViewController.h"

@implementation KIOErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lable.text = NSLocalizedString(@"bluetooth_error", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    

    self.bgView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5f];
    self.bgView.layer.cornerRadius = 10.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
