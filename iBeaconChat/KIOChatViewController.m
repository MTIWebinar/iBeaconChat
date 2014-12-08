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
    
    self.messages = [NSMutableArray array];
    [[KIOMessageService sharedInstance] startServices];
    
    [self setupView];
    [self listenNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self scrollToEndContent];
    
//    if (self.messages.count == 0) {
//        [self.textField becomeFirstResponder];
//    }

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.messages = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Setup View

- (void)setupView {
    CGFloat topInset = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, 0, 0);
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:tgr];
    
    for (UIBarButtonItem *item in self.toolBar.items) {
        if ([item.customView isKindOfClass:[UITextField class]]) {
            item.width = CGRectGetWidth(self.view.frame) - topInset;
        }
    }
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textField.enablesReturnKeyAutomatically = YES;
    self.textField.placeholder = NSLocalizedString(@"enter_text", nil);
}

- (void)scrollToEndContent {
    if (self.tableView.contentSize.height > self.tableView.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height) {
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // TODO: viewWillTransitionToSize
}


#pragma mark - NSNotification

- (void)listenNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(notificationKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(notificationMessage:) name:kKIOServiceMessagePeerReceiveDataNotification object:nil];
    [nc addObserver:self selector:@selector(notificationState:) name:kKIOServiceMessagePeerStateChangeNotification object:nil];
}

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
    };

    void (^completion)(BOOL finished) = ^(BOOL finished){
        
        [self scrollToEndContent];
    };
    
    [UIView animateWithDuration:keyboardDuration
                          delay:0
                        options:keyboardCurve
                     animations:animations
                     completion:completion];
}

- (void)notificationMessage:(NSNotification *)notification {

    KIOMessage *messageObject = [[KIOMessage alloc] init];
    messageObject.uniqID = notification.userInfo[@"id"];
    messageObject.text = notification.userInfo[@"message"];
    messageObject.date = notification.userInfo[@"date"];
    [self.messages addObject:messageObject];
    [self.tableView reloadData];
    [self scrollToEndContent];
}

- (void)notificationState:(NSNotification *)notification {
    KIOMessageServiceUserState state = [notification.userInfo[@"state"] integerValue];
    
    // TODO: how many users in chat
    
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
    messageObject.uniqID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    messageObject.text = self.textField.text;
    messageObject.date = [NSDate date];
    [self.messages addObject:messageObject];
    [self.tableView reloadData];
    [self scrollToEndContent];

    self.textField.text = nil;
}

- (void)hideKeyboard {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.messages.count == 0 ? [self showNoContent:YES inView:self.tableView] : [self showNoContent:NO inView:self.tableView];
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    KIOMessage *message = self.messages[indexPath.row];
    NSString *myID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if ([message.uniqID isEqualToString:myID]) {
        cell.textLabel.text = @"";
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.text = message.text;
    } else {
        cell.textLabel.text = message.text;
        cell.detailTextLabel.text = @"";
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send:textField.text];
    return NO;
}


@end

