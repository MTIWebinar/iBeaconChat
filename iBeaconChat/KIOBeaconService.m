//
//  KIOBeaconService.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 05.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOBeaconService.h"
@import CoreLocation;
@import UIKit;


typedef NS_ENUM(NSUInteger, KIOLocalNotificationType){
    KIOLocalNotificationTypePost    = 0,
    KIOLocalNotificationTypeDelete
};


#pragma mark - CLBeacon Category
@interface CLBeacon (Helper)
- (NSString *)unicID;
@end
@implementation CLBeacon (Helper)
- (NSString *)unicID {
    return [NSString stringWithFormat:@"%@-%@-%@", self.proximityUUID.UUIDString, self.major, self.minor];
}
@end


#pragma mark - KIOBeacon Service
@interface KIOBeaconService ()  <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@end


@implementation KIOBeaconService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *myUUID = @"ebefd083-70a2-47c8-9837-e7b5634df524";
//        NSString *myUUID = @"f7826da6-4fa2-4e98-8024-bc5b71e0893e";
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:myUUID];
        sharedInstance = [[self alloc] initWithUUID:uuid];
        
    });
    return sharedInstance;
}

// TODO: uuid in app settings


#pragma mark - Privat

- (instancetype)initWithUUID:(NSUUID *)uuid {
    self = [super init];
    if (self) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        NSString *identifier = [NSString stringWithFormat:@"ru.ibeaconchat.%@", [uuid UUIDString]];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
    }
    
    return self;
}

- (void)startMonitoring {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        // TODO: show request
        NSLog(@"CLLocationManager kCLAuthorizationStatusNotDetermined");
    }
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)stopMonitoring {
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    [self postLocalNotificationType:KIOLocalNotificationTypeDelete beaconRegion:self.beaconRegion];
}


#pragma mark - Notification

- (void)postNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:nil userInfo:userInfo];
}

- (void)postLocalNotificationType:(KIOLocalNotificationType)localNotificationType beaconRegion:(CLBeaconRegion *)beaconRegion {
    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
    
    if (localNotificationType == KIOLocalNotificationTypePost) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = NSLocalizedString(@"user_enter", nil);;
        notification.soundName = UILocalNotificationDefaultSoundName;

        // TODO: nikname for ibeacon
        // notification.userInfo = @{@"proximityUUID": [beaconRegion.proximityUUID UUIDString]};

        [application presentLocalNotificationNow:notification];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.proximityUUID isEqual:self.beaconRegion.proximityUUID]) {
            
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
            
            [self postNotificationName:kKIOServiceEnterBeaconRegionNotification userInfo:nil];
            [self postLocalNotificationType:KIOLocalNotificationTypePost beaconRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.proximityUUID isEqual:self.beaconRegion.proximityUUID]) {
            
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
            
            [self postNotificationName:kKIOServiceExitBeaconRegionNotification userInfo:nil];
            [self postLocalNotificationType:KIOLocalNotificationTypeDelete beaconRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count > 0) {
        if ([region.proximityUUID isEqual:self.beaconRegion.proximityUUID]) {
            NSMutableDictionary *beaconDictionary = [NSMutableDictionary dictionaryWithCapacity:beacons.count];
            for (CLBeacon *beacon in beacons) {
                beaconDictionary[[beacon unicID]] = @(beacon.proximity);
            }
            [self postNotificationName:kKIOServiceBeaconsInRegionNotification userInfo:@{@"beacons": beaconDictionary}];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        
        if (state == CLRegionStateInside) {
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        } else {
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self postNotificationName:kKIOServiceLocationErrorNotification userInfo:@{@"error": error}];
}


@end

NSString *const kKIOServiceEnterBeaconRegionNotification = @"ru.kirillosipov.kKIOServiceEnterBeaconRegionNotification";
NSString *const kKIOServiceExitBeaconRegionNotification = @"ru.kirillosipov.kKIOServiceExitBeaconRegionNotification";
NSString *const kKIOServiceBeaconsInRegionNotification = @"ru.kirillosipov.kKIOServiceBeaconsInRegionNotification";
NSString *const kKIOServiceLocationErrorNotification = @"ru.kirillosipov.kKIOServiceLocationErrorNotification";
