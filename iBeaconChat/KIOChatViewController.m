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


@interface KIOChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) UILabel *noOneLable;
@end


@implementation KIOChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];

    self.messages = [NSMutableArray array];
    [[KIOMessageService sharedInstance] startServices];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(notificationKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(notificationMessage:) name:kKIOServiceMessagePeerReceiveDataNotification object:nil];
    [nc addObserver:self selector:@selector(notificationState:) name:kKIOServiceMessagePeerStateChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self scrollToEndContent];
    
//    if (self.messages.count == 0) {
//        [self.textField becomeFirstResponder];
//    }
//    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.messages = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - View Helper

- (void)scrollToEndContent {
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)showNoContent:(BOOL)show inView:(UIView *)view {
    if (show && !self.noOneLable) {
        self.noOneLable = [[UILabel alloc] initWithFrame:view.frame];
        self.noOneLable.text = NSLocalizedString(@"no_content", nil);
        self.noOneLable.textColor = [[UIColor grayColor] colorWithAlphaComponent:.5f];
        self.noOneLable.textAlignment = NSTextAlignmentCenter;
        self.noOneLable.center = self.tableView.center;
        [view addSubview:self.noOneLable];
    } else if (self.noOneLable) {
        [self.noOneLable removeFromSuperview];
        self.noOneLable = nil;
    }
}


#pragma mark - Setup View

- (void)setupView {
    CGFloat topInset = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    self.textField.enablesReturnKeyAutomatically = YES;
}


#pragma mark - NSNotification

- (void)notificationKeyboard:(NSNotification *)notification {
    
    UIViewAnimationOptions keyboardCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat pointY = CGRectGetMinY(keyboardRect);
    
    void (^animations)(void) = ^{

        CGRect toolBarRect = self.toolBar.frame;
        toolBarRect.origin.y = pointY - CGRectGetHeight(toolBarRect);
        
        for(NSLayoutConstraint *constraint in self.view.constraints) {
            if(constraint.secondAttribute == NSLayoutAttributeBottom && constraint.secondItem == self.toolBar) {
                constraint.constant = CGRectGetHeight(self.view.frame) - pointY;
            }
        }
        
        self.toolBar.frame = toolBarRect;
        [self.toolBar layoutIfNeeded];
    };

    [UIView animateWithDuration:keyboardDuration
                          delay:0
                        options:keyboardCurve
                     animations:animations
                     completion:nil];
    
    
    [self scrollToEndContent];
}

- (void)notificationMessage:(NSNotification *)notification {

    KIOMessage *messageObject = [[KIOMessage alloc] init];
    messageObject.uniqID = notification.userInfo[@"id"];
    messageObject.text = notification.userInfo[@"message"];
    messageObject.date = notification.userInfo[@"date"];
    [self.messages addObject:messageObject];
    
    [self.tableView reloadData];
}

- (void)notificationState:(NSNotification *)notification {
    KIOMessageServiceUserState state = [notification.userInfo[@"state"] integerValue];
    
    // TODO: how many items in chat
    
    switch (state) {
        case KIOMessageServiceUserStateNotConnected:
            NSLog(@"Not Connected: %@", notification.userInfo[@"id"]);
            break;
        case KIOMessageServiceUserStateConnecting:
            NSLog(@"Connecting: %@", notification.userInfo[@"id"]);
            break;
        case KIOMessageServiceUserStateConnected:
            NSLog(@"Connected: %@", notification.userInfo[@"id"]);
            break;
    }
}

#pragma mark - Action

- (void)send:(NSString *)message {
    [[KIOMessageService sharedInstance] sendMessage:message];
    
    KIOMessage *messageObject = [[KIOMessage alloc] init];
    messageObject.text = self.textField.text;
    messageObject.date = [NSDate date];
    messageObject.uniqID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self.messages addObject:messageObject];
    
    self.textField.text = nil;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.messages.count == 0 ? [self showNoContent:YES inView:self.tableView] : [self showNoContent:NO inView:self.tableView];
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];

    KIOMessage *message = self.messages[indexPath.row];
    NSString *myID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if ([message.uniqID isEqualToString:myID]) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = message.text;
    } else {
        cell.textLabel.text = message.text;
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send:textField.text];
    return NO;
}

@end
