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


@interface CAGradientLayer (Gradient)
+ (CAGradientLayer *)gradient;
@end
@implementation CAGradientLayer (Gradient)
+ (CAGradientLayer *)gradient {
    
    UIColor *colorOne = [[UIColor redColor] colorWithAlphaComponent:0.1f];
    UIColor *colorTwo = [[UIColor redColor] colorWithAlphaComponent:0.6f];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    headerLayer.locations = @[@0.0f, @1.0f];
    
    return headerLayer;
}
@end


@interface UIView (Pulse)
+ (UIView *)pulsatingCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color;
@end
@implementation UIView (Pulse)
+ (UIView *)pulsatingCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    view.center = point;
    view.backgroundColor = color;
    view.layer.cornerRadius = radius;
    
    CABasicAnimation *scaleAnimation;
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @0.0f;
    scaleAnimation.toValue = @1.0f;
    
    CAKeyframeAnimation *opacityAnimation;
    opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0.2f, @0.4f, @0.0f];
    opacityAnimation.keyTimes = @[@0.0f, @0.3f, @1.0f];
    opacityAnimation.removedOnCompletion = NO;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = .8f * 4;
    groupAnimation.repeatCount = HUGE_VAL;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.animations = @[opacityAnimation, scaleAnimation];
    
    [view.layer addAnimation:groupAnimation forKey:@"groupAnimation"];

    return view;
}
@end


@interface UIColor (Styling)
+ (UIColor *)randomColor;
+ (UIColor *)proximityBeaconColor:(CLBeacon *)beacon;
@end
@implementation UIColor (Styling)
+ (UIColor *)randomColor {
    CGFloat r = (float)(arc4random() % 256) / 255.f;
    CGFloat g = (float)(arc4random() % 256) / 255.f;
    CGFloat b = (float)(arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}
+ (UIColor *)proximityBeaconColor:(CLBeacon *)beacon {
    switch (beacon.proximity) {
        case CLProximityUnknown:    return [UIColor lightGrayColor];    break;
        case CLProximityImmediate:  return [UIColor redColor];          break;
        case CLProximityNear:       return [UIColor greenColor];        break;
        case CLProximityFar:        return [UIColor yellowColor];       break;
        default:                    return [UIColor clearColor];        break;
    }
}
@end









@interface KIOBeaconViewController ()
@property (strong, nonatomic) UIView *pulseView;
@property (strong, nonatomic) NSArray *beacons;
@end


@implementation KIOBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startPulsingView:self.view];
    [self listenNotification];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.pulseView) {
        [self.pulseView removeFromSuperview];
        self.pulseView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UI creater

- (void)reloadBeaconView:(UIView *)view {
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (CLBeacon *beacon in self.beacons) {
        
        CGFloat randomdx = (float)arc4random_uniform(10) * (float)arc4random_uniform(2)?-1:1;
        CGFloat randomX = CGRectGetWidth(view.frame)/2 + randomdx;
        CGFloat randomY = [self proximityBeaconPointY:beacon inView:view];
        
        UIColor *color = [UIColor proximityBeaconColor:beacon];
        CGPoint point = CGPointMake(randomX, randomY);
        UIView *pulseBeacon = [UIView pulsatingCircleWithRadius:50.f position:point color:color];
        
        [view addSubview:pulseBeacon];
    }
}

- (CGFloat)proximityBeaconPointY:(CLBeacon *)beacon inView:(UIView *)view {
    CGFloat h = CGRectGetHeight(view.frame);
    switch (beacon.proximity) {
        case CLProximityUnknown:    return arc4random_uniform(h/2);             break;
        case CLProximityImmediate:  return h - arc4random_uniform(10);          break;
        case CLProximityNear:       return h/2 + h/3 + arc4random_uniform(h/3); break;
        case CLProximityFar:        return h/2 + arc4random_uniform(h/3);       break;
    }
}

- (void)startPulsingView:(UIView *)view {
    CGFloat radius = CGRectGetHeight(view.frame);
    CGPoint point = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame));
    self.pulseView = [UIView pulsatingCircleWithRadius:radius position:point color:[UIColor greenColor]];
    [view addSubview:self.pulseView];
    [view setNeedsDisplay];
}

- (void)setupViewUI {
    CAGradientLayer *bgLayer = [CAGradientLayer gradient];
    bgLayer.frame = self.radarView.frame;
    [self.radarView.layer addSublayer:bgLayer];
}


#pragma mark - NSNotification

- (void)listenNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationMessage:) name:kKIOServiceMessagePeerReceiveDataNotification object:nil];
    [nc addObserver:self selector:@selector(notificationBeacon:) name:kKIOServiceBeaconsInRegionNotification object:nil];
}

- (void)notificationMessage:(NSNotification *)notification {
    NSLog(@"%@", notification.userInfo);
}

- (void)notificationBeacon:(NSNotification *)notification {
    NSArray *tempBeacons = (NSArray *)notification.userInfo[@"beacons"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isNew = NO;
        for (CLBeacon *beacon in tempBeacons) {
            if (![self.beacons containsObject:beacon]) {
                isNew = YES;
            };
        }
    
        if (isNew) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.beacons = tempBeacons;
                [self reloadBeaconView:self.beaconView];
                [self.view setNeedsDisplay];
            });
        }
    });
}

#pragma mark - Action

- (void)actionMessage {
    NSLog(@"PIP");
}


@end
