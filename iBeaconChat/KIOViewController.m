//
//  KIOViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 20.05.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOViewController.h"

@interface KIOViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelStatus;
@property (nonatomic, weak) IBOutlet UIButton *buttonBroadcast;

@end

@implementation KIOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttonBroadcast.titleLabel.text = NSLocalizedString(@"buttonBroadcast", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
