//
//  KIOBeaconViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOBeaconViewController.h"
#import "KIOChatViewController.h"

#import "KIOMessageService.h"
#import "KIOBeaconService.h"

#import "UIView+Scanner.h"


#pragma mark -
@interface UIColor (Styling)
+ (UIColor *)randomColor;
+ (UIColor *)proximityBeaconColor:(KIOBeaconProximity)proximity;
@end
@implementation UIColor (Styling)
+ (UIColor *)randomColor {
    CGFloat r = (float)(arc4random() % 256) / 255.f;
    CGFloat g = (float)(arc4random() % 256) / 255.f;
    CGFloat b = (float)(arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}
+ (UIColor *)proximityBeaconColor:(KIOBeaconProximity)proximity {
    switch (proximity) {
        case KIOBeaconProximityUnknown:     return [UIColor lightGrayColor];    break;
        case KIOBeaconProximityImmediate:   return [UIColor redColor];          break;
        case KIOBeaconProximityNear:        return [UIColor greenColor];        break;
        case KIOBeaconProximityFar:         return [UIColor yellowColor];       break;
        default:                            return [UIColor clearColor];        break;
    }
}
@end


#pragma mark - KIOBeaconViewController

@interface KIOBeaconViewController ()
@property (strong, nonatomic) UIView *animatedView;
@property (strong, nonatomic) NSDictionary *beacons;
@end


@implementation KIOBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self listenNotification];
    if (!self.animatedView) {
        [self startScaningView:self.view];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self reloadBeaconView:self.beaconView];
    if (self.animatedView) {
        [self.animatedView removeFromSuperview];
        self.animatedView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UI creater

- (void)reloadBeaconView:(UIView *)view {
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSString *beaconID in self.beacons) {
        
        KIOBeaconProximity proximity = [self.beacons[beaconID] integerValue];
        UIColor *color = [UIColor proximityBeaconColor:proximity];
        CGPoint point = [self pointForProximity:proximity inView:view];
        UIView *pulseBeacon = [UIView pulsingCircleWithRadius:50.f position:point color:color];
        
        [view addSubview:pulseBeacon];
    }
}

- (CGPoint)pointForProximity:(KIOBeaconProximity)proximity inView:(UIView *)view {
    CGPoint point;
    
    CGFloat w = CGRectGetWidth(view.frame);
    CGFloat h = CGRectGetHeight(view.frame);
    
    float sign = arc4random_uniform(2) ? -1 : 1;
    CGFloat randomX = arc4random_uniform(w/2) * sign;
    CGFloat randomY = arc4random_uniform(h/3);
    
    switch (proximity) {
        
        case KIOBeaconProximityImmediate: {
            point.x = w/2 + randomX / 8;
            point.y = h - randomY;
        }break;
        
        case KIOBeaconProximityNear: {
            point.x = w/2 + randomX / 3;
            point.y = h - h/3 - randomY;
        }break;
        
        case KIOBeaconProximityFar: {
            point.x =  w/2 + randomX / 2;
            point.y = randomY;
        }break;
        
        case KIOBeaconProximityUnknown: {
            point.x = w/2 + randomX;
            point.y = randomY / 4;
        }break;
    }
    
    return point;
}

- (void)startScaningView:(UIView *)view {

    self.animatedView = [UIView scaningFrame:view.frame color:[UIColor greenColor]];
    [view addSubview:self.animatedView];

    self.animatedView.alpha = 0.f;
    void (^animations)(void) = ^{
        self.animatedView.alpha = 1.0f;
    };
    [UIView animateWithDuration:.8f animations:animations];
}


#pragma mark - NSNotification

- (void)listenNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationBeacon:) name:kKIOServiceBeaconsInRegionNotification object:nil];
}

- (void)notificationBeacon:(NSNotification *)notification {
    NSDictionary *tempBeacons = (NSDictionary *)notification.userInfo[@"beacons"];

#warning beacons array need to be refuck
    
    if (!self.beacons && tempBeacons.count > 0) {
        self.beacons = tempBeacons;
        [self reloadBeaconView:self.beaconView];
        [self.view setNeedsDisplay];
    }
    else {
        
        // TODO: isNew beacon refuck
        for (NSString *beaconID in tempBeacons.allKeys) {
            if (![self.beacons.allKeys containsObject:beaconID] ||
                ![tempBeacons[beaconID] isEqualToNumber:self.beacons[beaconID]]) {
                
                self.beacons = tempBeacons;
                [self reloadBeaconView:self.beaconView];
                [self.view setNeedsDisplay];
            }
        }
    }
}


@end
