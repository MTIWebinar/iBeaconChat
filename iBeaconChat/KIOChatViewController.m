//
//  KIOChatViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOChatViewController.h"
#import "KIOMessageService.h"


@interface KIOMessage : NSObject
@property (strong, nonatomic) NSString *uniqID;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDate *date;
@end
@implementation KIOMessage
@end


@interface KIOChatViewController ()
@property (strong, nonatomic) NSMutableArray *messages;
@end


@implementation KIOChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[KIOMessageService sharedInstance] startServices];
    
    self.messages = [NSMutableArray array];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(notificationKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(notificationMessage:) name:kKIOServiceMessagePeerReceiveDataNotification object:nil];
    [nc addObserver:self selector:@selector(notificationState:) name:kKIOServiceMessagePeerStateChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.messages = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - NSNotification

- (void)notificationKeyboard:(NSNotification *)notification {
    
    UIViewAnimationOptions keyboardCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    void (^animations)(void) = ^{
        
        UIEdgeInsets insets = self.tableView.contentInset;
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    };

    [UIView animateWithDuration:keyboardDuration
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:keyboardCurve
                     animations:animations
                     completion:nil];
}

- (void)notificationMessage:(NSNotification *)notification {

    KIOMessage *messageObject = [[KIOMessage alloc] init];
    messageObject.text = notification.userInfo[@"message"];
    messageObject.date = notification.userInfo[@"date"];
    messageObject.uniqID = notification.userInfo[@"id"];
    [self.messages addObject:messageObject];
    
    [self.tableView reloadData];
}

- (void)notificationState:(NSNotification *)notification {
    
    switch ([notification.userInfo[@"state"] integerValue]) {
        case 0:
            NSLog(@"Not Connected: %@", notification.userInfo[@"id"]);
            break;
        case 1:
            NSLog(@"Connecting: %@", notification.userInfo[@"id"]);
            break;
        case 2:
            NSLog(@"Connected: %@", notification.userInfo[@"id"]);
            break;
    }
}

#pragma mark - Action

- (IBAction)actionSend:(UIBarButtonItem *)sender {
    [[KIOMessageService sharedInstance] sendMessage:self.textField.text];
    
    KIOMessage *messageObject = [[KIOMessage alloc] init];
    messageObject.text = self.textField.text;
    messageObject.date = [NSDate date];
    messageObject.uniqID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self.messages addObject:messageObject];
    
    [self.tableView reloadData];
    self.textField.text = @"";
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];

    KIOMessage *message = self.messages[indexPath.row];
    
    if ([message.uniqID isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = message.text;
    } else {
        cell.textLabel.text = message.text;
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate


#pragma mark - UITextFieldDelegate


@end
