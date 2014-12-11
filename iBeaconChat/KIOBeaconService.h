//
//  KIOBeaconService.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 05.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, KIOBeaconProximity) {
    KIOBeaconProximityUnknown       = 0,
    KIOBeaconProximityImmediate,
    KIOBeaconProximityNear,
    KIOBeaconProximityFar
};

@interface KIOBeaconService : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitoring;
- (void)stopMonitoring;

@end

extern NSString *const kKIOServiceEnterBeaconRegionNotification;
extern NSString *const kKIOServiceExitBeaconRegionNotification;
extern NSString *const kKIOServiceBeaconsInRegionNotification;
extern NSString *const kKIOServiceLocationErrorNotification;
