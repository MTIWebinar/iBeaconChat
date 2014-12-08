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
//    scaleAnimation.duration = .8f;
    scaleAnimation.fromValue = @0.0f;
    scaleAnimation.toValue = @1.0f;
//    scaleAnimation.autoreverses = YES;
    
    CAKeyframeAnimation *opacityAnimation;
    opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0.2f, @0.4f, @0.0f];
    opacityAnimation.keyTimes = @[@0.0f, @0.3f, @1.0f];
    opacityAnimation.removedOnCompletion = NO;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = .8f * 2;
    groupAnimation.repeatCount = HUGE_VAL;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.animations = @[opacityAnimation, scaleAnimation];
    
    [view.layer addAnimation:groupAnimation forKey:@"groupAnimation"];

    return view;
}
@end


@interface UIColor (Styling)
+ (UIColor *)randomColor;
+ (UIColor *)proximityBeaconColor:(CLBeacon *)beacon withAlphaComponent:(CGFloat)alpha;
@end
@implementation UIColor (Styling)
+ (UIColor *)randomColor {
    CGFloat r = (float)(arc4random() % 256) / 255.f;
    CGFloat g = (float)(arc4random() % 256) / 255.f;
    CGFloat b = (float)(arc4random() % 256) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

+ (UIColor *)proximityBeaconColor:(CLBeacon *)beacon withAlphaComponent:(CGFloat)alpha {
    switch (beacon.proximity) {
        case CLProximityUnknown:    return [[UIColor lightGrayColor] colorWithAlphaComponent:alpha]; break;
        case CLProximityImmediate:  return [[UIColor redColor] colorWithAlphaComponent:alpha]; break;
        case CLProximityNear:       return [[UIColor greenColor] colorWithAlphaComponent:alpha]; break;
        case CLProximityFar:        return [[UIColor yellowColor] colorWithAlphaComponent:alpha]; break;
        default:                    return [UIColor clearColor]; break;
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

- (void)reloadBeaconView {
    [self.beaconView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (CLBeacon *beacon in self.beacons) {
        CGFloat random = (float)arc4random_uniform(3) + 2;

        UIColor *color = [UIColor proximityBeaconColor:beacon withAlphaComponent:1.f];
        CGPoint point = CGPointMake(CGRectGetMaxX(self.beaconView.frame)/2, CGRectGetMaxY(self.beaconView.frame)/random);
        UIView *pulseBeacon = [UIView pulsatingCircleWithRadius:50.f position:point color:color];
        
        [self.beaconView addSubview:pulseBeacon];
    }
    
    [self.view setNeedsDisplay];
}

#pragma mark - NSNotification

- (void)listenNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationMessage:) name:kKIOServiceMessagePeerReceiveDataNotification object:nil];
    [nc addObserver:self selector:@selector(notificationBeacon:) name:kKIOServiceBeaconsInRegionNotification object:nil];
}

- (void)notificationMessage:(NSNotification *)notification {
    
    if (!self.pulseView) {
        CGFloat radius = 50.f;
        CGFloat random = (float)arc4random_uniform(5) + 2;
        CGPoint point = CGPointMake(CGRectGetMaxX(self.view.frame) - radius/7, CGRectGetMaxY(self.view.frame)/random);
        self.pulseView = [UIView pulsatingCircleWithRadius:radius position:point color:[UIColor redColor]];
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionMessage)];
        [self.pulseView addGestureRecognizer:tgr];
        [self.view addSubview:self.pulseView];
        [self.view setNeedsDisplay];
    }
}

- (void)notificationBeacon:(NSNotification *)notification {
    self.beacons = (NSArray *)notification.userInfo[@"beacons"];
    [self reloadBeaconView];
}

#pragma mark - Action

- (void)actionMessage {
    NSLog(@"PIP");
}


@end
