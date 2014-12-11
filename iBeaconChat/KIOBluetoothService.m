//
//  KIOService.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 20.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOBluetoothService.h"
@import CoreBluetooth;

@interface KIOBluetoothService ()  <CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@end


@implementation KIOBluetoothService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @(NO)};
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                     queue:dispatch_get_main_queue()
                                                                   options:options];
    }

    return self;
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL bluetoothON = central.state == CBPeripheralManagerStatePoweredOn ? YES : NO;
    [self postNotificationBluetoothState:bluetoothON];
}


#pragma mark - Notification

- (void)postNotificationBluetoothState:(BOOL)bluetoothState {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kKIOServiceBluetoothStateNotification object:nil
                        userInfo:@{kKIOServiceBluetoothStateNotification : @(bluetoothState)}];
}

@end

NSString *const kKIOServiceBluetoothStateNotification = @"ru.kirillosipov.kKIOServiceBluetoothStateNotification";
