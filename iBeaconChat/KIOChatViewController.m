//
//  KIOChatViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOChatViewController.h"
#import "KIOMessageService.h"


@interface KIOChatViewController ()
@property (strong, nonatomic) KIOMessageService *messageService;
@end

@implementation KIOChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.messageService = [[KIOMessageService alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action

- (IBAction)actionTest:(id)sender {
    [self.messageService sendString:@"Hello word"];
}


@end
