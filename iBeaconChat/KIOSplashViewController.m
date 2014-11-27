//
//  KIOSplashViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOSplashViewController.h"
#import "KIOPageViewController.h"
#import "KIOChatViewController.h"
#import "KIOBeaconViewController.h"
#import "KIOSettingsViewController.h"
#import "KIOErrorViewController.h"
#import "KIOBluetoothService.h"


@interface KIOSplashViewController ()
@property (nonatomic) BOOL blutoothState;
@end


@implementation KIOSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KIOBluetoothService sharedInstance];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationBlutoothState:) name:kKIOServiceBluetoothStateNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - NSNotification

- (void)notificationBlutoothState:(NSNotification *)notification {
    self.blutoothState = [notification.userInfo[kKIOServiceBluetoothStateNotification] boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:.3f];
        [self performSegueWithIdentifier:@"GOSegue" sender:self];
    });
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    KIOPageViewController *pageViewController = [segue destinationViewController];

    BOOL blutoothState = TARGET_IPHONE_SIMULATOR ? !self.blutoothState : self.blutoothState;
    
    if (blutoothState) {
        pageViewController.pageStoryboardIdentifiers = @[NSStringFromClass([KIOBeaconViewController class]),
                                                         NSStringFromClass([KIOChatViewController class])];
    } else {
        pageViewController.pageStoryboardIdentifiers = @[NSStringFromClass([KIOErrorViewController class])];
    }
}


@end
