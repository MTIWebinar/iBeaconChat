//
//  KIOService.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 20.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

@import Foundation;

@interface KIOService : NSObject

+ (instancetype)sharedInstance;

@end

extern NSString *const kKIOServiceBluetoothStateNotification;
