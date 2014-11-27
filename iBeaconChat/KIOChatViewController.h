//
//  KIOChatViewController.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIOChatViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)actionSend:(UIBarButtonItem *)sender;

@end
