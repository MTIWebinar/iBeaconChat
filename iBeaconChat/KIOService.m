//
//  KIOService.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 20.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOService.h"
@import CoreBluetooth;

@interface KIOService ()  <CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@end


@implementation KIOService

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
        self.bluetoothManager =
        [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()
                                           options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    }
    return self;
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL bluetooth = central.state == CBPeripheralManagerStatePoweredOn ? YES : NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kKIOServiceBluetoothStateNotification object:nil
                        userInfo:@{kKIOServiceBluetoothStateNotification : @(bluetooth)}];
}


@end

NSString *const kKIOServiceBluetoothStateNotification = @"ru.kirillosipov.kKIOServiceBluetoothStateNotification";
