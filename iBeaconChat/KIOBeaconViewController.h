//
//  KIOBeaconViewController.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIOBeaconViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end
