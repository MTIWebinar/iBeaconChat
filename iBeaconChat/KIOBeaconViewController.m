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


#pragma mark -
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
@property (strong, nonatomic) UIView *pulseView;
@property (strong, nonatomic) NSDictionary *beacons;
@end


@implementation KIOBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self listenNotification];
    if (!self.pulseView) {
        [self startPulsingView:self.view];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self reloadBeaconView:self.beaconView];
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
    
    for (NSString *beaconID in self.beacons) {
        
        KIOBeaconProximity proximity = [self.beacons[beaconID] integerValue];
        
        CGFloat randomdx = (float)arc4random_uniform((int)(CGRectGetWidth(view.frame)/10)) * ((float)arc4random_uniform(2)?-1:1);
        CGFloat randomX = CGRectGetWidth(view.frame)/2 + randomdx;
        CGFloat randomY = [self proximityBeaconPointY:proximity inView:view];
        
        UIColor *color = [UIColor proximityBeaconColor:proximity];
        CGPoint point = CGPointMake(randomX, randomY);
        UIView *pulseBeacon = [UIView pulsatingCircleWithRadius:50.f position:point color:color];
        
        [view addSubview:pulseBeacon];
    }
}

- (CGFloat)proximityBeaconPointY:(KIOBeaconProximity)proximity inView:(UIView *)view {
    CGFloat h = CGRectGetHeight(view.frame);
    switch (proximity) {
        case KIOBeaconProximityUnknown:    return arc4random_uniform(h/2);             break;
        case KIOBeaconProximityImmediate:  return h - arc4random_uniform(20);          break;
        case KIOBeaconProximityNear:       return h/2 + h/3 + arc4random_uniform(h/3); break;
        case KIOBeaconProximityFar:        return h/2 + arc4random_uniform(h/3);       break;
    }
}

- (void)startPulsingView:(UIView *)view {
    CGFloat radius = CGRectGetHeight(view.frame);
    CGPoint point = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame));
    self.pulseView = [UIView pulsatingCircleWithRadius:radius position:point color:[UIColor greenColor]];
    [view addSubview:self.pulseView];
    [view setNeedsDisplay];
}


#pragma mark - NSNotification

- (void)listenNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationBeacon:) name:kKIOServiceBeaconsInRegionNotification object:nil];
}

- (void)notificationBeacon:(NSNotification *)notification {
    NSDictionary *tempBeacons = (NSDictionary *)notification.userInfo[@"beacons"];
    
    if (!self.beacons && tempBeacons.count > 0) {
        self.beacons = tempBeacons;
        [self reloadBeaconView:self.beaconView];
        [self.view setNeedsDisplay];
    } else {
        
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
