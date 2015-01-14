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
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *myUUID = [userDefaults objectForKey:@"KIOAppInitialUUID"];
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:myUUID];
        sharedInstance = [[self alloc] initWithUUID:uuid];
        
    });
    return sharedInstance;
}


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
    [self requestAlwaysAuthorization];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)stopMonitoring {
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    [self postLocalNotificationType:KIOLocalNotificationTypeDelete beaconRegion:self.beaconRegion];
}


#pragma mark - iOS8 Authorization Status

- (void)requestAlwaysAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title = (status == kCLAuthorizationStatusDenied)
                        ? NSLocalizedString(@"alert_location_off_title", nil)
                        : NSLocalizedString(@"alert_location_background_title", nil);
        
        NSString *message = NSLocalizedString(@"alert_background_location_always_message", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"alert_cancel_button", nil);
        NSString *settingsButtonTitle = NSLocalizedString(@"alert_settings_button", nil);
        
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:title
                                   message:message
                                  delegate:self
                         cancelButtonTitle:cancelButtonTitle
                         otherButtonTitles:settingsButtonTitle, nil];
        [alertView show];
    }
    
    else if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


#pragma mark - Notification

- (void)postNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:nil userInfo:userInfo];
}

- (void)postLocalNotificationType:(KIOLocalNotificationType)localNotificationType beaconRegion:(CLBeaconRegion *)beaconRegion {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL localNotificationON = [[userDefaults objectForKey:@"KIOLocalNotificationON"] boolValue];

    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
    
    if (localNotificationON) {
        
        if (localNotificationType == KIOLocalNotificationTypePost) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = NSLocalizedString(@"user_enter", nil);;
            notification.soundName = UILocalNotificationDefaultSoundName;
            
            // TODO: nikname for ibeacon
            // notification.userInfo = @{@"proximityUUID": [beaconRegion.proximityUUID UUIDString]};
            
            [application presentLocalNotificationNow:notification];
        }
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
