//
//  UIView+Scanner.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 07.01.15.
//  Copyright (c) 2015 Kirill Osipov. All rights reserved.
//

#import "UIView+Scanner.h"


@implementation UIView (Scanner)

+ (UIView *)pulsingCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    view.backgroundColor = UIColor.clearColor;
    view.center = point;
    
    // center point
    CGRect rect;
    rect.size = CGSizeMake(radius * .4f, radius * .4f);
    rect.origin = CGPointMake(radius - radius * .2f, radius - radius * .2f);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    CAShapeLayer *centerPoint = CAShapeLayer.layer;
    centerPoint.lineWidth = 2.f;
    centerPoint.strokeColor = [UIColor whiteColor].CGColor;
    centerPoint.fillColor = color.CGColor;
    centerPoint.shadowRadius = 10.f;
    centerPoint.shadowColor = [UIColor whiteColor].CGColor;
    centerPoint.shadowOffset = CGSizeMake(0, 0);
    centerPoint.shadowOpacity = 1.f;
    centerPoint.path = bezierPath.CGPath;
    
    [view.layer addSublayer:centerPoint];
    
    // animation
    UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    innerView.backgroundColor = color;
    innerView.layer.cornerRadius = radius;

    CABasicAnimation *scaleAnimation;
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
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
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimation.animations = @[opacityAnimation, scaleAnimation];
    
    [innerView.layer addAnimation:groupAnimation forKey:@"groupAnimation"];
    
    [view insertSubview:innerView atIndex:0];
    
    return view;
}

+ (UIView *)scaningFrame:(CGRect)frame color:(UIColor *)color {
    
    CGFloat radius = CGRectGetHeight(frame);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    view.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame));
    view.backgroundColor = UIColor.clearColor;
    view.layer.cornerRadius = radius;
    
    // radar line for animation
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint:CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame)/2 - 50)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(view.frame)/2, 30)];
    
    CAShapeLayer *layer = CAShapeLayer.layer;
    layer.lineWidth = 1.f;
    layer.lineCap = @"round";
    layer.strokeColor = color.CGColor;
    layer.path = bezierPath.CGPath;
    [view.layer addSublayer:layer];
    
    // animation
    float angle = (float)(M_PI_2 - atanf(CGRectGetHeight(view.frame)/(CGRectGetWidth(view.frame)/2)));
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.autoreverses = YES;
    rotationAnimation.duration = 2.3f;
    rotationAnimation.repeatCount = HUGE_VAL;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:-angle];
    rotationAnimation.toValue = [NSNumber numberWithFloat:angle];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:rotationAnimation forKey:@"animateLayer"];

    return view;
}

@end
