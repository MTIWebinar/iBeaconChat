//
//  KIOViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 23.05.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

@import CoreLocation;
@import CoreBluetooth;

#import "KIOViewController.h"
//#import "KIOBeacon.h"

@interface KIOViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelIamStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelNearStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelProximityStatus;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@end

@implementation KIOViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelIamStatus.text = nil;
    self.labelNearStatus.text = nil;
    self.labelProximityStatus.text = nil;
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"07296333-06D1-4081-9431-1CAFFCF36514"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"testregion"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)proximityString:(CLBeacon *)beacon
{
    switch (beacon.proximity) {
        case CLProximityUnknown:
            return NSLocalizedString(@"PROXIMITY_UNKNOWN", nil);
            break;
        case CLProximityImmediate:
            return NSLocalizedString(@"PROXIMITY_IMMEDIATE", nil);
            break;
        case CLProximityNear:
            return NSLocalizedString(@"PROXIMITY_NEAR", nil);
            break;
        case CLProximityFar:
            return NSLocalizedString(@"PROXIMITY_FAR", nil);
            break;
    }
}

- (UIColor *)proximityColor:(CLBeacon *)beacon
{
    switch (beacon.proximity) {
        case CLProximityUnknown:
            return [UIColor whiteColor];
            break;
        case CLProximityImmediate:
            return [UIColor redColor];
            break;
        case CLProximityNear:
            return [UIColor greenColor];
            break;
        case CLProximityFar:
            return [UIColor yellowColor];
            break;
    }
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        self.labelIamStatus.text = NSLocalizedString(@"BROADCASTING", nil);
        [self.peripheralManager startAdvertising:[self.beaconRegion peripheralDataWithMeasuredPower:nil]];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        self.labelIamStatus.text = NSLocalizedString(@"BLUTOOTH_OFF", nil);
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        self.labelIamStatus.text = NSLocalizedString(@"UNSUPPORTED_BL", nil);
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    if([region isKindOfClass:[CLBeaconRegion class]] && [region.identifier isEqualToString:self.beaconRegion.identifier]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    self.labelNearStatus.text = NSLocalizedString(@"GO_IN_TO_REGION", nil);
}

- (void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    if([region isKindOfClass:[CLBeaconRegion class]] && [region.identifier isEqualToString:self.beaconRegion.identifier]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    self.labelNearStatus.text = NSLocalizedString(@"GO_OUT_FROM_REGION", nil);
}

- (void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
    CLBeacon *foundBeacon = [beacons firstObject];
    self.labelProximityStatus.text = [self proximityString:foundBeacon];
    self.view.backgroundColor = [self proximityColor:foundBeacon];
    
    NSLog(@"foundBeacon %@", foundBeacon.proximityUUID.UUIDString);
    NSLog(@"foundBeacons %d", [beacons count]);
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState: %li for region: %@", state, region.identifier);
    
    if([region isKindOfClass:[CLBeaconRegion class]] && [region.identifier isEqualToString:self.beaconRegion.identifier]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if(state == CLRegionStateInside)
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        else
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
    }
}

@end
